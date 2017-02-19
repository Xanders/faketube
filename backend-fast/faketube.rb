# frozen_string_literal: true

p "Loading..." # STDOUT pipes to Docker logs

require 'bundler'
Bundler.require
require_relative './youtube.rb'
require_relative './fiber_io.rb'
FiberIO.instant_copy_stream!

module FakeTube
  CORS_ORIGIN = "Access-Control-Allow-Origin: *\r\n"
  CORS_OPTIONS = "Access-Control-Allow-Methods: HEAD,GET,PUT,PATCH,POST,DELETE,OPTIONS\r\nAccess-Control-Allow-Headers: X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept\r\n"

  def post_init
    @buffer, @state = FiberIO.empty_buffer, :none
  end

  def receive_data(message)
    message.force_encoding('ascii-8bit')
    case @state
    when :none
      @buffer.concat(message)
      parse_query
    when :preparing
      @buffer.concat(message)
      search_for_data_beginning
    when :uploading
      upload(message)
    end
  rescue => error
    p "#{error.class}: #{error.message}\n#{error.backtrace * "\n"}"
    answer(500)
  end

  def parse_query
    unless @buffer["\r\n"]
      close_connection if @buffer.size > 500
      return
    end
    /^(?<verb>GET|POST|PATCH|OPTIONS) \/(?:yt(?<id>.+?))?(?:\?title=(?<title>.+?))? / =~ @buffer
    p $~[0].strip # Last regexp match
    return answer(400) unless title.nil? || good_title?(title)
    case verb
    when 'GET'
      save_defer do
        answer(id ? find_video(id) || 404 : all_videos)
      end
    when 'POST'
      if id
        answer(404)
      else
        @state, @title = :preparing, title
        search_for_data_beginning
      end
    when 'PATCH'
      if id
        save_defer do
          video = find_video(id) or return answer(404)
          video.update(title: title, category_id: video.category_id) # Need category_id due to bug in yt gem
          answer
        end
      else
        answer(404)
      end
    when 'OPTIONS'
      answer(200, CORS_OPTIONS)
    end
  end

  def search_for_data_beginning
    headers = @buffer.index("\r\n\r\n")
    content = @buffer.index("\r\n\r\n", headers + 1) if headers
    return unless content
    /^Content-Length: *(?<size>\d+)\r\n/i =~ @buffer
    /^Content-Type: *multipart\/form-data; *boundary=(?<boundary>.+?)\r\n/i =~ @buffer
    return answer(400) unless size && boundary
    @state = :uploading
    @buffer.slice!(0, content + 4)
    video_size = size.to_i - (content - headers) - (boundary.size + 8) # 8 is "\r\n--" before boundary and "--\r\n" after boundary ending
    fiber = Fiber.new do
      @io = FiberIO.new(video_size, fiber)
      upload(@buffer)
      @buffer = nil
      save_defer do
        answer(upload_video(@io, title: @title, privacy_status: :unlisted))
      end
    end
    fiber.resume
  end

  def upload(message)
    @io.write(message)
  end

  def answer(with = nil, extra_headers = nil)
    status, body = if with.kind_of?(Integer)
      [with, nil]
    else
      [200, with]
    end
    body ||= ''
    body = body.to_json unless body.kind_of?(String)
    content_length = "Content-Length: #{body.bytesize}\r\n"
    content_type = "Content-Type: application/json\r\n" if body.size > 0
    headers = "#{CORS_ORIGIN}#{extra_headers}#{content_length}#{content_type}"
    send_data "HTTP/1.0 #{status}\r\n#{headers}\r\n#{body}"
    close_connection_after_writing
    @state = :closed
  end

  def save_defer(&block)
    EventMachine.defer do
      begin
        yield
      rescue => error
        p "#{error.class}: #{error.message}\n#{error.backtrace * "\n"}"
        answer(500)
      end
    end
  end
end

EventMachine.run do
  host, port = ENV['HOST'] || '0.0.0.0', ENV['PORT']&.to_i || 4568
  EventMachine.start_server(host, port, FakeTube)
  p "Ready, port #{port}"
end
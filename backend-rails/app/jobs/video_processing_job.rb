class VideoProcessingJob < ApplicationJob
  THUMBNAIL_SIZE = '240x180'

  queue_as :default

  def perform(watermark:, path: nil, id: nil)
    raise ArgumentError, 'use one of path or id options' if path && id || !path && !id

    video = if id
      Video.find_by_id(id)
    else
      file = File.open(path)
      Video.new(original: file)
    end

    unless video
      Rails.logger.warn "can't find video for processing: #{id}"
      return
    end

    path = video.original.path if video.persisted?

    time = time_of(path)
    uuid = SecureRandom.uuid
    processed = with_watermark(path, watermark, uuid)
    thumbnail = screenshot_of(processed.path, time, uuid)

    video.update!(processed: processed, thumbnail: thumbnail, time: time)

    file&.close
    processed.close
    thumbnail.close
    FileUtils.rm(path) unless id
    FileUtils.rm(processed.path)
    FileUtils.rm(thumbnail.path)
  end

  def time_of(path)
    `ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "#{path}"`.to_f.round
  end

  def with_watermark(path, text, uuid)
    output = "tmp/video_processing/#{uuid}.mp4"
    text.sub!(/(.{50,}?) /, "\\1\n")
    `ffmpeg -i "#{path}" -vf drawtext="text='#{text}': fontcolor=white: fontsize=24: box=1: boxcolor=black@0.5: boxborderw=5: x=30: y=h-text_h-30" -y -codec:a copy "#{output}"`
    File.open(output)
  end

  def screenshot_of(path, time, uuid)
    start = (time * 0.01).ceil
    output = "tmp/video_processing/#{uuid}.jpg"
    `ffmpeg -ss #{start} -i "#{path}" -deinterlace -an -f mjpeg -t 1 -r 1 -y -s #{THUMBNAIL_SIZE} "#{output}"`
    File.open(output)
  end
end
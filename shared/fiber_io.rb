# frozen_string_literal: true

require 'fiber'

# FiberIO acts as limited IO-object, but wait on given fiber on overreading

class FiberIO
  attr_reader :size

  def initialize(size, fiber)
    @size = size
    @fiber = fiber
    rewind
  end

  # IO class mimicry, can't inherit because of different iternal structure

  def eof?
    raise IOError, 'not opened for reading' if closed?
    @total == @size && @buffer.empty?
  end
  alias eof eof?

  def read(bytes = nil, output = nil)
    raise IOError, 'not opened for reading' if closed?
    if eof?
      output.clear
      return bytes && !bytes.zero? ? nil : output || FiberIO.empty_buffer
    end
    left = @buffer.size + @size - @total
    real_bytes = bytes ? bytes > left ? left : bytes : @buffer.size.zero? ? left : @buffer.size
    if @buffer.size < real_bytes
      Fiber.yield
      return read(bytes, output)
    end
    result = @buffer.slice!(0, real_bytes)
    output ? output.replace(result) : result
  end

  def write(string)
    raise IOError, 'not opened for writing' if closed?
    return 0 if @total == @size
    string.force_encoding('ascii-8bit')
    string = string.slice(0, @size - @total) if string.size > @size - @total
    @total += string.size
    @buffer.concat(string)
    @fiber.resume if @fiber.alive? && Fiber.current != @fiber
    string.size
  end

  def rewind
    @buffer = FiberIO.empty_buffer
    @total = 0
  end

  def close
    raise IOError, 'closed stream' if closed?
    @buffer = nil
  end
  def closed?
    @buffer.nil?
  end

  # Just for generating empty buffer

  def self.empty_buffer
    String.new.force_encoding('ascii-8bit')
  end

  # Use `FiberIO.instant_copy_stream!` to extend IO.copy_stream
  # with non-chunked byte-to-byte copying for FiberIO objects

  module IOExtension
    def copy_stream(from, to, maximum = nil, offset = nil)
      return super unless from.kind_of?(FiberIO)
      # Do not support offset for FiberIO
      return to.write(from.read(maximum)) if maximum
      to.write(from.read) until from.eof?
    end
  end

  def self.instant_copy_stream!
    IO.singleton_class.prepend(IOExtension)
  end
end
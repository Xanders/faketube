class VideoSerializer < ActiveModel::Serializer
  attributes :id, :url, :thumbnail, :time, :size

  def id
    "sa#{object.id}"
  end

  def url
    "#{ENV['STATIC_HOST']}#{object.processed.url}"
  end

  def thumbnail
    "#{ENV['STATIC_HOST']}#{object.thumbnail.url}"
  end

  def size
    object.processed_file_size
  end
end
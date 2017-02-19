# frozen_string_literal: true

module YtVideoToJson
  def as_json(*options)
    { id: "yt#{id}", url: "https://www.youtube.com/watch?v=#{id}", title: title, thumbnail: thumbnail_url, time: duration, size: file_size }
  end
end
Yt::Models::Video.prepend(YtVideoToJson)

module YtVideosToJson
  def as_json(*options)
    map { |video| video.as_json(*options) }
  end
end
Yt::Collections::Videos.prepend(YtVideosToJson)

# Public helpers

def good_title?(title)
  title.kind_of?(String) && title.size <= 100 && !title.blank?
end

def yt_account
  $account ||= Yt::Account.new(refresh_token: ENV['YT_REFRESH_TOKEN'])
end

def all_videos
  yt_account.videos
end

def find_video(id)
  yt_account.videos.find { |video| video.id == id }
end

def upload_video(*arguments)
  yt_account.upload_video(*arguments).tap do
    $account = nil # Because of caching problem
    all_videos # To process YouTube authentication
  end
end

all_videos # To process YouTube authentication before serving requests
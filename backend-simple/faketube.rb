# frozen_string_literal: true

require 'bundler'
Bundler.require
require_relative './youtube.rb'

before do
  headers 'Access-Control-Allow-Origin' => '*'
end

after do
  content_type :json if body.present?
end

get '/' do
  all_videos.to_json
end

post '/' do
  file, title = params[:file], params[:title]
  return 400 unless file.kind_of?(Hash) && file[:tempfile].kind_of?(Tempfile) && good_title?(title)
  upload_video(file[:tempfile].path, title: title, privacy_status: :unlisted).to_json
end

get '/yt:id' do
  find_video(params[:id])&.to_json || 404
end

patch '/yt:id' do
  title = params[:title]
  return 400 unless good_title?(title)
  video = find_video(params[:id]) or return 404
  video.update(title: title, category_id: video.category_id) # Need category_id due to bug in yt gem
  200
end

options '*' do
  headers 'Access-Control-Allow-Methods' => 'HEAD,GET,PUT,PATCH,POST,DELETE,OPTIONS'
  headers 'Access-Control-Allow-Headers' => 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  200
end
class VideosController < ApplicationController
  before_action :find_video, only: [:show, :update]
  before_action :check_title, only: [:create, :update]
  before_action :check_file, only: :create

  def index
    render json: Video.all
  end

  def show
    render json: @video
  end

  def create
    path = "tmp/video_processing/#{SecureRandom.uuid}"
    FileUtils.mv(params[:file].path, path)
    VideoProcessingJob.perform_later(path: path, watermark: params[:title])
    render json: { processing: true }
  end

  def update
    VideoProcessingJob.perform_later(id: @video.id, watermark: params[:title])
    render json: { processing: true }
  end

  private

  def find_video
    @video = Video.find_by_id(params[:id]) or head :not_found
  end

  def check_title
    title = params[:title]
    head :bad_request if title.blank? || !title.kind_of?(String) || title.size > 100
  end

  def check_file
    head :bad_request unless params[:file].kind_of?(ActionDispatch::Http::UploadedFile)
  end
end
class Video < ApplicationRecord
  has_attached_file :original
  has_attached_file :processed
  has_attached_file :thumbnail

  # All files will processed by job, so we don't need the validations
  do_not_validate_attachment_file_type :original, :processed, :thumbnail
end
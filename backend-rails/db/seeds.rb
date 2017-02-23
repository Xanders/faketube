# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

unless Rails.env.production?
  original = File.open(Rails.root.join('test/fixtures/files/test.wmv'))
  Video.create!(original: original)
end
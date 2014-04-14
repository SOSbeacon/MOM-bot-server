FactoryGirl.define do
  factory :photo_file do
    message :message

    file File.open(File.join(Rails.root, '/spec/fixtures/photo_files/photo.jpg'))
  end
end
class AddPhotoProfileToResumes < ActiveRecord::Migration[8.1]
  def change
    add_reference :resumes, :photo_profile, null: true, foreign_key: true
  end
end

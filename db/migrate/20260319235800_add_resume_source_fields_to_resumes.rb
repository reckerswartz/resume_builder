class AddResumeSourceFieldsToResumes < ActiveRecord::Migration[8.0]
  def change
    add_column :resumes, :source_mode, :string, null: false, default: "scratch"
    add_column :resumes, :source_text, :text
  end
end

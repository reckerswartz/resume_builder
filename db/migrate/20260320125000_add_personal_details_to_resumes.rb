class AddPersonalDetailsToResumes < ActiveRecord::Migration[8.1]
  def change
    add_column :resumes, :personal_details, :jsonb, default: {}, null: false
  end
end

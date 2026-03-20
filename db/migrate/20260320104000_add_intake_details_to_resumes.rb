class AddIntakeDetailsToResumes < ActiveRecord::Migration[8.1]
  def change
    add_column :resumes, :intake_details, :jsonb, null: false, default: {}
  end
end

class CreateResumes < ActiveRecord::Migration[8.1]
  def change
    create_table :resumes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true
      t.string :title, null: false
      t.string :headline
      t.string :slug, null: false
      t.jsonb :contact_details, null: false, default: {}
      t.jsonb :settings, null: false, default: {}
      t.text :summary, null: false, default: ""

      t.timestamps
    end

    add_index :resumes, %i[ user_id slug ], unique: true
  end
end

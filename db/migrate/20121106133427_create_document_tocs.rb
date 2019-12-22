class CreateDocumentTocs < ActiveRecord::Migration[6.0]
  def change
    create_table :document_tocs do |t|
      t.integer :parent_id
      t.integer :document_file_id
      t.integer :level
      t.string :title

      t.timestamps
    end
  end
end

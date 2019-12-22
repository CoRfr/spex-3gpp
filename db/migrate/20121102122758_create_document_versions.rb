class CreateDocumentVersions < ActiveRecord::Migration[6.0]
  def change
    create_table :document_versions do |t|
      t.integer :major
      t.integer :technical
      t.integer :editorial

      t.timestamps
    end
  end
end

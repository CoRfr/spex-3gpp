class CreateDocumentFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :document_files do |t|

      t.timestamps
    end
  end
end

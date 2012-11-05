class CreateDocumentFiles < ActiveRecord::Migration
  def change
    create_table :document_files do |t|

      t.timestamps
    end
  end
end

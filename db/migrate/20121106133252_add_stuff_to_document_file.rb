class AddStuffToDocumentFile < ActiveRecord::Migration[6.0]
  def change
    add_column :document_files, :nb_pages, :integer
  end
end

class AddStuffToDocumentFile < ActiveRecord::Migration
  def change
    add_column :document_files, :nb_pages, :integer
  end
end

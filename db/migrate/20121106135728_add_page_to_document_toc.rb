class AddPageToDocumentToc < ActiveRecord::Migration
  def change
    add_column :document_tocs, :page, :integer
  end
end

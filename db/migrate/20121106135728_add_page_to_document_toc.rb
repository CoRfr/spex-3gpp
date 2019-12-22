class AddPageToDocumentToc < ActiveRecord::Migration[6.0]
  def change
    add_column :document_tocs, :page, :integer
  end
end

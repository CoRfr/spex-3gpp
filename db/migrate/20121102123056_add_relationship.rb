class AddRelationship < ActiveRecord::Migration[6.0]
  def change
  	# belongs_to :document
  	add_column :document_versions, :document_id, :integer
  	add_index :document_versions, :document_id

  	# belongs_to :release
  	add_column :document_versions, :release_id, :integer
  	add_index :document_versions, :release_id

  	# belongs_to :document_version  	
  	add_column :document_files, :document_version_id, :integer
  	add_index :document_files, :document_version_id
  end
end

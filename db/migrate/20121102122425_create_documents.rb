class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name
      t.string :title
      t.integer :spec_serie_id
      t.integer :spec_number
      t.integer :spec_part

      t.timestamps
    end
  end
end

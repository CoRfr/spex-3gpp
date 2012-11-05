class CreateSpecSeries < ActiveRecord::Migration
  def change
    create_table :spec_series do |t|
      t.integer :index
      t.integer :spec_scope_id
      t.string :subject

      t.timestamps
    end
  end
end

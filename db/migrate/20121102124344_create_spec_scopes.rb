class CreateSpecScopes < ActiveRecord::Migration
  def change
    create_table :spec_scopes do |t|
      t.string :scope

      t.timestamps
    end
  end
end

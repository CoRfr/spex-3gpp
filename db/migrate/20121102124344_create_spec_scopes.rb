class CreateSpecScopes < ActiveRecord::Migration[6.0]
  def change
    create_table :spec_scopes do |t|
      t.string :scope

      t.timestamps
    end
  end
end

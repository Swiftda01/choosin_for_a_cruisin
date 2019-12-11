class CreateCruises < ActiveRecord::Migration[5.2]
  def change
    create_table :cruises do |t|
      t.references :line, foreign_key: true
      t.string :code
      t.date :start
      t.integer :days
      t.integer :price
      t.string :cabin_type

      t.timestamps
    end
  end
end

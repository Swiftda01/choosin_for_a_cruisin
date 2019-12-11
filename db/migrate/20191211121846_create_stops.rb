class CreateStops < ActiveRecord::Migration[5.2]
  def change
    create_table :stops do |t|
      t.references :cruise, foreign_key: true
      t.references :port, foreign_key: true
      t.datetime :d_from
      t.datetime :d_to

      t.timestamps
    end
  end
end

class CreatePorts < ActiveRecord::Migration[5.2]
  def change
    create_table :ports do |t|
      t.string :code
      t.string :name
      t.float :lat
      t.float :lng

      t.timestamps
    end
  end
end

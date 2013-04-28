class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :from_id, :null => false
      t.integer :to_id, :null => false
      t.float :amount, :null => false
      t.string :thing, :null => false
      t.timestamps
    end
  end
end

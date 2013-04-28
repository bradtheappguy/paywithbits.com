class Addudidtophonenumber < ActiveRecord::Migration
  def up
    add_column :phone_numbers, :uuid, :string
  end

  def down
     remove_column :phone_numbers, :uuid, :string
  end
end

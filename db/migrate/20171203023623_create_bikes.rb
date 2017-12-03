class CreateBikes < ActiveRecord::Migration[5.1]
  def change
    create_table :bikes do |t|
      t.float :km_travelled, default: 0

      t.timestamps
    end
  end
end

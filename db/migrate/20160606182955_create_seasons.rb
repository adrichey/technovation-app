class CreateSeasons < ActiveRecord::Migration
  def change
    create_table :seasons do |t|
      t.string :year, null: false
      t.datetime :starts_at, null: false

      t.timestamps null: false
    end
  end
end

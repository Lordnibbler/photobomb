class CreatePhotos < ActiveRecord::Migration[5.0]
  def change
    create_table :photos do |t|
      t.string :title
      t.text :description
      t.text :url_thumb
      t.text :url_small
      t.text :url_medium
      t.text :url_large
      t.text :url_original
      t.string :external_service_id
      t.string :external_service_name
      t.datetime :external_date
    end
    add_index :photos, :external_service_id
    add_index :photos, :external_service_name
    add_index :photos, :external_date
  end
end

class Photo < ActiveRecord::Base
  validates :external_service_id, uniqueness: { scope: :external_service_name }
end

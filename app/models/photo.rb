class Photo < ActiveRecord::Base
  validates :external_service_id, uniqueness: { scope: :external_service_name }

  scope :from_external_service, -> (external_service_name) do
    where(external_service_name: external_service_name)
  end

  def self.newest_from_external_service(external_service_name)
    from_external_service(external_service_name).newest
  end

  def self.newest
    order(external_date: :desc).limit(1).first
  end
end

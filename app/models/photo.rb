class Photo < ActiveRecord::Base
  validates :external_service_id, uniqueness: { scope: :external_service_name }

  scope :newest, -> do
    order(external_date: :desc).limit(1).first
  end

  scope :from_external_service, -> (external_service_name) do
    where(external_service_name: external_service_name)
  end

  scope :newest_from_external_service, -> (external_service_name) do
    from_external_service(external_service_name).newest
  end
end

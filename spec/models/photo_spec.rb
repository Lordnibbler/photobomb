require 'rails_helper'

describe Photo do
  context 'validations' do
    describe 'external_service_id' do
      let(:external_service_id) { '123' }
      let!(:photo) do
        FG.create(
          :photo,
          :flickr,
          external_service_id: external_service_id
        )
      end

      context 'when external_service_id is same, but external_service_name is different' do
        let(:photo2) do
          FG.create(
            :photo,
            :instagram,
            external_service_id: external_service_id
          )
        end

        it 'passes' do
          expect { photo2 }.not_to raise_error
        end
      end

      context 'when external_service_id and external_service_name are same' do
        let(:photo2) do
          FG.create(
            :photo,
            :flickr,
            external_service_id: external_service_id
          )
        end

        it 'fails' do
          expect { photo2 }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end

  context 'scopes' do
    describe '.newest_from_external_service' do
      let!(:old_photo) { FG.create(:photo, external_date: 2.days.ago) }
      let!(:new_photo) { FG.create(:photo, external_date: 1.hour.ago) }
      let(:external_service_name) { old_photo.external_service_name }

      it 'returns the newest photo from the specified external service' do
        expect(
          described_class.newest_from_external_service(external_service_name)
        ).to eq(new_photo)
      end
    end
  end
end

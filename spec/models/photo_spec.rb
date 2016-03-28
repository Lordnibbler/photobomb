require 'rails_helper'

describe Photo do
  context 'validations' do
    describe 'external_service_id' do
      let!(:photo) { FG.create(:photo, :flickr) }

      context 'when external_service_id is same, but external_service_name is different' do
        let(:photo2) { FG.create(:photo, :instagram) }

        it 'passes' do
          expect { photo2 }.not_to raise_error
        end
      end

      context 'when external_service_id and external_service_name are same' do
        let(:photo2) { FG.create(:photo, :flickr) }

        it 'fails' do
          expect { photo2 }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end

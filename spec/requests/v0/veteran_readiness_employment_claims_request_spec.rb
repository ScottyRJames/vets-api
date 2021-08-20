# frozen_string_literal: true

require 'rails_helper'

describe 'v0/veteran_readiness_employment_claims' do
  let(:loa3_user) { create(:evss_user) }

  let(:test_form) do
    build(:veteran_readiness_employment_claim)
  end

  context 'user logged in' do
    before { sign_in_as(loa3_user) }

    describe 'POST' do
      it 'returns a 200 when VBMS is down for maintenance' do
        allow_any_instance_of(ClaimsApi::VBMSUploader).to receive(:upload!).and_raise(VBMS::DownForMaintenance)
        form_params = { veteran_readiness_employment_claim: { form: test_form.form } }
        post('/v0/veteran_readiness_employment_claims.json', params: form_params)
        expect(response).to have_http_status :ok
      end
    end
  end
end

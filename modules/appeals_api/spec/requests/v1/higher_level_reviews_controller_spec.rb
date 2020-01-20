# frozen_string_literal: true

require 'rails_helper'

describe AppealsApi::V1::DecisionReview::HigherLevelReviewsController, type: :request do
  describe '#index' do
    it 'show a HLR from Caseflow successfully' do
      VCR.use_cassette('appeals/higher_level_reviews_show') do
        get('/services/appeals/v1/decision_review/higher_level_reviews/97bca3d5-3524-4e5d-81ea-92753892a59c')
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['data']).not_to be nil
      end
    end
  end
end

# frozen_string_literal: true

require 'caseflow/service'
require 'decision_review_v1/service'

class AppealsBaseControllerV1 < ApplicationController
  include ActionController::Serialization
  include FailedRequestLoggable
  before_action { authorize :appeals, :access? }

  private

  def decision_review_service
    DecisionReviewV1::Service.new
  end

  def request_body_hash
    @request_body_hash ||= get_hash_from_request_body
  end

  def get_hash_from_request_body
    # testing string b/c NullIO class doesn't always exist
    raise request_body_is_not_a_hash_error if request.body.class.name == 'Puma::NullIO'

    body = JSON.parse request.body.string
    raise request_body_is_not_a_hash_error unless body.is_a?(Hash)

    body
  rescue JSON::ParserError
    raise request_body_is_not_a_hash_error
  end

  def request_body_is_not_a_hash_error
    DecisionReviewV1::ServiceException.new key: 'DR_REQUEST_BODY_IS_NOT_A_HASH'
  end

  def request_body_debug_data
    {
      request_body_class_name: request.try(:body).class.name,
      request_body_string: request.try(:body).try(:string)
    }
  end
end

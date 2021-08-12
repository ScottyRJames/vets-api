# frozen_string_literal: true

require_dependency 'event_stream/application_controller'
# require 'okta/directory_service'

module EventStream
  module V0
    class EventsController < ApplicationController
      skip_before_action(:authenticate)
      
      def create
        render json: { id: SecureRandom.uuid }, status: :created
      end
    end
  end
end

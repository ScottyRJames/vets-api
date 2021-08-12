# frozen_string_literal: true

require_dependency 'event_stream/application_controller'
require 'event_stream/event_producer'

module EventStream
  module V0
    class EventsController < ApplicationController
      skip_before_action(:authenticate)

      def create
        event_id = event_producer.add(params[:event].as_json)
        render json: { id: event_id }, status: :created
      end

      private

      def event_producer
        EventStream::EventProducer.new
      end
    end
  end
end

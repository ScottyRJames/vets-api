# frozen_string_literal: true

require_relative '../configuration'

module VAOS
  module V1
    class FHIRConfiguration < VAOS::Configuration
      def base_path
        "#{Settings.va_mobile.url}/vsp/v1/"
      end

      def service_name
        'VAOS::FHIR'
      end

      def connection
        Faraday.new(base_path, headers: base_request_headers, request: request_options) do |conn|
          conn.use :breakers

          if ENV['VAOS_DEBUG'] && !Rails.env.production?
            conn.request(:curl, ::Logger.new(STDOUT), :warn)
            conn.response(:logger, ::Logger.new(STDOUT), bodies: true)
          end

          conn.response :betamocks if mock_enabled?

          conn.adapter Faraday.default_adapter
        end
      end
    end
  end
end

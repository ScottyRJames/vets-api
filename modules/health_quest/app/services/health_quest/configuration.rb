# frozen_string_literal: true

module HealthQuest
  class Configuration < Common::Client::Configuration::REST
    def base_path
      Settings.hqva_mobile.url
    end

    def service_name
      'HEALTHQUEST'
    end

    def connection
      Faraday.new(base_path, headers: base_request_headers, request: request_options) do |faraday|
        faraday.use :breakers
        faraday.use Faraday::Response::RaiseError

        faraday.request :json

        faraday.response :betamocks if mock_enabled?
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter Faraday.default_adapter
      end
    end

    def mock_enabled?
      [true, 'true'].include?(Settings.va_mobile.mock)
    end
  end
end

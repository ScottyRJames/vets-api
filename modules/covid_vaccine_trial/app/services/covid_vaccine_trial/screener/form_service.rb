# frozen_string_literal: true

require 'json_schemer'

module CovidVaccineTrial
  module Screener
    class FormService
      SCHEMA = 'COVID-VACCINE-TRIAL'

      def valid_submission?(json)
        schema.valid?(json)
      end

      def submission_errors(json)
        schema.validate(json).map do |e|
          if e['data_pointer'].blank?
            {
              type: 'invalid',
              detail: e['data']
            }
          else
            {
              type: 'invalid',
              detail: e['data_pointer']
            }
          end
        end
      end

      private

      def schema
        @schema ||= JSONSchemer.schema(schema_data)
      end

      # production branch becomes universal after vets-json-schema update
      def schema_data
        if Rails.env.production?
          JSON.parse(VetsJsonSchema::SCHEMAS[SCHEMA])
        else
          dir = Rails.root.join('modules', 'covid_vaccine_trial', 'config', 'schemas')
          JSON.parse(File.read(File.join(dir, 'covid-vaccine-trial-schema.json')))
        end
      end
    end
  end
end
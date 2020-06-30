# frozen_string_literal: true

require_relative 'base'
require_relative 'attachment'

module CARMA
  module Models
    class Attachments < Base
      attr_reader   :response,
                    :has_errors

      attr_accessor :all,
                    :carma_case_id,
                    :veteran_first_name,
                    :veteran_last_name

      def initialize(carma_case_id, veteran_first_name, veteran_last_name)
        @carma_case_id        = carma_case_id
        @veteran_first_name   = veteran_first_name
        @veteran_last_name    = veteran_last_name
        @all                  = []
      end

      def add(document_type, local_path)
        all << CARMA::Models::Attachment.new(
          carma_case_id: carma_case_id,
          document_type: document_type,
          file_path: local_path,
          veteran_name: {
            first: veteran_first_name,
            last: veteran_last_name
          }
        )

        self
      end

      def to_request_payload
        raise 'must have at least one attachment' if all.empty?

        {
          'records' => all.map(&:to_request_payload)
        }
      end

      def submit!
        return response if response

        @response = if Flipper.enabled?(:stub_carma_responses)
                      client.upload_attachments_stub(to_request_payload)
                    else
                      client.upload_attachments(to_request_payload)
                    end

        @has_errors = @response['hasErrors']

        @all.each do |attachment|
          matching_result = @response['results'].find do |upload_result|
            upload_result['referenceId'] == attachment.reference_id
          end

          attachment.id = matching_result['id']
        end

        self
      end

      private

      def client
        @client ||= CARMA::Client::Client.new
      end
    end
  end
end

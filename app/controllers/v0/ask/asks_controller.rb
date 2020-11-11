# frozen_string_literal: true

module V0
  module Ask
    class AsksController < ApplicationController
      skip_before_action :authenticate, only: :create
      skip_before_action :verify_authenticity_token

      def create
        return not_implemented unless Flipper.enabled?(:get_help_ask_form)

        claim = SavedClaim::Ask.new(form: form_submission)

        service = OracleRPAService.new(claim)

        confirmation_number = service.submit_form

        # validate!(claim)

        render json: {
          'confirmationNumber': confirmation_number,
          'dateSubmitted': DateTime.now.utc.strftime('%m-%d-%Y')
        }, status: :created
      end

      private

      def not_implemented
        render nothing: true, status: :not_implemented, as: :json
      end

      def form_submission
        params.require(:inquiry).require(:form)
      rescue
        raise
      end

      def validate!(claim)
        raise Common::Exceptions::ValidationErrors, claim unless claim.valid?
      end
    end
  end
end

# frozen_string_literal: true

require 'va_profile/contact_information/service'

module V0
  module Profile
    class TransactionsController < ApplicationController
      include Vet360::Transactionable
      include Vet360::Writeable

      before_action { authorize :vet360, :access? }
      after_action :invalidate_cache

      def status
        check_transaction_status!
      end

      def statuses
        transactions = AsyncTransaction::VAProfile::Base.refresh_transaction_statuses(@current_user, service)

        render json: transactions, each_serializer: AsyncTransaction::BaseSerializer
      end

      private

      def transaction_params
        params.permit :transaction_id
      end

      def service
        VAProfile::ContactInformation::Service.new(@current_user)
      end
    end
  end
end

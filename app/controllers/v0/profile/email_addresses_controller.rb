# frozen_string_literal: true

module V0
  module Profile
    class EmailAddressesController < ApplicationController
      include Vet360::Writeable

      before_action { authorize :vet360, :access? }
      after_action :invalidate_cache

      def create
        write_to_vet360_and_render_transaction!(
          'email',
          email_address_params
        )
      end

      def update
        write_to_vet360_and_render_transaction!(
          'email',
          email_address_params,
          http_verb: 'put'
        )
      end

      def destroy
        write_to_vet360_and_render_transaction!(
          'email',
          add_effective_end_date(email_address_params),
          http_verb: 'put'
        )
      end

      private

      def email_address_params
        params.permit(
          :email_address,
          :id,
          :transaction_id
        )
      end
    end
  end
end

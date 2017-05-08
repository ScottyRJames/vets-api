# frozen_string_literal: true
require 'common/client/base'
require 'common/client/concerns/mhv_session_based_client'
require 'rx/configuration'
require 'rx/client_session'
require 'active_support/core_ext/hash/slice'

module Rx
  # Core class responsible for api interface operations
  class Client < Common::Client::Base
    include Common::Client::MHVSessionBasedClient

    configuration Rx::Configuration
    client_session Rx::ClientSession

    def get_active_rxs
      json = perform(:get, 'prescription/getactiverx', nil, token_headers).body
      Common::Collection.new(::Prescription, json)
    end

    def get_history_rxs
      json = perform(:get, 'prescription/gethistoryrx', nil, token_headers).body
      Common::Collection.new(::Prescription, json)
    end

    def get_rx(id)
      collection = get_history_rxs
      collection.find_first_by('prescription_id' => { 'eq' => id })
    end

    def get_tracking_rx(id)
      json = perform(:get, "prescription/rxtracking/#{id}", nil, token_headers).body
      data = json[:data].first.merge(prescription_id: id)
      Tracking.new(json.merge(data: data))
    end

    def get_tracking_history_rx(id)
      json = perform(:get, "prescription/rxtracking/#{id}", nil, token_headers).body
      tracking_history = json[:data].map { |t| Hash[t].merge(prescription_id: id) }
      Common::Collection.new(::Tracking, json.merge(data: tracking_history))
    end

    def post_refill_rx(id)
      perform(:post, "prescription/rxrefill/#{id}", nil, token_headers)
    end

    # TODO: Might need error handeling around this.
    def get_preferences
      response = {}
      config.parallel_connection.in_parallel do
        response.merge!(get_notification_email_address)
        response.merge!(rx_flag: get_rx_preference_flag[:flag])
      end
      { data: response, errors: {}, metadata: {} }
    end

    # TODO: Might need error handling around this
    def post_preferences(params)
      config.parallel_connection.in_parallel do
        post_notification_email_address(params.slice(:email_address))
        post_rx_preference_flag(params.slice(:rx_flag))
      end
      get_preferences
    end

    private

    # NOTE: After June 17, MHV will roll out an improvement that collapses these
    # into a single endpoint so that you do not need to make multiple distinct
    # requests. They will keep these around for some time and eventually deprecate.

    # Current Email Account that receives notifications
    def get_notification_email_address
      config.parallel_connection.get('preferences/email', nil, token_headers).body
    end

    # Current Rx preference setting
    def get_rx_preference_flag
      config.parallel_connection.get('preferences/rx', nil, token_headers).body
    end

    # Change Email Account that receives notifications
    def post_notification_email_address(params)
      config.parallel_connection.post('preferences/email', params, token_headers)
    end

    # Change Rx preference setting
    def post_rx_preference_flag(params)
      params = { flag: params[:rx_flag] }
      config.parallel_connection.post('preferences/rx', params, token_headers)
    end
  end
end

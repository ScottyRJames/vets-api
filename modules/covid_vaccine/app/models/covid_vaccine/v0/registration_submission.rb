# frozen_string_literal: true

require 'database/key_rotation'
require 'json_marshal/marshaller'

module CovidVaccine
  module V0
    class RegistrationSubmission < ApplicationRecord
      include Database::KeyRotation
      scope :for_user, ->(user) { where(account_id: user.account_uuid).order(created_at: :asc) }

      after_initialize do |reg|
        reg.form_data&.symbolize_keys!
      end

      attr_encrypted :form_data, key: proc { |r|
                                        r.encryption_key(:form_data)
                                      }, marshal: true, marshaler: JsonMarshal::Marshaller
      attr_encrypted :raw_form_data, key: proc { |r|
                                            r.encryption_key(:raw_form_data)
                                          }, marshal: true, marshaler: JsonMarshal::Marshaller
    end
  end
end

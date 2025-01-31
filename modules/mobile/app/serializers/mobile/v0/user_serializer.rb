# frozen_string_literal: true

require 'fast_jsonapi'

module Mobile
  module V0
    class UserSerializer
      include FastJsonapi::ObjectSerializer

      ADDRESS_KEYS = %i[
        id
        address_line1
        address_line2
        address_line3
        address_pou
        address_type
        city
        country_code
        country_code_iso3
        international_postal_code
        province
        state_code
        zip_code
        zip_code_suffix
      ].freeze

      EMAIL_KEYS = %i[
        id
        email_address
      ].freeze

      PHONE_KEYS = %i[
        id
        area_code
        country_code
        extension
        phone_number
        phone_type
      ].freeze

      SERVICE_DICTIONARY = {
        appeals: :appeals,
        appointments: :vaos,
        claims: :evss,
        directDepositBenefits: %i[evss ppiu],
        lettersAndDocuments: :evss,
        militaryServiceHistory: :emis,
        userProfileUpdate: :vet360,
        secureMessaging: :mhv_messaging
      }.freeze

      def self.filter_keys(value, keys)
        value&.to_h&.slice(*keys)
      end

      attribute :profile do |user|
        {
          first_name: user.first_name,
          middle_name: user.middle_name,
          last_name: user.last_name,
          contact_email: filter_keys(user.vet360_contact_info&.email, EMAIL_KEYS),
          signin_email: user.email,
          birth_date: user.birth_date.nil? ? nil : Date.parse(user.birth_date).iso8601,
          gender: user.gender,
          residential_address: filter_keys(user.vet360_contact_info&.residential_address, ADDRESS_KEYS),
          mailing_address: filter_keys(user.vet360_contact_info&.mailing_address, ADDRESS_KEYS),
          home_phone_number: filter_keys(user.vet360_contact_info&.home_phone, PHONE_KEYS),
          mobile_phone_number: filter_keys(user.vet360_contact_info&.mobile_phone, PHONE_KEYS),
          work_phone_number: filter_keys(user.vet360_contact_info&.work_phone, PHONE_KEYS),
          fax_number: filter_keys(user.vet360_contact_info&.fax_number, PHONE_KEYS)
        }
      end

      attribute :authorized_services do |user|
        SERVICE_DICTIONARY.filter { |_k, policies| authorized_for_service(policies, user) }.keys
      end

      attribute :health do |user|
        {
          facilities: user.va_treatment_facility_ids.map { |id| facility(user, id) },
          is_cerner_patient: !user.cerner_id.nil?
        }
      end

      def self.authorized_for_service(policies, user)
        [*policies].all? { |policy| user.authorize(policy, :access?) }
      end

      def self.facility(user, facility_id)
        cerner_facility_ids = user.cerner_facility_ids || []
        {
          facility_id: facility_id,
          is_cerner: cerner_facility_ids.include?(facility_id)
        }
      end
    end
  end
end

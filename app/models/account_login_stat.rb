# frozen_string_literal: true

class AccountLoginStat < ApplicationRecord
  # ['idme', 'myhealthevet', 'dslogon']
  LOGIN_TYPES = SAML::User::AUTHN_CONTEXTS.map { |_k, v| v[:sign_in][:service_name] }.uniq.freeze

  belongs_to :account, inverse_of: :login_stats
  validates :account_id, presence: true, uniqueness: true
end

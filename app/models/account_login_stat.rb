# frozen_string_literal: true

class AccountLoginStat < ApplicationRecord
  LOGIN_TYPES = %w[idme dslogon mhv].freeze

  belongs_to :account, inverse_of: :login_stats
  validates :account_id, presence: true, uniqueness: true
end

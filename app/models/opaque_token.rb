# frozen_string_literal: true

class OpaqueToken
  attr_reader :token_string

  def initialize(token_string, aud)
    @token_string = token_string
    @aud = aud
  end

  def to_s
    @token_string
  end

  def payload
    @payload
  end

  def set_payload(payload)
    @payload = payload
  end
end
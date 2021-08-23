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
    @payload['scp'] = @payload['scopes'] if @payload['scopes']
  end

  def client_credentials_token?
    false
  end

  def ssoi_token?
    false
  end

  def static?
    payload['static']
  end
end
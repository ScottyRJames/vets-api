# frozen_string_literal: true

class TokenUtil
  def self.validate_token(token)
    raise TokenUtil.error_klass('Invalid issuer') unless valid_issuer?(token)
    raise TokenUtil.error_klass('Invalid audience') unless valid_audience?(token)
  end

  def self.valid_audience?(token)
    if token.aud.nil?
      token.payload['aud'] == Settings.oidc.isolated_audience.default
    else
      # Temorarily accept the default audience or the API specificed audience
      [Settings.oidc.isolated_audience.default, *token.aud].include?(payload['aud'])
    end
  end

  def self.valid_issuer?(token)
    iss = token.payload['iss'] if token.payload
    !iss.nil? && iss.match?(%r{^#{Regexp.escape(Settings.oidc.issuer_prefix)}/\w+$})
  rescue e
    raise error_klass(e.message)
  end

  def self.error_klass(error_detail_string)
    # Errors from the jwt gem (and other dependencies) are reraised with
    # this class so we can exclude them from Sentry without needing to know
    # all the classes used by our dependencies.
    Common::Exceptions::TokenValidationError.new(detail: error_detail_string)
  end
end

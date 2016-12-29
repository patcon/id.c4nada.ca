require 'base64'
require 'feature_management'
require 'omniauth'

def private_key_enc_content
  file = File.join(Rails.root, 'keys', 'saml.key.enc')
  if File.exist?(file)
    cipher_content = File.read(file)
  elsif Figaro.env.IDP_CERT_PRIV_ENC_BASE64?
    cipher_content = Base64.decode64(Figaro.env.IDP_CERT_PRIV_ENC_BASE64)
  else
    raise
  end

  cipher_content
end

def idp_cert_content
  file = File.join(Rails.root, 'certs', 'saml.crt')
  if File.exist?(file)
    cipher_content = File.read(file)
  elsif Figaro.env.IDP_CERT_PUB_BASE64?
    cipher_content = Base64.decode64(Figaro.env.IDP_CERT_PUB_BASE64)
  else
    raise
  end

  cipher_content
end

DEFAULT_OPTIONS = {
  idp_sso_target_url: Figaro.env.idp_sso_target_url,
  issuer: "https://#{Figaro.env.domain_name}/users/auth/saml",
  single_signon_service_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
  idp_cert: idp_cert_content,
  idp_cert_fingerprint_algorithm: 'http://www.w3.org/2001/04/xmlenc#sha256',
  name_identifier_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS,
  allowed_clock_drift: 60.seconds,
  certificate: File.read("#{Rails.root}/certs/sp/saml_test_sp.crt"),
  private_key: OpenSSL::PKey::RSA.new(
    private_key_enc_content,
    Figaro.env.saml_passphrase
  ).to_pem,
  assertion_consumer_service_url: "https://#{Figaro.env.domain_name}/users/auth/saml/callback",
  assertion_consumer_service_binding: 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
  authn_context: 'http://idmanagement.gov/ns/assurance/loa/2',
  compress_request: false,
  double_quote_xml_attribute_values: true,
  security: {
    authn_requests_signed: true,
    embed_sign: true,
    digest_method: 'http://www.w3.org/2001/04/xmlenc#sha256',
    signature_method: 'http://www.w3.org/2001/04/xmldsig-more#rsa-sha256'
  }
}.freeze
options = DEFAULT_OPTIONS

if Rails.env == 'development'
  options = DEFAULT_OPTIONS.merge(
    issuer: "http://#{Figaro.env.domain_name}/users/auth/saml",
    assertion_consumer_service_url: "http://#{Figaro.env.domain_name}/users/auth/saml/callback",
    allowed_clock_drift: 5.minutes
  )
end

if FeatureManagement.allow_third_party_auth?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :saml, options
  end
end

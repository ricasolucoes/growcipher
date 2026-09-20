#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "json"
require "net/http"
require "openssl"
require "time"
require "uri"

class AppStoreConnectExportCompliance
  API_BASE = "https://api.appstoreconnect.apple.com"
  DEFAULT_APP_ID = "6814259887"
  DEFAULT_BUILD_NUMBER = "3001"
  DEFAULT_WAIT_SECONDS = 1_200
  DEFAULT_POLL_INTERVAL_SECONDS = 20

  def self.build_update_payload(build_id)
    {
      "data" => {
        "type" => "builds",
        "id" => build_id,
        "attributes" => {"usesNonExemptEncryption" => false}
      }
    }
  end

  def self.select_build(builds, build_number)
    builds.find do |build|
      attributes = build.fetch("attributes", {})
      attributes["version"].to_s == build_number.to_s && attributes["processingState"] == "VALID"
    end
  end

  def initialize(
    api_key_id: ENV.fetch("APPSTORE_CONNECT_API_KEY_ID"),
    issuer_id: ENV.fetch("APPSTORE_CONNECT_ISSUER_ID"),
    private_key_base64: ENV.fetch("APPSTORE_CONNECT_API_PRIVATE_KEY_BASE64"),
    app_id: ENV.fetch("IOS_APP_ID", DEFAULT_APP_ID),
    build_number: ENV.fetch("IOS_BUILD_NUMBER", DEFAULT_BUILD_NUMBER),
    wait_seconds: ENV.fetch("IOS_COMPLIANCE_WAIT_SECONDS", DEFAULT_WAIT_SECONDS.to_s).to_i,
    poll_interval_seconds: ENV.fetch("IOS_COMPLIANCE_POLL_INTERVAL_SECONDS", DEFAULT_POLL_INTERVAL_SECONDS.to_s).to_i
  )
    @api_key_id = api_key_id
    @issuer_id = issuer_id
    @private_key_base64 = private_key_base64
    @app_id = app_id
    @build_number = build_number
    @wait_seconds = wait_seconds
    @poll_interval_seconds = poll_interval_seconds
  end

  def run
    build = wait_for_valid_build
    build_id = build.fetch("id")
    current_value = build.dig("attributes", "usesNonExemptEncryption")

    if current_value == false
      puts "Build #{build_number} já declara usesNonExemptEncryption=false."
    else
      puts "Declarando usesNonExemptEncryption=false no build #{build_number}."
      request(:patch, "/v1/builds/#{build_id}", body: self.class.build_update_payload(build_id))
    end

    verified = fetch_build(build_id)
    verified_value = verified.dig("attributes", "usesNonExemptEncryption")
    unless verified_value == false
      raise "A Apple não confirmou a declaração de criptografia do build #{build_number}."
    end

    puts "Conformidade de criptografia confirmada para o build #{build_number} (#{build_id})."
  end

  private

  attr_reader :build_number

  def wait_for_valid_build
    deadline = Time.now + @wait_seconds

    loop do
      builds = list_builds
      build = self.class.select_build(builds, @build_number)
      return build if build

      matching_build = builds.find do |candidate|
        candidate.dig("attributes", "version").to_s == @build_number.to_s
      end
      processing_state = matching_build&.dig("attributes", "processingState") || "não encontrado"

      if Time.now >= deadline
        raise "Build #{@build_number} não ficou VALID dentro de #{@wait_seconds}s (estado: #{processing_state})."
      end

      puts "Aguardando o build #{@build_number} ficar VALID (estado atual: #{processing_state})."
      sleep [@poll_interval_seconds, (deadline - Time.now).ceil].min
    end
  end

  def list_builds
    response = request(
      :get,
      "/v1/apps/#{@app_id}/builds",
      query: {
        "filter[version]" => @build_number,
        "limit" => "200",
        "fields[builds]" => "version,processingState,usesNonExemptEncryption"
      }
    )
    JSON.parse(response.body).fetch("data")
  end

  def fetch_build(build_id)
    response = request(
      :get,
      "/v1/builds/#{build_id}",
      query: {"fields[builds]" => "version,processingState,usesNonExemptEncryption"}
    )
    JSON.parse(response.body).fetch("data")
  end

  def request(method, path, query: nil, body: nil)
    uri = URI.join(API_BASE, path)
    uri.query = URI.encode_www_form(query) if query
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 90

    request_class = {get: Net::HTTP::Get, patch: Net::HTTP::Patch}.fetch(method)
    http_request = request_class.new(uri)
    http_request["Authorization"] = "Bearer #{jwt}"
    http_request["Content-Type"] = "application/json" if body
    http_request.body = JSON.generate(body) if body

    response = http.request(http_request)
    return response if response.is_a?(Net::HTTPSuccess) || response.code == "204"

    details = begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end
    raise "App Store Connect API #{method.to_s.upcase} #{path} falhou (#{response.code}): #{details}"
  end

  def jwt
    header = {"alg" => "ES256", "kid" => @api_key_id, "typ" => "JWT"}
    now = Time.now.to_i
    payload = {"iss" => @issuer_id, "iat" => now - 60, "exp" => now + 600, "aud" => "appstoreconnect-v1"}
    encoded_header = base64url(JSON.generate(header))
    encoded_payload = base64url(JSON.generate(payload))
    signing_input = "#{encoded_header}.#{encoded_payload}"

    key = OpenSSL::PKey::EC.new(Base64.strict_decode64(@private_key_base64.gsub(/\s+/, "")))
    der_signature = key.dsa_sign_asn1(OpenSSL::Digest::SHA256.digest(signing_input))
    asn1_signature = OpenSSL::ASN1.decode(der_signature)
    r = asn1_signature.value[0].value.to_s(2).rjust(32, "\x00")[-32, 32]
    s = asn1_signature.value[1].value.to_s(2).rjust(32, "\x00")[-32, 32]

    "#{signing_input}.#{base64url(r + s)}"
  end

  def base64url(value)
    Base64.urlsafe_encode64(value, padding: false)
  end
end

if $PROGRAM_NAME == __FILE__
  AppStoreConnectExportCompliance.new.run
end

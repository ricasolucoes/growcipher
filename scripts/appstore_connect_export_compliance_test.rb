#!/usr/bin/env ruby

require "minitest/autorun"
require_relative "appstore_connect_export_compliance"

class AppStoreConnectExportComplianceTest < Minitest::Test
  def test_build_update_payload_declares_no_non_exempt_encryption
    assert_equal(
      {
        "data" => {
          "type" => "builds",
          "id" => "build-3001",
          "attributes" => {"usesNonExemptEncryption" => false}
        }
      },
      AppStoreConnectExportCompliance.build_update_payload("build-3001")
    )
  end

  def test_select_build_requires_the_requested_build_number_and_valid_processing_state
    builds = [
      {"id" => "old", "attributes" => {"version" => "3000", "processingState" => "VALID"}},
      {"id" => "processing", "attributes" => {"version" => "3001", "processingState" => "PROCESSING"}},
      {"id" => "current", "attributes" => {"version" => "3001", "processingState" => "VALID"}}
    ]

    assert_equal(
      "current",
      AppStoreConnectExportCompliance.select_build(builds, "3001")["id"]
    )
  end
end

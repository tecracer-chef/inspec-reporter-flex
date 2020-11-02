require_relative "mixin/erb_helpers"
require_relative "mixin/file_resolver"

require "erb" unless defined? ERB

module InspecPlugins::FlexReporter
  class Reporter < Inspec::Reporters::Json
    include InspecPlugins::FlexReporter::ErbHelpers
    include InspecPlugins::FlexReporter::FileResolver

    # Render report
    def render
      template_file = resolve_path(config["template"])
      template = ERB.new(File.read(template_file))

      # Use JSON Reporter base's `report` to have pre-processed data
      mushy_report = Hashie::Mash.new(report)

      # Eeease of use here
      platform   = mushy_report.platform
      profiles   = mushy_report.profiles
      statistics = mushy_report.statistics
      version    = mushy_report.version

      # Some pass/fail information
      test_results = profiles.map(&:controls).flatten.map(&:results).flatten.map(&:status)
      passed_tests = test_results.select { |text| text == "passed" }.count
      failed_tests = test_results.count - passed_tests
      percent_pass = 100.0 * passed_tests / test_results.count
      percent_fail = 100.0 - percent_pass

      # Detailed OS
      platform_arch = runner.backend.backend.os.arch
      platform_name = runner.backend.backend.os.title

      # Allow template-based settings
      template_config = config.fetch("template_config", {})

      # ... also can use all InSpec resources via "inspec_resource.NAME.PROPERTY"

      output(template.result(binding))
    end

    # Return Constraints.
    #
    # @return [String] Always "~> 0.0"
    def self.run_data_schema_constraints
      "~> 0.0"
    end

    private

    # Initialize configuration with defaults and Plugin config.
    #
    # @return [Hash] Configuration data after merge
    def config
      @config unless @config.nil?

      # Defaults
      @config = {
        "template" => "templates/flex.erb",
      }

      @config.merge! Inspec::Config.cached.fetch_plugin_config("inspec-reporter-flex")
    end

    # Return InSpec Runner for further inspection.
    #
    # @return [Inspec::Runner] Runner instance
    def runner
      require "binding_of_caller"

      binding.callers.find { |b| b.frame_description == "run_tests" }.receiver
    end
  end
end

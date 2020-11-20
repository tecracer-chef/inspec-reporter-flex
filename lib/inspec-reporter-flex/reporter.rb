require_relative "mixin/erb_helpers"
require_relative "mixin/file_resolver"

require "erb" unless defined? ERB

module InspecPlugins::FlexReporter
  class Reporter < Inspec::Reporters::Json
    include InspecPlugins::FlexReporter::ErbHelpers
    include InspecPlugins::FlexReporter::FileResolver

    ENV_PREFIX = "INSPEC_REPORTER_FLEX_".freeze

    attr_writer :config, :env, :inspec_config, :logger, :template_contents

    # Render report
    def render
      template = ERB.new(template_contents)

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

    # Read contents of requested template.
    #
    # @return [String] ERB Template
    # @raise [IOError]
    def template_contents
      @template_contents ||= File.read full_path(config["template_file"])
    end

    # Initialize configuration with defaults and Plugin config.
    #
    # @return [Hash] Configuration data after merge
    def config
      @config unless @config.nil?

      # Defaults
      @config = {
        "template_file" => "templates/flex.erb",
      }

      @config.merge! inspec_config.fetch_plugin_config("inspec-reporter-flex")
      @config.merge! config_environment

      logger.debug format("Configuration: %<config>s", config: @config)

      @config
    end

    # Allow (top-level) setting overrides from environment.
    #
    # @return [Hash] Configuration data from environment
    def config_environment
      env_reporter = env.select { |var, _| var.start_with?(ENV_PREFIX) }
      env_reporter.transform_keys { |key| key.delete_prefix(ENV_PREFIX).downcase }
    end

    # Return environment variables.
    #
    # @return [Hash] Mapping of environment variables
    def env
      @env ||= ENV
    end

    # Return InSpec Config object.
    #
    # @return [Inspec::Config] The InSpec config object
    def inspec_config
      @inspec_config ||= Inspec::Config.cached
    end

    # Return InSpec logger.
    #
    # @return [Inspec:Log] The Logger object
    def logger
      @logger ||= Inspec::Log
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

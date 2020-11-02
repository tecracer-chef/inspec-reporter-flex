require_relative "version"

module InspecPlugins
  module FlexReporter
    class Plugin < ::Inspec.plugin(2)
      # Internal machine name of the plugin. InSpec will use this in errors, etc.
      plugin_name :"inspec-reporter-flex"

      reporter :flex do
        require_relative "reporter"
        InspecPlugins::FlexReporter::Reporter
      end
    end
  end
end

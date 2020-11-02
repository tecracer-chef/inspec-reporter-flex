module InspecPlugins::FlexReporter
  module ErbHelpers
    # Return latest start time of the scan
    #
    # @return [DateTime] Timestamp of the last scan in the profile
    def scan_time
      DateTime.strptime(report[:profiles].last[:controls].last[:results].last[:start_time])
    end

    # Execute a remote command.
    #
    # @param [String] cmd Command to execute
    # @return [Train::Extras::CommandResult] Command result (.stdout/.stderr/.exit_status)
    def remote_command(cmd)
      runner.backend.backend.run_command(cmd)
    end

    # Retrieve remote file contents.
    #
    # @param [String] remote_file Path to the remote file
    # @return [String] Contents of the file
    def remote_file_content(remote_file)
      runner.backend.backend.file(remote_file).content
    end

    # Allow access to all InSpec resources from the report.
    #
    # @return [Inspec::Backend] The InSpec backend
    def inspec_resource
      runner.backend
    end

    # Return InSpec OS resource results.
    #
    # @return [Class] Look into documentation for properties (.arch/.family/.name/...)
    # @see https://github.com/inspec/inspec/blob/master/lib/inspec/resources/os.rb
    def os
      runner.backend.os
    end

    # Return InSpec SysInfo resource results.
    #
    # @return [Class] Look into documentation for properteis (.domain/.fqdn/.hostname/.ip_address/.model/...)
    # @see https://github.com/inspec/inspec/blob/master/lib/inspec/resources/sys_info.rb
    def sys_info
      runner.backend.sys_info
    end

    # Return if all results of a control have passed/skipped/waived.
    #
    # @param [Hash] control Data of a control run
    # @return [Boolean] If all passed checks
    def control_passed?(control)
      control[:results].any? { |result| result[:status] == "failed" }
    end

    # Map InSpec status to cleartext
    #
    # @param [String] inspec_status One of the valid InSpec result status.
    # @return [Strint] "ok"/"not ok" depending on status
    def status_to_pass(inspec_status)
      case inspec_status
      when "passed", "skipped", "waived"
        "ok"
      else
        "not ok"
      end
    end

    # Map InSpec severity (0..1) to CVSS scale (none-low-medium-high-critical)
    #
    # @param [Float] inspec_severity Severity from the profile
    # @return [String] One of the scale values
    # @see https://www.first.org/cvss/specification-document#Qualitative-Severity-Rating-Scale
    def impact_to_severity(inspec_severity)
      case inspec_severity
      when 0.0...0.1
        "none"
      when 0.1...0.4
        "low"
      when 0.4...0.7
        "medium"
      when 0.7...0.9
        "high"
      when 0.9..1.0
        "critical"
      else
        "unknown"
      end
    end
  end
end

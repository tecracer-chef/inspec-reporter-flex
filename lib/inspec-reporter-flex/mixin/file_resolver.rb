module InspecPlugins::FlexReporter
  module FileResolver
    # Resolve the full path for a file in order absolute path/gem bundled file/relative.
    #
    # @param [String] name Name or path of a file to resolve
    # @return [String] Absolute path to the file, if any
    # @raise [IOError] if file not found
    def full_path(name)
      if absolute_path?(name)
        name
      elsif relative_path?(name)
        relative_path(name)
      elsif gem_path?(name)
        gem_path(name)
      else
        raise IOError, "Template file #{name} not found"
      end
    end

    # Is this an absolute path?
    #
    # @param [String] name name or path of a file
    # @return [Boolean] if it is an absolute path
    def absolute_path?(name)
      name.start_with? "/"
    end

    # Is this an relative path?
    #
    # @param [String] name name or path of a file
    # @return [Boolean] if it is an relative path
    def relative_path?(name)
      File.exist? relative_path(name)
    end

    # Is this a Gem-bundled path?
    #
    # @param [String] name name or path of a file
    # @return [Boolean] if it is a Gem-bundled path
    def gem_path?(name)
      File.exist? gem_path(name)
    end

    # Return absolute path for a file relative to Dir.pwd.
    #
    # @param [String] name Name or path of a file
    # @return [String] Absolute path to the file
    def relative_path(name)
      File.join(Dir.pwd, name)
    end

    # Return absolute path for a file bundled with this Gem.
    #
    # @param [String] name Name or path of a file
    # @return [String] Absolute path to the file
    def gem_path(name)
      File.join(__dir__, "../../..", name)
    end
  end
end

require "vagrant/util/counter"

module VagrantPlugins
  module Chef
    module Config
      class Base < Vagrant.plugin("2", :config)
        extend Vagrant::Util::Counter

        # The path to Chef's bin/ directory.
        # @return [String]
        attr_accessor :binary_path

        # Arbitrary environment variables to set before running the Chef
        # provisioner command.
        # @return [String]
        attr_accessor :binary_env

        # Install Chef on the system if it does not exist. Default is true.
        # This is a trinary attribute (it can have three values):
        #
        # - true (bool) install Chef
        # - false (bool) do not install Chef
        # - "force" (string) install Chef, even if it is already installed at
        #   the proper version
        #
        # @return [true, false, String]
        attr_accessor :install

        # The Chef log level. See the Chef docs for acceptable values.
        # @return [String, Symbol]
        attr_accessor :log_level

        # Install a prerelease version of Chef.
        # @return [true, false]
        attr_accessor :prerelease

        # The version of Chef to install. If Chef is already installed on the
        # system, the installed version is compared with the requested version.
        # If they match, no action is taken. If they do not match, version of
        # the value specified in this attribute will be installed over top of
        # the existing version (a warning will be displayed).
        #
        # You can also specify "latest" (default), which will install the latest
        # version of Chef on the system. In this case, Chef will use whatever
        # version is on the system. To force the newest version of Chef to be
        # installed on every provision, set the {#install} option to "force".
        #
        # @return [String]
        attr_accessor :version

        def initialize
          super

          @binary_path = UNSET_VALUE
          @binary_env  = UNSET_VALUE
          @install     = UNSET_VALUE
          @log_level   = UNSET_VALUE
          @prerelease  = UNSET_VALUE
          @version     = UNSET_VALUE
        end

        def finalize!
          @binary_path = nil     if @binary_path == UNSET_VALUE
          @binary_env  = nil     if @binary_env == UNSET_VALUE
          @install     = true    if @install == UNSET_VALUE
          @log_level   = :info   if @log_level == UNSET_VALUE
          @prerelease  = false   if @prerelease == UNSET_VALUE
          @version     = :latest if @version == UNSET_VALUE

          # Make sure the install is a symbol if it's not a boolean
          if @install.respond_to?(:to_sym)
            @install = @install.to_sym
          end

          # Make sure the version is a symbol if it's not a boolean
          if @version.respond_to?(:to_sym)
            @version = @version.to_sym
          end

          # Make sure the log level is a symbol
          @log_level = @log_level.to_sym
        end

        # Like validate, but returns a list of errors to append.
        #
        # @return [Array<String>]
        def validate_base(machine)
          errors = _detected_errors

          if missing?(log_level)
            errors << I18n.t("vagrant.provisioners.chef.log_level_empty")
          end

          errors
        end

        # Determine if the given string is "missing" (blank)
        # @return [true, false]
        def missing?(obj)
          obj.to_s.strip.empty?
        end
      end
    end
  end
end

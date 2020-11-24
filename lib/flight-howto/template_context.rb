#==============================================================================
# Copyright (C) 2020-present Alces Flight Ltd.
#
# This file is part of FlightHowto.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# FlightHowto is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with FlightHowto. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on FlightHowto, please visit:
# https://github.com/openflighthpc/flight-howto
#==============================================================================

require 'erb'
require 'ostruct'
require 'pathname'
require 'yaml'

module FlightHowto
  class TemplateContext < Hashie::Mash
    def self.load
      if Dir.exists? Config::CACHE.template_config_dir
        Pathname.new(Config::CACHE.template_config_dir)
                .children
                .sort
                .each_with_object(new) { |p, memo| memo.load_config(p) }
      else
        new
      end
    end

    def load_config(pathname)
      pathname = Pathname.new(pathname) unless pathname.is_a? Pathname

      # Do not require the config to exist. Missing configs are considered as
      # good as empty. This allows load_config to be embedded in templates easily
      return unless pathname.exist?

      # Error if the requested config does not give an absolute path, it should
      # already be expanded
      raise ConfigLoadError, <<~ERROR.chomp unless pathname.absolute?
        Can not load the templating config as it is not an absolute path:
        #{pathname.to_s}
      ERROR

      # Error if the config is not readable
      raise ConfigLoadError, <<~ERROR.chomp unless pathname.readable?
        Can not open the template config:
        #{pathname.to_s}
      ERROR

      # Merge the config into the existing context
      begin
        merge!(**(YAML.load(pathname.read, symbolize_names: true) || {}))
      rescue
        raise ConfigLoadError, <<~ERROR.chomp
          Failed to load the templating config! Please ensure it is valid YAML
          #{pathname.to_s}
        ERROR
      end
    end

    def render(template)
      Bundler.with_original_env do
        ERB.new(template, nil, '-').result(to_module.to_binding)
      end
    end

    # Convert the context into a module which defines the top level
    # keys as constants. This provides nice handling of capitalised keys
    def to_module
      Module.new do
        class << self
          attr_reader :context

          # Do not error on missing constants
          def const_missing(s)
            nil
          end

          def to_binding
            class_eval('binding')
          end
        end
      end.tap do |mod|
        mod.instance_variable_set(:@context, self)

        mod.context.each do |key, value|
          # Skip keys which can not be constantized
          next unless /\A[[:alpha:]]\w*\Z/.match?(key.to_s)

          # Generate the constant key
          const_key = key.to_s.upcase

          # Do not redefine constants
          next if mod.const_defined?(key)

          # Define the constant
          mod.const_set(const_key, value)
        end
      end
    end
  end
end

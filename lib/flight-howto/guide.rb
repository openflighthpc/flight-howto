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

require 'tty-markdown'
require 'tty-pager'

module FlightHowto
  Guide = Struct.new(:path) do
    INDEX_REGEX = /\A(?<index>\d[[:alnum:]]*)_(?<rest>.*)\Z/

    ##
    # Used to convert strings into a standardized format. This provides case
    # and word boundary invariance. The standardization process will:
    # * Use underscore for the word boundaries, and
    # * Downcase all letters
    def self.standardize_string(string)
      string.dup.gsub(/[\s-]/, '_').downcase
    end

    attr_reader :parts
    attr_reader :index

    def initialize(*a)
      super

      # Standardizes the case and word boundaries
      name = self.class.standardize_string(File.basename(path, '.*'))

      # Detects if an index has been provided
      match = INDEX_REGEX.match(name)
      if match
        # Remove the index from the name, and trim leading zeros
        @index = match.named_captures['index'].sub(/\A0*/, '')
        @parts = match.named_captures['rest'].split('_')
      else
        # Set the index to the default
        @index = Config::CACHE.default_index.to_s
        @parts = name.split('_')
      end
    end

    ##
    # Converts the parts to a human friendly format. This does
    # not include the index
    def humanized_name
      @humanized_name ||= parts.map(&:capitalize).join(' ')
    end

    ##
    # Reads the guides content
    def read
      File.read path
    end

    ##
    # Renders the markdown
    def render
      TTY::Markdown.parse(read)
    end
  end
end

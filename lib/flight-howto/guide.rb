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
    INDEX_REGEX = /\A(?<index>\d+)_(?<rest>.*)\Z/

    ##
    # Used to convert strings into a standardized format. This provides case
    # and word boundary invariance. The standardization process will:
    # * Use underscore for the word boundaries, and
    # * Downcase all letters
    def self.standardize_string(string)
      string.dup.gsub(/[\s-]/, '_').downcase
    end

    ##
    # Returns the standardized version of the base name, this is primarily
    # used to provide case/boundary invariant pattern matching
    #
    # The standard basename should always be prefixed with a two digit
    # integer. Their is no assumption on uniqueness, however in practice
    # this is likely to be the case.
    #
    # As a compromise, the standard_basename is always prefixed with an
    # integer which in term becomes a non-unique index lookup. The
    # "default index" 99_ has been chosen so they always sort last
    #
    # NOTE: Leading zeros are stripped from the index otherwise the
    #       user would need to include for the atomic match to work
    #
    # The file extension is not include in the standardized name
    def standard_basename
      @standard_basename ||= begin
        name = self.class.standardize_string(File.basename(path, '.*'))
        if match = INDEX_REGEX.match(name)
          # Type casting removes leading 0s
          id = match.named_captures['index'].to_i
          rest = match.named_captures['rest']
          "#{id}_#{rest}"
        else
          # Add the default index
          "#{Config::CACHE.default_index.to_i}_#{name}"
        end
      end
    end

    ##
    # Returns the index associated with the guide
    def index
      @index ||= /\A\d+/.match(standard_basename).to_a.first
    end

    ##
    # Converts the standard_basename to a human friendly format. This does
    # not include the index
    def humanized_name
      @humanized_name ||= standard_basename.split('_')[1..-1]
                                           .map(&:capitalize)
                                           .join(' ')
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

    ##
    # Pages the guides content
    def page
      ENV['LESS'] ||= '-FRX'
      TTY::Pager.new.page(render)
    end
  end
end

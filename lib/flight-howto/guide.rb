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

require 'tty-pager'
require 'securerandom'

require_relative 'renderer'
require_relative 'meta_regex'

module FlightHowto
  PREFIX_REGEX  = /\A(?<prefix>\d+)_(?<rest>.*)\Z/

  Guide = Struct.new(:path) do
    ##
    # Used to convert strings into a standardized format. This provides case
    # and word boundary invariance. The standardization process will:
    # * Use underscore for the word boundaries, and
    # * Downcase all letters
    def self.standardize_string(string)
      string.dup                # Don't modify the input string
            .gsub(/[\s-]/, '_') # Treat hyphen as an underscore
            .downcase           # Make it case insensitive
    end

    attr_reader :prefix, :joined
    attr_writer :index

    def initialize(*a)
      super

      # Standardizes the case and word boundaries
      name = self.class.standardize_string(File.basename(path, '.*'))

      # Detects if an prefix has been provided
      match = PREFIX_REGEX.match(name)
      if match
        # Remove the prefix from the name, and trim leading zeros
        @prefix = match.named_captures['prefix'].to_i
        @joined = match.named_captures['rest']
      else
        @prefix = nil
        @joined = name
      end
    end

    ##
    # A random identifier used to back reference from the search algorithm
    # It is not intended to be exposed to the end user
    def id
      @id ||= SecureRandom.uuid
    end

    ##
    # Comparison Operator
    def <=>(other)
      return nil unless self.class == other.class
      if prefix == other.prefix
        joined <=> other.joined
      elsif prefix && other.prefix
        prefix <=> other.prefix
      elsif prefix
        -1
      else
        1
      end
    end

    ##
    # A guide's index depends on the sort order within the greater list of guides
    # To prevent time complexity issues, it is injected onto guide after it is loaded
    # This creates two problems:
    #  * It could be accessed before being set, triggering an internal error
    #  * It can become stale and should be viewed with scepticism
    def index
      @index || raise(InternalError, <<~ERROR.chomp)
        The guide index has not been set: #{path}
      ERROR
    end

    def parts
      @parts ||= joined.split('_')
    end

    ##
    # Converts the parts to a human friendly format. This does
    # not include the prefix
    def humanized_name
      @humanized_name ||= parts.map(&:capitalize).join(' ')
    end

    ##
    # Checks if the command is admin only by loading the metadata
    def admin?
      metadata[:admin] ? true : false
    end

    def metadata
      @metadata ||= read_metadata
    end

    def content
      @content ||= read_content
    end

    ##
    # Renders the markdown
    def render
      begin
        Renderer.new(content).wrap_markdown
      rescue => e
        Config::CACHE.logger.error "Failed to pretty render: #{path}"
        Config::CACHE.logger.warn e.full_message
        content
      end
    end

    private

    ##
    # Processes the metadata block at the start of each guide
    def read_metadata
      {}.tap do |meta|
        File.open(path) do |file|
          while (line = file.gets)[0] == ':'
            if match = META_REGEX.match(line)
              captures  = match.named_captures
              key       = captures['key'].downcase.to_sym

              if value = captures['single']
                meta[key] = value.gsub("\'", "'")
              elsif value = captures['double']
                meta[key] = "\"#{value}\"".undump
              elsif value = captures['value']
                meta[key] = case value
                            when 'true'
                              true
                            when 'false'
                              false
                            when /\d+/
                              value.to_i
                            else
                              value
                            end
              else
                meta[key] = nil
              end
            end
          end
        end
      end
    end

    ##
    # Reads the guide without the metadata
    def read_content
      enum = File.read(path).each_line
      memo = ''

      begin
        # Fast forward past the metadata block
        enum.next while enum.peek[0] == ':'

        # Skip a single trailing blank line
        enum.next if enum.peek == "\n"

        # Reform the remaining content
        loop { memo = memo << enum.next }
      rescue StopIteration
        # NOOP
      end

      memo.force_encoding('UTF-8')
    end
  end
end

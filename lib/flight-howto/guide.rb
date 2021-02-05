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
require 'open3'

require_relative 'markdown_renderer'
require_relative 'parser'
require_relative 'template_context'

module FlightHowto
  GROFF_CMD = 'groff -mtty-char -mandoc -Tascii -t -'
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
      basename = File.basename(path).sub(/\..*\Z/, '')
      name = self.class.standardize_string(basename)

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

    def template?
      /\.erb\Z/.match? path
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
      parse_result.attributes
    end

    def content
      @content ||= begin
        raw = parse_result.content
        template? ? TemplateContext.load.render(raw) : raw
      end
    end

    def render_manpage
      env = {
        'PATH' => '/bin:/sbin:/usr/bin:/usr/sbin',
        'HOME' => ENV['HOME'],
        'USER' => ENV['USER'],
        'LOGNAME' => ENV['LOGNAME'],
      }
      html  = Kramdown::Document.new(content,
                                     smart_quotes: ['apos', 'apos', 'quot', 'quot'],
                                     typographic_symbols: { hellip: '...', ndash: '--', mdash: '--' },
                                     hard_wrap: false,
                                     input: 'GFM').to_html
      roff  = Kramdown::Document.new(html, input: 'html').to_man
      out, errors, status = Open3.capture3(
        env,
        GROFF_CMD,
        stdin_data: roff,
        unsetenv_others: true,
        close_others: true,
      )

      unless errors.empty?
        Config::CACHE.logger.warn <<~WARN.chomp
          The following errors when rendering the manpage for: #{path}
          #{errors}
        WARN
      end

      if status.success?
        out
      else
        raise RenderError, "Failed to render: #{humanized_name}"
      end
    end

    ##
    # Renders the markdown
    def render
      begin
        MarkdownRenderer.new(content).wrap_markdown
      rescue => e
        Config::CACHE.logger.error "Failed to pretty render: #{path}"
        Config::CACHE.logger.warn e.full_message
        content
      end
    end

    private

    def parse_result
      @parse_result ||= Parser.new.call(path)
    end
  end
end

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
require 'word_wrap'

module FlightHowto
  Renderer = Struct.new(:content, :width) do
    attr_reader :colors

    def initialize(*_)
      super
      self.width ||= ((w = TTY::Screen.width) > 80 ? w : 80)
      @colors = 256 # Attempt to use 256-color initially
    end

    def wrap_markdown
      parse_markdown.split("\n").map do |padded_line|
        # Finds the un-padded line and the padding width
        line = padded_line.sub(/^\s*/, '')
        pad_width = padded_line.length - line.length
        padding = ' ' * pad_width

        # Wraps the un-padded line, adjusting for the paddding
        wrapped_line = WordWrap.ww(line, width - pad_width).chomp

        # Pads the start and additional new line characters
        "#{padding}#{wrapped_line}".gsub("\n", "\n#{padding}")
      end.join("\n")
    end

    def parse_markdown
      # TTY::Markdown does not wrap text correctly and makes it difficult
      # for WordWrap as it adds padding to the beginning of the lines.
      #
      # A work around is to pseudo disable text wrapping at this stage and then
      # wrap each line individually accounting for its padding.
      TTY::Markdown.parse(content, colors: colors, width: content.length)
    rescue
      if colors > 16
        @colors = 16
        retry       # Retry using 16-colors
      end
    end
  end
end

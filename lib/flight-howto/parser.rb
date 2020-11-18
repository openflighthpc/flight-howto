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

# Copyright (c) 2007–… Denis Defreyne and contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

module FlightHowto
  class Parser
    SEPARATOR = /(-{5}|-{3})/.source

    class ParseResult
      attr_reader :content
      attr_reader :attributes
      attr_reader :attributes_data

      def initialize(content:, attributes:, attributes_data:)
        @content = content
        @attributes = attributes
        @attributes_data = attributes_data
      end
    end

    # @return [ParseResult]
    def call(content_filename)
      parse_with_frontmatter(content_filename)
    end

    # @return [ParseResult]
    def parse_with_frontmatter(content_filename)
      data = read_file(content_filename)

      unless /\A#{SEPARATOR}\s*$/.match?(data)
        return ParseResult.new(content: data, attributes: {}, attributes_data: '')
      end

      pieces = data.split(/^#{SEPARATOR}[ \t]*\r?\n?/, 3)
      if pieces.size < 4
        raise InvalidFormatError.new(content_filename)
      end

      meta = parse_metadata(pieces[2], content_filename)
      content = pieces[4].sub(/\A\n/, '')

      ParseResult.new(content: content, attributes: meta, attributes_data: pieces[2])
    end

    # @return [Hash]
    def parse_metadata(data, filename)
      begin
        meta = YAML.load(data) || {}
      rescue => e
        raise UnparseableMetadataError.new(filename, e)
      end

      verify_meta(meta, filename)

      meta
    end

    def frontmatter?(filename)
      data = read_file(filename)
      /\A#{SEPARATOR}\s*$/.match?(data)
    end

    def verify_meta(meta, filename)
      return if meta.is_a?(Hash)

      raise InvalidMetadataError.new(filename, meta.class)
    end

    def read_file(filename)
      # Read
      begin
        data = File.read(filename)
      rescue => e
        raise FileUnreadableError.new(filename, e)
      end

      # Set original encoding, if any
      original_encoding = data.encoding

      # Set encoding to UTF-8
      begin
        data.encode!('UTF-8')
      rescue
        raise InvalidEncodingError.new(filename, original_encoding)
      end

      # Verify
      unless data.valid_encoding?
        raise InvalidEncodingError.new(filename, original_encoding)
      end

      # Remove UTF-8 BOM (ugly)
      data.delete!("\xEF\xBB\xBF")

      data
    end
  end
end

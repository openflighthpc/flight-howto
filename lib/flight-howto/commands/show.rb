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

require 'fuzzy_match'
require 'tty-markdown'
require 'kramdown'

module FlightHowto
  module Commands
    class Show < Command
      def run
        puts TTY::Markdown.parse(read_guide)
      end

      def fuzzy_name
        args.first
      end

      def resolve_name
        if File.exists? join_howto(fuzzy_name)
          fuzzy_name
        elsif options.exact
          raise MissingError, "Could not exactly match: #{fuzzy_name}"
        elsif match = FuzzyMatch.new(fetch_howtos, read: :to_s).find(fuzzy_name)
          match
        else
          raise MissingError, "Could not fuzzy match: #{fuzzy_name}"
        end
      end

      def read_guide
        File.read join_howto(resolve_name)
      end
    end
  end
end

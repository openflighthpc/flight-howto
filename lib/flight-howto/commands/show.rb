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

module FlightHowto
  module Commands
    class Show < Command
      def run
        guides = match_guides
        if guides.length == 0
          raise MissingError, "Could not locate: #{args.join(' ')}"
        elsif guides.length == 1
          guide = guides.first
          options.no_pager ? (puts guide.render) : guide.page
        else
          msg = ['Could not uniquely identify a guide. Did you mean?']
          guides.each do |guide|
            msg << "#{guide.index} #{guide.humanized_name}"
          end
          raise MissingError, msg.join("\n")
        end
      end

      def search_keys
        @search_keys ||= Guide.standardize_string(args.join('_')).split('_').uniq
      end

      def search_hash
        @search_hash ||= search_keys.map { |key| [key, true] }.to_h
      end

      ##
      # Select guides who's name contains all the search keys
      # NOTE: This method ignores order because it is hard to check and does
      #       not improve the usability
      def match_guides
        fetch_guides.select do |guide|
          # Generate standardized parts of the guide's name
          parts = guide.standard_basename.split('_')

          # Ignore parts which do not appear in the search_key
          filtered = parts.select { |p| search_hash[p] }

          # Ensure the filtered key contains all the search keys
          filtered.uniq.length == search_keys.length
        end
      end
    end
  end
end

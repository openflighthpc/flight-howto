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
        if options.no_pager
          puts load_content
        else
          TTY::Pager.new.page(load_content)
        end
      end

      def load_content
        guide = resolve_guide
        if $stdout.tty? && !options.no_pretty
          guide.render
        else
          guide.read
        end
      end

      def resolve_guide
        # Attempt to find a guide by ID
        if args.length == 1 && (guide = matcher.find_by_index(args.first))
          guide

        # Handle loose guide resolution
        else
          guides = load_guides_from_args
          if guides.length == 1
            guides.first
          elsif guides.length > 1
            raise MissingError, <<~ERROR.chomp
              Could not uniquely identify a guide. Did you mean one of the following?
              #{Paint[Lister.build_output(verbose: false).render(*guides), :reset]}
            ERROR
          else
            raise MissingError, "Could not locate: #{args.join(' ')}"
          end
        end
      end

      def load_guides_from_args
        Guide.standardize_string(args.join('_'))
             .split('_')
             .uniq
             .reduce(matcher) { |memo, key| memo.search(key) }
             .guides
      end

      def matcher
        @matcher ||= Matcher.new
      end
    end
  end
end

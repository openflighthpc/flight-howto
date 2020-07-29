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

require_relative 'guide'

module FlightHowto
  class Matcher
    include Enumerable
    extend  Forwardable

    ##
    # Helper method for loading in all the guides
    def self.load_guides
      Dir.glob(File.join(Config::CACHE.howto_dir, '*\.md'))
         .map { |p| Guide.new(p) }
    end

    ##
    # Enumerates over a set of guides
    attr_reader     :guides
    def_delegators  :guides, :each

    ##
    # Optionally allow a Matcher to be created with a set of guides
    #
    def initialize(guides = nil)
      @guides = guides || self.class.load_guides
    end

    ##
    # Searches the guides for an ID match. The IDs will implicitly be downcasd
    # without leading 0s. This is to match the processing of the filenames
    def find_by_id(raw_id)
      id = raw_id.to_s.downcase.sub(/\A0*/, '')
      find { |g| g.id == id  }
    end

    ##
    # Filter the guides by a search key. Note: They key must already be standardized
    def search(key)
      regex = /\A#{key}.*/
      matching_guides = select do |guide|
        guide.parts.any? { |p| regex.match?(p)  }
      end
      self.class.new(matching_guides)
    end
  end
end


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

require 'output_mode'
require 'pathname'
require 'pastel'

module FlightHowto
  module Commands
    class List < Command
      # Defines a handy interface for generating Tabulated data
      extend OutputMode::TLDR::Index

      # Defines the columns to the output as a series of blocks
      # Essentially each "callable" is a proc and a config rolled into a single object
      register_callable(header: 'Index') do |guide|
        $stdout.tty? ? pastel.yellow(guide.index) : guide.index
      end
      register_callable(header: 'Name') do |guide|
        if $stdout.tty?
          pastel.cyan guide.humanized_name
        else
          guide.parts.join('_')
        end
      end
      register_callable(header: "File (Dir: #{Config::CACHE.howto_dir})", verbose: true) do |guide|
        if $stdout.tty?
          Pathname.new(guide.path).relative_path_from Config::CACHE.howto_dir
        else
          guide.path
        end
      end

      def self.pastel
        @pastel ||= Pastel.new
      end

      def run
        guides = Matcher.new.guides
        if guides.empty?
          $stderr.puts 'No guides found!'
        else
          puts build_output.render(*guides)
        end
      end

      def build_output
        self.class.build_output(verbose: options.verbose)
      end
    end
  end
end

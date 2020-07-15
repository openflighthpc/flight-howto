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

require_relative 'commands'
require_relative 'version'
require_relative 'errors'

require 'commander'

module FlightHowto
  module CLI
    extend Commander::CLI

    program :name, Config::CACHE.app_name
    program :version, "v#{FlightHowto::VERSION}"
    program :description, '%DESCRIPTION%'
    program :help_paging, false
    default_command :help

    if ENV['TERM'] !~ /^xterm/ && ENV['TERM'] !~ /rxvt/
      Paint.mode = 0
    end

    def self.create_command(name, args_str = '')
      command(name) do |c|
        c.syntax = "#{program :name} #{name} #{args_str}"
        c.hidden = true if name.split.length > 1

        c.action do |args, opts|
          Commands.build(name, *args, **opts.to_h).run!
        end

        yield c if block_given?
      end
    end

    create_command 'list' do |c|
      c.summary = 'Return all the known how-to guides'
    end

    create_command 'show', 'NAME_OR_FUZZY' do |c|
      c.summary = 'Search and display a how-to guide'
      c.description = <<~DESC.chomp
        Search for a how-to guide by it's name or close approximation.
        Exact name matches are recommended in order to gaurantee a particular
        guide is returned.

        Failing an exact match, a close approximation shall be used instead.
        This should yield the expect guide if the search name is similar to the
        target. For example, NAME_OR_FUZZY could be:
         * The leading prefix to the guide,
         * A key word within the guide's name, or
         * A minor typo in the spelling.
      DESC
      c.slop.bool '--exact', 'Require the name to extactly match, disables fuzzy logic'
    end

    if Config::CACHE.development?
      create_command 'console' do |c|
        c.action do
          FlightHowto::Command.new([], {}).instance_exec { binding.pry }
        end
      end
    end
  end
end

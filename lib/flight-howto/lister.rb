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

module FlightHowto
  module Lister
    # Defines a handy interface for generating Tabulated data
    extend OutputMode::TLDR::Index

    # Define the index column
    register_column(header: 'Index', row_color: :yellow) do |guide|
      guide.index
    end

    # Define the name column (toggles on verbosity)
    { header: 'Name', row_color: :cyan }.tap do |o|
      register_column(verbose: true, **o) do |guide|
        guide.parts.join('_')
      end

      register_column(verbose: false, **o) do |guide|
        guide.humanized_name
      end
    end

    # Define the file column (toggles on verbosity)
    register_column(header: "File (Dir: #{Config::CACHE.howto_dir})", verbose: true) do |guide|
      # NOTE: This toggle does not work quite as expected with --ascii flag
      #       The --ascii flag should give the humanized output in non-interactive terminals
      #       However the flag is not available at this point in the code execution
      #
      #       Fixing this will require an additional feature in OutputMode
      if $stdout.tty?
        Pathname.new(guide.path).relative_path_from Config::CACHE.howto_dir
      else
        guide.path
      end
    end

    # NOTE: OutputMode now considers 'true' to be explicitly on and 'false' as explicit off
    #       The default handling is trigged by `nil` (e.g. verbose: nil)
    #
    #       However Slop can not pass a nil values for boolean flags,
    #       so there needs to be an adaptation layer between the two.
    def self.build_output(verbose: false, ascii: false, interactive: false)
      opts = {}.tap do |o|
        o[:verbose]     = true  if verbose
        o[:ascii]       = true  if ascii
        o[:interactive] = true  if interactive || ascii
      end
      super(header_color: :clear, row_color: :clear, **opts)
    end
  end
end


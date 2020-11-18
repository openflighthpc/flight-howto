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
  class Error < RuntimeError
    def self.define_class(code, &block)
      Class.new(self).tap do |klass|
        klass.instance_variable_set(:@exit_code, code)

        if block
          klass.class_eval(&block)
        end
      end
    end

    def self.exit_code
      @exit_code || begin
        superclass.respond_to?(:exit_code) ? superclass.exit_code : 2
      end
    end

    def exit_code
      self.class.exit_code
    end
  end

  InternalError = Error.define_class(1)
  GeneralError = Error.define_class(2)
  InputError = GeneralError.define_class(3)

  InvalidFormatError = GeneralError.define_class(4) do
    def initialize(content_filename)
      super("The file '#{content_filename}' appears to start with a metadata section (three or five dashes at the top) but it does not seem to be in the correct format.")
    end
  end

  UnparseableMetadataError = GeneralError.define_class(5) do
    def initialize(filename, error)
      super("Could not parse metadata for #{filename}: #{error.message}")
    end
  end

  InvalidMetadataError = GeneralError.define_class(6) do
    def initialize(filename, klass)
      super("The file #{filename} has invalid metadata (expected key-value pairs, found #{klass} instead)")
    end
  end

  InvalidEncodingError = GeneralError.define_class(8) do
    def initialize(filename, encoding)
      super("Could not read #{filename} because the file is not valid #{encoding}.")
    end
  end

  FileUnreadableError = GeneralError.define_class(7) do
    def initialize(filename, error)
      super("Could not read #{filename}: #{error.inspect}")
    end
  end

  class InteractiveOnly < InputError
    MSG = 'This command requires an interactive terminal'

    def initialize(msg = MSG)
      super
    end
  end

  MissingError = GeneralError.define_class(20)
end

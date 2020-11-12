#==============================================================================
# Adapted from https://github.com/bkeepers/dotenv/blob/9e16a424083055139e62d60a55bd0fec53003cee/lib/dotenv/parser.rb
# Modifications to the original software are made available under the terms of
# the main software license:
#
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
#
#==============================================================================
# Original License:
#
# Copyright (c) 2012 Brandon Keepers
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#==============================================================================

module FlightHowto
  META_REGEX = /
    (?:^|\A):                     # beginning of line, with a colon prefix
    \s*                           # leading whitespace
    (?<key>[\w]+)                 # key
    (?:\s*=\s*?|:\s+?)            # separator
    (?:                           # optional value begin
      '(?<single>(?:\\'|[^'])*)'  #   single quoted value
      |                           #   or
      "(?<double>(?:\\"|[^"])*)"  #   double quoted value
      |                           #   or
      (?<value>[^\#\r\n]+)        #   unquoted value
    )?                            # value end
    \s*                           # trailing whitespace
    (?:\#.*)?                     # optional comment
    (?:$|\z)                      # end of line
  /x
end

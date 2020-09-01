# frozen_string_literal: true
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
source 'https://rubygems.org'

gem 'commander-openflighthpc', '~> 2'
gem 'hashie'
gem 'output_mode'
# There is a bug in TTY::Markdown where it does not render links correctly
# This will be fixed in the version 0.7.0 release, however the fix is on the
# master branch. The catch is the new version requires the bleeding edge of the
# entire TTY toolbox.
#
# This fix can be removed once the 0.7.0 version is released
# https://github.com/piotrmurach/tty-markdown/issues/26
#
# PS: TTY::Table is not required directly by this app, but is a transient
# dependency of OutputMode. However due to the above issue, it also needs to
# be on the bleeding edge ¯\_(ツ)_/¯
gem 'pastel',       git: 'https://github.com/piotrmurach/pastel',       ref: 'afd82952076e605402a54dd0a142cdcebe34edc7'
gem 'tty-markdown', git: 'https://github.com/piotrmurach/tty-markdown', ref: '93f6fe9096f3096d65dd3e752d9d873fd0f7acd6'
gem 'tty-pager',    git: 'https://github.com/piotrmurach/tty-pager',    ref: 'd5fc3426ad1e5d670c7bc890b240d1cfe9124ac5'
gem 'tty-table',    git: 'https://github.com/piotrmurach/tty-table',    ref: '0088ab81b5f211012eda0f7970fc9ae5b8fc3824'
gem 'word_wrap'
gem 'xdg'

group :development do
  gem 'pry'
  gem 'pry-byebug'
end

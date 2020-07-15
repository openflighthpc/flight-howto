# Flight Howto

Search and display useful hints on how to use the `flight` suite

## Installation

The application requires a modern(ish) version of `ruby`/`bundler`. It has been designed with the following versions in mind:
* centos7
* ruby 2.7.1
* bundler 2.1.4

After downloading the source code (via git or other means), the gems need to be installed using bundler:

```
cd /path/to/source
bundle install --with default --without development --path vendor
```

## Configuration

See the [reference config](etc/config.reference) for the list of configuration keys. The config
must be saved relative to the repos root director (aka the directory containing this file).

```
vi etc/config.yaml # Add/edit keys specified in the reference
```

## Operation

Markdown documents must be added to the how to CLI manually. The default path to the directory depends on if `flight_ROOT` has been set:

```
# If `flight_ROOT` has not been exported to the environment, then a relative
# path from the README direcotry is used
var/flight/etc/howto

# If the default `flight_ROOT` has been exported
/opt/flight/etc/howto

# If you updated the internal etc/config.yaml
.. anywhere you want ..
```

The file extension must be `.md`:

```
./flight/etc/howto/my-guide.md        # Valid
./flight/etc/howto/my-guide.markdown  # Ignored
```

To list all the guides within the directory:

```
bin/howto list
```

To view a particular guide:

```
bin/howto show my-guide
... displays my-guide ...
```

To fuzzy search for a guide:

```
bin/howto show guide
... displays my-guide ...
```

To force an explicit match

```
bin/howto show my-guide --exact
... displays my-guide ...


bin/howto show guide --exact # errors
```

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

# Copyright and License

Eclipse Public License 2.0, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2020-present Alces Flight Ltd.

This program and the accompanying materials are made available under
the terms of the Eclipse Public License 2.0 which is available at
[https://www.eclipse.org/legal/epl-2.0](https://www.eclipse.org/legal/epl-2.0),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

FlightHowto is distributed in the hope that it will be
useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR
CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR
A PARTICULAR PURPOSE. See the [Eclipse Public License 2.0](https://opensource.org/licenses/EPL-2.0) for more
details.

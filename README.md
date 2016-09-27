# Resona

Homebrew resource stanza generator for RubyGems dependencies.

## Features

Given a `Gemfile`, resona will resolve gem dependencies and output Homebrew
resource stanzas useful for creating formulas. See the [Homebrew Formula
Cookbook](https://github.com/Homebrew/brew/blob/master/docs/Formula-Cookbook.md#specifying-gems-python-modules-go-projects-etc-as-dependencies)
for more information on resource stanzas.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resona'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resona

## Usage

```
Usage: resona [options] gemfile
        --with grp,...               Specify groups to include
        --without grp,...            Specify groups to exclude
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/midchildan/resona. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


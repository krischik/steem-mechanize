[![Gem Version](https://badge.fury.io/rb/steem-mechanize.svg)](https://badge.fury.io/rb/steem-mechanize)

# `steem-mechanize`

Steem Mechanize is an extension to [`steem-ruby`](https://github.com/steemit/steem-ruby) that replaces its `Net::HTTP` client with a [mechanize](https://github.com/sparklemotion/mechanize).

## Feature

There is only one feature provided by this gem: Persistent HTTP

All other functionality is identical to `steem-ruby`.  This gem achieves HTTP persistence by instantiating a Mechanize Agent as a singleton and using this agent for all requests.

This is like having one dedicated browser performing all POST requests for json-rpc.  For certain applications, this can represent a signifiant performance boost over what `Net::HTTP` can offer.

This gem also serves to demonstrate how easy it is to replace the default client used for performing `json-rpc` requests by `steem-ruby`.  The entire feature can be reviewed here:

[`lib/steem/mechanize/rpc/mechanize_client.rb`](lib/steem/mechanize/rpc/mechanize_client.rb)

## Getting Started

The `steem-mechanize` gem is compatible with Ruby 2.2.5 or later.

### Install the gem for your project

*(Assuming that [Ruby is installed](https://www.ruby-lang.org/en/downloads/) on your computer, as well as [RubyGems](http://rubygems.org/pages/download))*

To install the gem on your computer, run in shell:

```bash
gem install steem-mechanize
```

... then add in your code:

```ruby
require 'steem-mechanize'
```

To add the gem as a dependency to your project with [Bundler](http://bundler.io/), you can add this line in your Gemfile:

```ruby
gem 'steem-mechanize'
```

Once installed, use it just like [`steem-ruby`](https://github.com/steemit/steem-ruby).

### Tests

* Clone the client repository into a directory of your choice:
  * `git clone https://github.com/steemit/steem-mechanize.git`
* Navigate into the new folder
  * `cd steem-mechanize`
* To run `threads` tests (which quickly verifies thread safety):
  * `bundle exec rake test:threads`

You can also run other tests that are not part of the above `test` execution:

* To run `block_range`, which streams blocks (using `json-rpc-batch`)
  * `bundle exec rake stream:block_range`

## Contributions

Patches are welcome! Contributors are listed in the `steem-mechanize.gemspec` file. Please run the tests (`rake test`) before opening a pull request and make sure that you are passing all of them. If you would like to contribute, but don't know what to work on, check the issues list.

## Issues

When you find issues, please report them!

## License

MIT

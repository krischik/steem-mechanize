# encoding: UTF-8
require 'steem'
require 'mechanize'

require 'steem/mechanize/version'
require 'steem/mechanize/rpc/mechanize_client'

# Here, we will monkeypatch steem-ruby to use Mechanize.
module Steem
  class Api
    def self.default_rpc_client_class
      Steem::Mechanize::RPC::MechanizeClient
    end
  end
end

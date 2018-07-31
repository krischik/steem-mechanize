# encoding: UTF-8
require 'steem'
require 'mechanize'

require 'steem/mechanize/version'
require 'steem/mechanize/rpc/mechanize_client'

# Here, we will inject Mechanize into steem-ruby.
Steem::Api.register default_rpc_client_class: Steem::Mechanize::RPC::MechanizeClient

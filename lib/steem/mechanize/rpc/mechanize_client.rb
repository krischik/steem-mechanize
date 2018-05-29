module Steem
  module Mechanize
    module RPC
      class MechanizeClient < Steem::RPC::HttpClient
        POST_HEADERS = Steem::RPC::HttpClient::POST_HEADERS.merge(
          'User-Agent' => Steem::Mechanize::AGENT_ID
        )
        
        def self.agent
          @agent ||= ::Mechanize.new(Steem::Mechanize::AGENT_ID).tap do |agent|
            agent.user_agent = Steem::Mechanize::AGENT_ID
            agent.max_history = 0
            agent.default_encoding = 'UTF-8'
          end
        end
        
        def http_request(request)
          catch :request_with_entity do; begin
            self.class.agent.request_with_entity :post, url, request.body, POST_HEADERS
          rescue Net::HTTP::Persistent::Error => e
            @error_pipe.puts "Warning, retrying after agent reset due to: #{e}"
            @agent = nil
            throw :request_with_entity
          end; end
        end
      end
    end
  end
end

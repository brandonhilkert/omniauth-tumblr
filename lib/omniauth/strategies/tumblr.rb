require 'omniauth-oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Tumblr < OmniAuth::Strategies::OAuth

      option :name, 'tumblr'
      option :client_options, {:site => 'https://www.tumblr.com',
                               :request_token_path => "/oauth/request_token",
                               :access_token_path  => "/oauth/access_token",
                               :authorize_path     => "/oauth/authorize"}

      uid { raw_info['name'] }

      info do
        {
          :nickname => raw_info['name'],
          :name => raw_info['name'],
          :blogs => raw_info['blogs'].map do |b|
            { :name => b['name'], :url => b['url'], :title => b['title'] }
          end,
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def user
        tumblelogs = user_hash['tumblr']['tumblelog']
        if tumblelogs.kind_of?(Array)
          @user ||= tumblelogs[0]
        else
          @user ||= tumblelogs
        end
      end

      def raw_info
        url = 'https://api.tumblr.com/v2/user/info'
        @raw_info ||= MultiJson.decode(access_token.get(url).body)['response']['user']
      end
    end
  end
end

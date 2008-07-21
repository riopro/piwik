require 'rubygems'
require 'cgi'
require 'activesupport'
require 'rest_client'
require 'xmlsimple'

module Piwik
  class ApiError < StandardError; end
  class MissingConfiguration < ArgumentError; end
  class UnknownSite < ArgumentError; end
  class UnknownUser < ArgumentError; end

  class Base
    @@template  = <<-EOF
# .piwik
# 
# Please fill in fields like this:
#
#  piwik_url: http://your.piwik.site
#  auth_token: secret
#
piwik_url: 
auth_token: 
EOF
      
    private
      # Checks for the config, creates it if not found
      def self.load_config_from_file
        config = {}
        home = ENV['HOME'] || ENV['USERPROFILE'] || ENV['HOMEPATH']
        if File.exists?(home + "/.piwik")
          temp_config = YAML::load open(home + "/.piwik")
        else
          open(home + '/.piwik','w') { |f| f.puts @@template }
          temp_config = YAML::load(@@template)
        end
        temp_config.each { |k,v| config[k.to_sym] = v } if temp_config
        if config[:piwik_url] == nil || config[:auth_token] == nil
          raise MissingConfiguration, "Please edit ~/.piwik to include your piwik url and auth_key"
        end
        config
      end
  end
end

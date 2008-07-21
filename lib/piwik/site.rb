module Piwik
  class Site < Piwik::Base
    attr_accessor :name, :main_url
    attr_reader :id, :created_at, :config
    
    # Initializes a new <tt>Piwik::Site</tt> object, with the supplied attributes. 
    # 
    # You can pass the URL for your Piwik install and an authorization token as 
    # the second and third parameters. If you don't, than it will try to find 
    # them in a <tt>'~/.piwik'</tt> (and create the file with an empty template if it 
    # doesn't exists).
    # 
    # Valid (and required) attributes are:
    # * <tt>:name</tt> - the site's name
    # * <tt>:main_url</tt> - the site's url
    def initialize(attributes={}, piwik_url=nil, auth_token=nil)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      @config = if piwik_url.nil? || auth_token.nil?
        self.class.load_config_from_file
      else
        {:piwik_url => piwik_url, :auth_token => auth_token}
      end
      load_attributes(attributes)
    end
  
    # Returns an instance of <tt>Piwik::Site</tt> representing the site identified by 
    # the supplied <tt>site_id</tt>. Raises a <tt>Piwik::ApiError</tt> if the site doesn't 
    # exists or if the user associated with the supplied auth_token does not 
    # have at least 'view' access to the site.
    # 
    # You can pass the URL for your Piwik install and an authorization token as 
    # the second and third parameters. If you don't, than it will try to find 
    # them in a <tt>'~/.piwik'</tt> (and create the file with an empty template if it 
    # doesn't exists).
    def self.load(site_id, piwik_url=nil, auth_token=nil)
      raise ArgumentError, "expected a site Id" if site_id.nil?
      @config = if piwik_url.nil? || auth_token.nil?
        load_config_from_file
      else
        {:piwik_url => piwik_url, :auth_token => auth_token}
      end
      attributes = get_site_attributes_by_id(site_id, @config[:piwik_url], @config[:auth_token])
      new(attributes, @config[:piwik_url], @config[:auth_token])
    end
    
    # Returns <tt>true</tt> if the current site does not exists in the Piwik yet.
    def new?
      id.nil? && created_at.nil?
    end
    
    # Saves the current site in Piwik.
    # 
    # Calls <tt>create</tt> it it's a new site, <tt>update</tt> otherwise.
    def save
      new? ? create : update
    end
    
    # Saves the current new site in Piwik.
    # 
    # Equivalent Piwik API call: SitesManager.addSite (siteName, urls)
    def create
      raise ArgumentError, "Site already exists in Piwik, call 'update' instead" unless new?
      raise ArgumentError, "Name can not be blank" if name.blank?
      raise ArgumentError, "Main URL can not be blank" if main_url.blank?
      xml = call('SitesManager.addSite', :siteName => name, :urls => main_url)
      result = XmlSimple.xml_in(xml, {'ForceArray' => false})
      @id = result.to_i
      @created_at = Time.current
      id && id > 0 ? true : false
    end
    
    # Saves the current site in Piwik, updating it's data.
    # 
    # Equivalent Piwik API call: SitesManager.updateSite (idSite, siteName, urls)
    def update
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      raise ArgumentError, "Name can not be blank" if name.blank?
      raise ArgumentError, "Main URL can not be blank" if main_url.blank?
      xml = call('SitesManager.updateSite', :idSite => id, :siteName => name, :urls => main_url)
      result = XmlSimple.xml_in(xml, {'ForceArray' => false})
      result['success'] ? true : false
    end
    
    def reload
      #TODO
    end
    
    # Deletes the current site from Piwik.
    # 
    # Equivalent Piwik API call: SitesManager.deleteSite (idSite)
    def destroy
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      xml = call('SitesManager.deleteSite', :idSite => id)
      result = XmlSimple.xml_in(xml, {'ForceArray' => false})
      freeze
      result['success'] ? true : false
    end
    
    # Gives read access (<tt>'view'</tt>) to the supplied user login for the current
    # site.
    def give_view_access_to(login)
      give_access_to(:view, login)
    end
    
    # Gives read and write access (<tt>'admin'</tt>) for the supplied user login for the 
    # current site.
    def give_admin_access_to(login)
      give_access_to(:admin, login)
    end
    
    # Removes all access (gives an <tt>'noaccess'</tt>) for the supplied user login for 
    # the current site.
    def give_no_access_to(login)
      give_access_to(:noaccess, login)
    end
    alias_method :remove_access_from, :give_no_access_to
    
    # Returns a hash with a summary of access information for the current site 
    # (visits, unique visitors, actions / pageviews, maximum actions per visit, 
    # bounces and total time spent in all visits in seconds), filtered by the 
    # supplied period and date.
    # 
    # * <tt>period</tt> should be one of <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt> or <tt>:year</tt> (default: <tt>:day</tt>)
    # * <tt>date</tt> should be a <tt>Date</tt> object (default: <tt>Date.today</tt>)
    # 
    # Equivalent Piwik API call: VisitsSummary.get (idSite, period, date)
    def summary(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      xml = call('VisitsSummary.get', :idSite => id, :period => period, :date => date)
      result = XmlSimple.xml_in(xml, {'ForceArray' => false})
      {
        :visits => result['nb_visits'].to_i,
        :unique_visitors => result['nb_uniq_visitors'].to_i,
        :actions => result['nb_actions'].to_i,
        :max_actions_per_visit => result['max_actions'].to_i,
        :bounces => result['bounce_count'].to_i,
        :total_time_spent => result['sum_visit_length'].to_i, # in seconds
      }
    end
    
    # Returns the amount of visits for the current site, filtered by the 
    # supplied period and date.
    # 
    # * <tt>period</tt> should be one of <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt> or <tt>:year</tt> (default: <tt>:day</tt>)
    # * <tt>date</tt> should be a <tt>Date</tt> object (default: <tt>Date.today</tt>)
    # 
    # Equivalent Piwik API call: VisitsSummary.getVisits (idSite, period, date)
    def visits(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      xml = call('VisitsSummary.getVisits', :idSite => id, :period => period, :date => date)
      result = XmlSimple.xml_in(xml, {'ForceArray' => false})
      result.to_i
    end
    
    # Returns the amount of unique visitors for the current site, filtered by 
    # the supplied period and date.
    # 
    # * <tt>period</tt> should be one of <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt> or <tt>:year</tt> (default: <tt>:day</tt>)
    # * <tt>date</tt> should be a <tt>Date</tt> object (default: <tt>Date.today</tt>)
    # 
    # Equivalent Piwik API call: VisitsSummary.getUniqueVisitors (idSite, period, date)
    def unique_visitors(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      xml = call('VisitsSummary.getUniqueVisitors', :idSite => id, :period => period, :date => date)
      result = XmlSimple.xml_in(xml, {'ForceArray' => false})
      result.to_i
    end
    
    # Returns the amount of actions (pageviews) for the current site, filtered 
    # by the supplied period and date.
    # 
    # * <tt>period</tt> should be one of <tt>:day</tt>, <tt>:week</tt>, <tt>:month</tt> or <tt>:year</tt> (default: <tt>:day</tt>)
    # * <tt>date</tt> should be a <tt>Date</tt> object (default: <tt>Date.today</tt>)
    # 
    # Equivalent Piwik API call: VisitsSummary.getActions (idSite, period, date)
    def actions(period=:day, date=Date.today)
      raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
      xml = call('VisitsSummary.getActions', :idSite => id, :period => period, :date => date)
      result = XmlSimple.xml_in(xml, {'ForceArray' => false})
      result.to_i
    end
    alias_method :pageviews, :actions
    
    private
      # Calls the supplied Piwik API method, with the supplied parameters.
      # 
      # Returns a string containing the XML reply from Piwik, or raises a 
      # <tt>Piwik::ApiError</tt> exception with the error message returned by Piwik 
      # in case it receives an error.
      def call(method, params={})
        self.class.call(method, params, config[:piwik_url], config[:auth_token])
      end
    
      # Loads the attributes in the instance variables.
      def load_attributes(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
        @main_url = attributes[:main_url] ? attributes[:main_url].gsub(/\/$/, '') : nil
        @created_at = attributes[:created_at]
      end

      # Gives the supplied access for the supplied user, for the current site.
      # 
      # * <tt>access</tt> can be one of <tt>:view</tt>, <tt>:admin</tt> or <tt>:noaccess</tt>
      # * <tt>login</tt> is the user login on Piwik
      # 
      # Equivalent Piwik API call: UsersManager.setUserAccess (userLogin, access, idSites)
      def give_access_to(access, login)
        raise UnknownSite, "Site not existent in Piwik yet, call 'save' first" if new?
        xml = call('UsersManager.setUserAccess', :idSites => id, :access => access.to_s, :userLogin => login.to_s)
        result = XmlSimple.xml_in(xml, {'ForceArray' => false})
        result['success'] ? true : false
      end

      # Calls the supplied Piwik API method, with the supplied parameters.
      # 
      # Returns a string containing the XML reply from Piwik, or raises a 
      # <tt>Piwik::ApiError</tt> exception with the error message returned by Piwik 
      # in case it receives an error.
      def self.call(method, params={}, piwik_url=nil, auth_token=nil)
        raise MissingConfiguration, "Please edit ~/.piwik to include your piwik url and auth_key" if piwik_url.nil? || auth_token.nil?
        url = "#{piwik_url}/?module=API&format=xml&method=#{method}"
        url << "&token_auth=#{auth_token}" unless auth_token.nil?
        params.each { |k, v| url << "&#{k}=#{CGI.escape(v.to_s)}" }
        verbose_obj_save = $VERBOSE
        $VERBOSE = nil # Suppress "warning: peer certificate won't be verified in this SSL session"
        xml = RestClient.get(url)
        $VERBOSE = verbose_obj_save
        if xml =~ /error message=/
          result = XmlSimple.xml_in(xml, {'ForceArray' => false})
          raise ApiError, result['error']['message'] if result['error']
        end
        xml
      end

      # Returns a hash with the attributes of the supplied site, identified 
      # by it's Id in <tt>site_id</tt>.
      # 
      # Equivalent Piwik API call: SitesManager.getSiteFromId (idSite)
      def self.get_site_attributes_by_id(site_id, piwik_url, auth_token)
        xml = call('SitesManager.getSiteFromId', {:idSite => site_id}, piwik_url, auth_token)
        result = XmlSimple.xml_in(xml, {'ForceArray' => false})
        attributes = {
          :id => result['row']['idsite'].to_i,
          :name => result['row']['name'],
          :main_url => result['row']['main_url'],
          :created_at => Time.parse(result['row']['ts_created']),
        }
        attributes
      end
  end
end

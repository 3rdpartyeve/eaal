#--
# EAAL by Peter Petermann <PeterPetermann@gmx.net>
# This library is licensed under the terms found in
# the LICENSE file distributed with it
#
# TODO: 
#  - more documenation
#  - write tests (i know, i know, i fail badly)
#  - more error handling (im certain i missed a few possibles)
#  - cleanup (you can see that this is my first project in ruby, cant you?)
#
# THANKS:
#  thanks go to all people on irc.coldfront.net, channel #eve-dev
#  special thanks go to lisa (checkout her eve api library, reve,
#  much more mature then mine) for answering my endless questions 
#  about ruby stuff (and for one or two snippets i stole from reve)
#++

require 'rubygems'
require 'hpricot'
require 'activesupport'

require 'net/http'
require 'uri'
require 'cgi'

module EAAL
    
    mattr_reader :version_string, :version
    
    @@version = "0.1.4"
    @@version_string = "EAAL" +  EAAL.version # the version string, used as client name in http requests
    
    mattr_accessor :api_base, :additional_request_parameters, :cache
    @@api_base = "http://api.eve-online.com/"  # the url used as basis for all requests, you might want to use gatecamper url or a personal proxy instead
    @@additional_request_parameters = {}       # hash, if :key => value pairs are added those will be added to each request    
    @@cache = EAAL::Cache::NoCache.new         # caching object, see EAAL::Cache::FileCache for an Example
    
    # EAAL::API class
    # Usage Example:
    #  api = EAAL::API.new("my userid", "my API key")
    #  result = api.Characters
    #  result.characters.each{|character|
    #      puts character.name
    #  }
    class API
        attr_accessor :userid, :key, :scope
        
        # constructor
        # Expects:
        # * userid (String | Integer) the users id
        # * key (String) the apikey Full or Restricted
        # * scope (String) defaults to account
        def initialize(userid, key, scope="account")
            self.userid = userid.to_s
            self.key = key.to_s
            self.scope = scope.to_s
        end
        
        # create an xml request according to the method called
        # this is used to dynamicaly create api calls and 
        # should usually not be called directly
        # * method (const) 
        # * args 
        def method_missing(method, *args)
            scope = self.scope
            args_hash = args.first
            args_hash = {} unless args_hash
            self.request_xml(scope, method.id2name, args_hash)
        end
      
        # make a request to the api. will use cache if set.
        # usually not called by the user directly
        # * scope (String)
        # * name (String)
        # * opts (Hash)
        def request_xml(scope, name, opts)
            opts = EAAL.additional_request_parameters.merge(opts)
            xml = EAAL.cache.load(self.userid, self.key, scope, name,opts)
            if not xml
              source = URI.parse(EAAL.api_base + scope + '/' + name +'.xml.aspx')
              req_path = source.path + format_url_request(opts.merge({
                  :userid => self.userid, 
                  :apikey => self.key}))
              req = Net::HTTP::Get.new(req_path)
              req[EAAL.version_string]
              res = Net::HTTP.new(source.host, source.port).start {|http| http.request(req) } #one request for now  
              case res
              when Net::HTTPOK
              when Net::HTTPNotFound
                raise EAAL::Exception::APINotFoundError.new("The requested API (#{scope} / #{name}) could not be found.")
              else 
                raise EAAL::Exception::HTTPError.new("An HTTP Error occured, body: " + res.body)
              end
              EAAL.cache.save(self.userid, self.key, scope,name,opts, res.body)
              xml = res.body
            end
            doc = Hpricot.XML(xml)
            result = EAAL::Result.new(scope.capitalize + name, doc)
        end
                
        # Turns a hash into ?var=baz&bam=boo
        # stolen from Reve (thx lisa)
        # * opts (Hash)
        def format_url_request(opts)
            req = "?"
            opts.stringify_keys!
            opts.keys.sort.each do |key|
                req += "#{CGI.escape(key.to_s)}=#{CGI.escape(opts[key].to_s)}&" if opts[key]
            end
            req.chop # We are lazy and append a & to each pair even if it's the last one. FIXME: Don't do this.
        end
    end
end

#--
# EAAL by Peter Petermann <PeterPetermann@gmx.net>
# This library is licensed under the terms found in
# the LICENSE file distributed with it
#++
require 'fileutils'

module EAAL
  # The Classes in this module are objects that may be used as value
  # of EAAL.cache.
  # By default EAAL uses the NoCache class, where no caching is done.
  # If a working cache class is used it will store the xml data
  # and return it, so no requests to the API are done (as long as valid xml is available)
  module Cache
    
    # EAAL::Cache::FileCache
    # File based xml cache which respects the cachedUntil of the Eve API
    # Usage:
    #  EAAL.cache = EAAL::Cache::FileCache.new
    # Or
    #  EAAL.cache = EAAL::Cache::FileCache.new("/path/to/place/to/store/xml/data")
    class FileCache
      attr_accessor :basepath
      
      # constructor, takes one argument which is the path
      # where files should be written
      # * basepath (String) path which should be used to store cached data. defaults to $HOME/.eaal/cache/
      def initialize(basepath = "#{ENV['HOME']}/.eaal/cache")
        if basepath[(basepath.length) -1, basepath.length] != "/"
          basepath += "/" 
        end
        @basepath = basepath
      end
      
      # create the path/filename for the cache file
      def filename(userid, apikey, scope, name, args)
        ret =""
        args.delete_if { |k,v| (v || "").to_s.length == 0 }
        h = args.stringify_keys
        ret += h.sort.flatten.collect{ |e| e.to_s }.join(':')
        hash = ret.gsub(/:$/,'')
        "#{@basepath}#{userid}/#{apikey}/#{scope}/#{name}/Request_#{hash}.xml"
      end
      
      # load xml if available, return false if not available, or cachedUntil ran out
      def load(userid, apikey, scope, name, args)
        filename = self.filename(userid, apikey,scope,name,args)
        if not File.exist?(filename)
          ret = false
        else
          xml = File.open(filename).read
          if self.validate_cache(xml, name)
            ret = xml
          else
            ret = false
          end
        end
        ret
      end
      
      # validate cached datas cachedUntil
      def validate_cache(xml, name)
        doc = Hpricot.XML(xml)
	if name == "WalletJournal"
          Time.at((doc/"/eveapi/cachedUntil").inner_html.to_time.to_i + 3600) > Time.now
        else 
	  (doc/"/eveapi/cachedUntil").inner_html.to_time > Time.now
	end
      end
      
      # save xml data to file
      def save(userid, apikey, scope, name, args, xml)
        filename = self.filename(userid, apikey,scope,name,args)
        FileUtils.mkdir_p(File.dirname(filename))
        File.open(filename,'w') { |f| f.print xml }        
      end
    end
    
    # NoCache class
    # dummy class which is used for non-caching behaviour (default)
    class NoCache
      def load(userid, apikey, scope, name, args)
        false
      end
      def save(userid, apikey, scope, name, args, xml)
      end
    end
    
  end
end

# EAAL::API class
# Usage Example:
#  api = EAAL::API.new("my keyID", "my API key")
#  result = api.Characters
#  result.characters.each{|character|
#      puts character.name
#  }
class EAAL::API
  attr_accessor :keyid, :vcode, :scope

  # constructor
  # Expects:
  # * keyID (String | Integer) the keyID
  # * vCode (String) the vCode
  # * scope (String) defaults to account
  def initialize(keyid = nil, vcode = nil, scope="account")
    keyid ||= EAAL.config.keyid
    vcode ||= EAAL.config.vcode
    scope = EAAL.config.scope if EAAL.config.scope
    raise ArgumentError, 'Must specify keyid and vcode' unless keyid && vcode
    self.keyid = keyid.to_s
    self.vcode = vcode.to_s
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
    cache_only = (args_hash && args_hash.delete(:cache_only)) || false
    args_hash = {} unless args_hash
    self.request_xml(scope, method.id2name, args_hash, cache_only)
  end

  # make a request to the api. will use cache if set.
  # usually not called by the user directly
  # * scope (String)
  # * name (String)
  # * opts (Hash)
  def request_xml(scope, name, opts, cache_only = false)
    opts = EAAL.additional_request_parameters.merge(opts)
    xml = EAAL.cache.load(self.keyid, self.vcode, scope, name,opts)

    if (not xml) && (not cache_only)
      
      conn = Faraday.new(:url => "#{EAAL.api_base}") do |faraday|
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end

      response = conn.get(
        request_path(name), 
        opts.merge({
          :keyid => self.keyid,
          :vcode => self.vcode}))
      
      case response.status
      when 200
        # Nothing
      when 404
        raise EAAL::Exception::APINotFoundError.new("The requested API (#{scope} / #{name}) could not be found.")
      else
        raise EAAL::Exception::HTTPError.new("An HTTP Error occured, body: " + response.body)
      end

      EAAL.cache.save(self.keyid, self.vcode, scope,name,opts, response.body)
      xml = response.body
    end

    if xml
      doc = Hpricot.XML(xml)
      result = EAAL::Result.new(scope.capitalize + name, doc)
    else 
      result = nil
    end
  end

  def request_path(name)
    "/#{scope}/#{name}.xml.aspx"
  end

end

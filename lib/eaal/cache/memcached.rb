# EAAL::Cache::Memcached
# Cache class to allow use of Memcached server(s) as a local cache option.
require 'memcache'
class EAAL::Cache::MemcachedCache

  def initialize(servers="localhost:11211",options={})
    o = {:namespace => 'eaal'}.merge(options)
    $cache = MemCache.new(servers,o)
  end
  # Returns the memcached key for a given set of args.
  # Does not use the full API key string as the risk of a collision is astronomically high.
  def key(userid, apikey, scope, name, args)
    "#{userid}#{apikey[0..25]}#{scope}#{name}#{args}"
  end
  # Saves to cache. It is worth noting that memcached handles expiry for us unlike FileCache
  # as a result, there is no requirement for a validate_cache method- we just get MC to expire
  # the key when we can go get a new copy.
  def save(userid, apikey, scope, name, args, xml)
    k = key(userid, apikey, scope, name, args)
    cached_until = xml.match(/<cachedUntil>(.+)<\/cachedUntil>/)[1].to_time
    expires_in = (name=='WalletJournal' ? cached_until.to_i+3600 : cached_until.to_i )
    $cache.delete(k)
    $cache.add(k,xml,expires_in)
  end

  # Loads from the cache if there's a value for it.
  def load(userid, apikey, scope, name, args)
    k = key(userid, apikey, scope, name, args)
    ($cache.get(k) or false) rescue false
  end
end

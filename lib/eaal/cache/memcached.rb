# EAAL::Cache::Memcached
# Cache class to allow use of Memcached server(s) as a local cache option.

class EAAL::Cache::MemcachedCache
  attr_accessor :servers
  def initialize
    
  end
  def save(userid, apikey, scope, name, args, xml)
    
  end
  # load xml if available, return false if not available, or cachedUntil ran out
  def load(userid, apikey, scope, name, args)
    
  end
end
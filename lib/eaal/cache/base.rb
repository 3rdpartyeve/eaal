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


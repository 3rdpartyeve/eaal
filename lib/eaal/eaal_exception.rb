#--
# EAAL by Peter Petermann <PeterPetermann@gmx.net>
# This library is licensed under the terms found in
# the LICENSE file distributed with it
#++
module EAAL
  module Exception
    # creates the class for an EveAPIException
    def self.EveAPIException(nr)
      classname = "EveAPIException#{nr}" 
      if not Object.const_defined? classname
          klass = Object.const_set(classname, Class.new(EAAL::Exception::EveAPIException))
      else
          klass = Object.const_get(classname)
      end
      klass
    end
    
    # raise the eve API exceptions, class will be dynamicaly created by classname
    # EveAPIException followed by the APIs exception Number
    def self.raiseEveAPIException(nr, msg)
        raise EAAL::Exception.EveAPIException(nr).new(msg)
    end
    
    # all EAAL exceptions should extend this.
    class EAALError < StandardError
    end
    
    # Used when an http error is encountered
    class HTTPError < EAALError
    end
    
    # Used when the Eve API returns a 404
    class APINotFoundError < HTTPError
    end
    
    # All API Errors should be derived from this
    class EveAPIException < EAALError
    end
      
  end
end
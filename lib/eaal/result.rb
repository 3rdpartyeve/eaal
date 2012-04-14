#--
# EAAL by Peter Petermann <PeterPetermann@gmx.net>
# This library is licensed under the terms found in
# the LICENSE file distributed with it
#++
module EAAL

    module Result

        # base class for automated result class creation
        class ResultBase
            attr_accessor :request_time, :cached_until
        end

        # Result Container class, ...
        class ResultContainer
            attr_accessor :container

            def initialize
                self.container = {}
            end

            def add_element(key, val)
                self.container.merge!({key => val})
            end

            def method_missing(method, *args)
                self.container[method.id2name]
            end
        end

        # result element
        class ResultElement
            attr_accessor :name, :value, :attribs
            def initialize(name, value)
                self.name = name
                self.value = value
                self.attribs = {}
            end

            def add_attrib(key, val)
                self.attribs.merge!({key => val})
            end

            def method_missing(method, *args)
                if self.attribs.has_key?(method.id2name)
                    self.attribs[method.id2name]
                else
                    self.value.send(method, *args)
                end

            end

            # parses an xml element to create either the ResultElement, ResultContainer or Rowset
            # necessary
            def self.parse_element(prefix, element)
                if element.name == "rowset" then
                    re = EAAL::Rowset.new(prefix, element)
                else
                    key = element.name
                    if element.children && element.containers.length > 0
                        container = ResultContainer.new
                        element.containers.each { |celement|
                            cel = EAAL::Result::ResultElement.parse_element(prefix, celement)
                            if celement.attributes.to_hash.length > 0
                                container.add_element(cel.name, cel)
                            else
                                container.add_element(cel.name, cel.value)
                            end
                        }
                        value = container
                    else
                        value = element.inner_html.gsub(/\W+/, "") #Mainly to filter tags within description element in corporationsheet.
                    end
                    re = ResultElement.new(key, value)
                    if element.attributes.to_hash.length > 0
                        re.attribs.merge!(element.attributes.to_hash)
                    end
                end
                re
            end
        end

	      # create a new result derived from ResultBase
        def self.new(prefix, xml)
            classname = prefix + 'Result'
            members = []
            values = {}
            if (xml/"eveapi/error").length > 0
              error = (xml/"eveapi/error").first
              raise EAAL::Exception.raiseEveAPIException(error["code"], error.inner_html)
            end
            if (xml/"eveapi/result").length < 1
              raise EAAL::Exception::EAALError.new("Unknown API error, no result element was found")
            end
            elements = (xml/"eveapi/result").first.containers
            elements.each {|element|
                el = EAAL::Result::ResultElement.parse_element(prefix, element)
                members << el.name
                if el.kind_of? EAAL::Rowset::RowsetBase
                    values.merge!({el.name => el})
                else
                    values.merge!({el.name => el.value})
                end
            }
            if not Object.const_defined? classname
                klass = Object.const_set(classname, Class.new(EAAL::Result::ResultBase))
                klass.class_eval do
                    attr_accessor(*members)
                end
            else
                klass = Object.const_get(classname)
            end
            result = klass.new
            result.request_time = (xml/"eveapi/currentTime").first.inner_html
            result.cached_until = (xml/"eveapi/cachedUntil").first.inner_html
            values.each { |key,value|
                result.send(key + "=", value)
            }
            result
        end
    end
end

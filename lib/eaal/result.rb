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
            attr_accessor :container, :attribs

            def initialize
                self.container = {}
                self.attribs = {}
            end

            def add_element(key, val)
                self.container.merge!({key => val})
            end

            def method_missing(method, *args)
                if self.attribs.has_key?(method.id2name)
                    self.attribs[method.id2name]
                else
                    self.container[method.id2name]
                end
            end

            def to_hash
                if self.container == {}
                    vars = self.instance_variables
                    vars.delete_at(0) # delete container var name
                    vars.each {|v| self.container[v.to_s.gsub("@","")] = self.instance_variable_get v }
                end
                return self.container.dup
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
                        # Mainly to filter HTML tags within description element in corporationsheet.
                        value = element.inner_html.gsub(/(<|&lt;)(.|\n)*?(>|&gt;)/, "")
                    end
                    re = ResultElement.new(key, value)
                    if element.attributes.to_hash.length > 0
                        re.attribs.merge!(element.attributes.to_hash)
                        if re.value.respond_to?(:attribs)
                            re.value.attribs.merge!(element.attributes.to_hash)
                        end
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
                # This class may have been set up with some missing keys if the original
                # response that trigged its creation didn't contain certain elements
                # For example, some CharacterSheets don't have an "allianceName" element
                # if the character isn't in an alliance.  This adds them if they're missing
                if(!result.respond_to?("#{key}=".to_sym))
                    result.class.class_eval do
                        attr_accessor key.to_sym
                    end
                end
                result.send(key + "=", value)
            }
            result
        end
    end
end

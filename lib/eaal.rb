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
# Neat little hack to get around path issues on require
$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# External libs
require 'rubygems'
require 'hpricot'
require 'active_support'
require 'active_support/core_ext'
require 'net/http'
require 'net/https'
require 'uri'
require 'cgi'
# And now EAAL stuff
require 'eaal/cache/base'
require 'eaal/cache/file'
require 'eaal/cache/memcached'
require 'eaal/exception'
require 'eaal/result'
require 'eaal/rowset'
module EAAL
  mattr_reader :version_string
  VERSION = "0.1.10" # fix for Hoe.spec 2.x
  @@version_string = "EAAL" +  VERSION # the version string, used as client name in http requests

  mattr_accessor :api_base, :additional_request_parameters, :cache
  @@api_base = "https://api.eve-online.com/"  # the url used as basis for all requests, you might want to use gatecamper url or a personal proxy instead
  @@additional_request_parameters = {}       # hash, if :key => value pairs are added those will be added to each request
  @@cache = EAAL::Cache::NoCache.new         # caching object, see EAAL::Cache::FileCache for an Example
end
require 'eaal/api'

require 'rubygems'
require 'parseconfig'
require 'optparse'
require 'ostruct'
require 'fileutils'

require "../lib/modules/GenericApplication"
require "../lib/modules/IOHelper"
require "../lib/classes/CSSPrimer"

module Redcar
    class CSSPrimer
        def initialize
            @argv = []
        end
    end
end
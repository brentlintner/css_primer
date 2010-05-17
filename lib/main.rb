#!/usr/bin/ruby

require 'rubygems'

require 'optparse' 
require 'ostruct'
require 'parseconfig'
require 'fileutils'

require "modules/GenericApplication"
require "modules/IOHelper"
require "classes/CSSPrimer"

CSSPrimer.new(ARGV, STDIN).prime!


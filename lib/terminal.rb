#!/usr/bin/ruby

require 'optparse'
require 'ostruct'
require 'fileutils'

require "modules/GenericApplication"
require "modules/IOHelper"
require "classes/CSSPrimer"

CSSPrimer.new(ARGV).prime!


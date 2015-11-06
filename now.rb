require 'date'
require 'optparse'
require './sankeinews'

args = {}
opt = OptionParser.new
opt.on('-d date') {|v| args[:d] = v }
opt.parse!(ARGV)

date = (args[:d] ? Date.parse(args[:d]) : DateTime.now)
Sankei.new.news(date)

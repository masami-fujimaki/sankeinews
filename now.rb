require 'date'
require 'optparse'
require './sankeinews'

args = {}
opt = OptionParser.new
opt.on('-d VALUE', pat=/\d{4}-\d{1,2}-\d{1,2}/, desc="YYYY-MM-DD") {|v| args[:date] = v }
opt.on('-m VALUE', pat=/\d{4}-\d{1,2}/, desc="YYYY-MM") {|v| args[:month] = v }
opt.on('-y VALUE', pat=/\d{4}/, desc="YYYY") {|v| args[:year] = v }
opt.on('-n VALUE', pat=/[-]?\d+/, desc="number of days") {|v| args[:n] = v}
opt.parse!(ARGV)

date = (args[:date] ? DateTime.parse(args[:date]) : DateTime.now)
n = args[:n].to_i

if n > 0
  s = date
  e = date + n
elsif n < 0
  s = date + n
  e = date
else
  s = date
  e = date
end
range = s..e

range.each do |d|
  puts d.strftime("%Y-%m-%d")
  Sankei.new.news(d)
end

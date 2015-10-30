require 'date'
require './sankeinews'

sankei = Sankei.new
(1..365).map{ |i|
   d = DateTime.now - i
   sankei.news(d)
}

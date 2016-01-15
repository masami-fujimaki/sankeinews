
require 'date'
require 'digest'
require 'json'
require 'mongo'
require 'pp'
require './noun'

Mongo::Logger.logger.level = ::Logger::FATAL
db = Mongo::Client.new(['127.0.0.1:27017'], :database=>'sankei')
col = db[:news]

path = "/home/ec2-user/sankeinews/news"
#path = "/home/masami/sankeinews/news"

Dir.glob(path+"/**/**").each { |e|
  next if FileTest.directory?(e)
  news = nil
  open(e, "r") { |f|
    news = JSON.load(f)
  }
  doc = col.find(:md5 => news['md5'])
  if doc.count == 0
    news['date'] = DateTime.parse(news['date'])
    news['text'].strip!
    news['nouns'] = Noun.analysis(news['text'])
    col.insert_one(news)
    puts news['category']+":"+news['date'].to_s
  end
}


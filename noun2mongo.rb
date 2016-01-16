
require 'date'
require 'bson'
require 'mongo'
require 'pp'

def update_col(col, news, category, nouns)
  nouns.each { |noun|
    dic = col.find({:noun => noun[:noun]}).limit(1)
    if dic.count == 0
      news_ids = news.find({:$and=>[{:category=>category}, {"nouns.noun"=>noun[:noun]}]}).map { |e| e[:_id] }
      col.insert_one({
        :noun => noun[:noun], 
        :feature => noun[:feature], 
        :count => news_ids.length(), 
        :news_ids => news_ids
      })
    end
  }
end


def revise_text(text)
  text.gsub(/【.*?】/, '')
end


Mongo::Logger.logger.level = ::Logger::FATAL
db = Mongo::Client.new(['127.0.0.1:27017'], :database=>'sankei')

['politics','economy','world','sports','entertainments','life','affairs'].each { |category|
  col = db[category]
  col.drop()
  col.indexes.create_one({:noun=>1}, :unique=>true)
  col.indexes.create_one({:count=>1})
  db[:news].find(:category => category).sort(:date => 1).each_with_index { |news, idx|
    puts "%s:%s" % [news['category'], news['date']]
    update_col(col, db[:news], category, news['nouns'])
  }
}

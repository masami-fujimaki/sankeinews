
require 'date'
require 'bson'
require 'mongo'
require 'pp'

require './noun'

def update_dictionary(dictionary, nouns, news)
  nouns.each { |noun|
    dic = dictionary.find({:noun => noun[:noun]}).limit(1)
    if dic.count == 0 
      dictionary.insert_one({:noun => noun[:noun], :feature => noun[:feature], :count => 1, :news_ids => [news[:_id]]})
    else
      dic.each { |e|
        id = e[:_id]
        if not e[:news_ids].include?(news[:_id])
          news_ids = e[:news_ids]
          news_ids << news[:_id]
          dictionary.update_one({:_id =>id}, {"$inc" => {:count => 1}, "$set" => {:news_ids => news_ids}})
        else
          #p "..."
        end 
      }
    end
  }
end


def revise_text(text)
  text.gsub(/【.*?】/, '')
end


Mongo::Logger.logger.level = ::Logger::FATAL
db = Mongo::Client.new(['127.0.0.1:27017'], :database=>'sankei')

['affairs','economy','entertainments','life','politics','sports','world'].each{ |category|
  dictionary = db[category]
  dictionary.drop()
  dictionary.indexes.create_one({:noun=>1}, :unique=>true)
  dictionary.indexes.create_one({:count=>1})
  db[:news].find(:category => category).sort(:date => 1).each_with_index { |news, idx|
    puts "%s:%s" % [news['category'], news['date']]
    nouns = Noun.analysis(revise_text(news['text']))
    update_dictionary(dictionary, nouns, news)
  }
}

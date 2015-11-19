
require 'date'
require 'bson'
require 'natto'
require 'mongo'
require 'pp'

def update_dictionary(db, nouns, news)
  nouns.each { |noun|
    dictionary= db[:dictionary]
    dic = dictionary.find({:noun => noun}).limit(1)
    if dic.count == 0 
      dictionary.insert_one({:noun => noun, :count => 1, :news_ids => [news[:_id]]})
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

Mongo::Logger.logger.level = ::Logger::FATAL
db = Mongo::Client.new(['127.0.0.1:27017'], :database=>'sankei')

natto = Natto::MeCab.new

db[:news].find().each { |news|
  p news['date'], news['category']
  nodes = []
  natto.parse(news['text']) { |n|
    nodes << { :surface => n.surface, :features => n.feature.split(",") }
  }

  nouns = []
  noun = nil
  nodes.each { |node|
    surface = node[:surface]
    features = node[:features]
    if features[0] == "名詞"
      if (features[1] == "接尾" or features[1] == "サ変接続")
         noun = (noun ? noun + surface : surface)
      elsif features[1] == "数"
         noun = (noun ? noun + surface : surface)
      elsif features[1] == "非自立" or features[1] == "代名詞" or features[1] == "副詞可能"
         next
      else 
         nouns << noun if noun
         noun = surface
      end 
    else
      nouns << noun if noun
      noun = nil
    end
  } 

  update_dictionary(db, nouns, news)
}

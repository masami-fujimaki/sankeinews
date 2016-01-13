
require 'date'
require 'bson'
require 'natto'
require 'mongo'
require 'pp'

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

def analysis(db, category, dictionary, natto)
  db[:news].find(:category => category).sort(:date => 1).each_with_index { |news, idx|
    puts "%06d-%s:%s" % [idx, news['category'], news['date']]
    nodes = []
    natto.parse(revise_text(news['text'])) { |n|
      nodes << { :surface => n.surface, :features => n.feature.split(",") }
    }

    nouns = []
    noun = nil
    feature = nil
    nodes.each { |node|
      surface = node[:surface]
      features = node[:features]
      if features[0] == "名詞"
        if features[1] == "接尾" or features[1] == "サ変接続" or features[1] == "数"
          noun = (noun ? noun + surface : surface)
          feature = (feature ? feature + features[1] : features[1])
        elsif features[1] == "非自立" or features[1] == "代名詞"
          next
        else 
          nouns << {:noun=>noun, :feature=>feature} if noun
          noun = surface
          feature = features[1]
        end 
      else
        nouns << {:noun=>noun, :feature=>feature} if noun
        noun = nil
        feature = nil
      end
    } 

    update_dictionary(dictionary, nouns, news)
  }
end


Mongo::Logger.logger.level = ::Logger::FATAL
db = Mongo::Client.new(['127.0.0.1:27017'], :database=>'sankei')

natto = Natto::MeCab.new

#['affairs','economy','entertainments','life','politics','sports','world'].each{ |category|
['world'].each{ |category|
  dictionary = db[category]
  dictionary.drop()
  dictionary.indexes.create_one({:noun=>1}, :unique=>true)
  dictionary.indexes.create_one({:count=>1})
  analysis(db, category, dictionary, natto)
}

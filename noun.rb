
require 'date'
require 'natto'
require 'pp'

module Noun


  def self.add_nouns(noun,feature)
    @nouns.each { |e|
      if e[:noun] == noun
         e[:count] += 1
         return 
      end
    }
    @nouns << {:noun => noun, :feature => feature, :count => 1}
  end

  def analysis(text)
    natto = Natto::MeCab.new

    nodes = []
    natto.parse(text) { |n|
      nodes << { :surface => n.surface, :features => n.feature.split(",") }
    }

    @nouns = []
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
          add_nouns(noun, feature) if noun
          noun = surface
          feature = features[1]
        end 
      else
        add_nouns(noun, feature) if noun
        noun = nil
        feature = nil
      end
    } 

    @nouns
  end


  module_function :analysis
end

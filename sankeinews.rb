
require 'date'
require 'digest'
require 'fileutils'
require 'json'
require 'oga'
require 'open-uri'
require 'optparse'

class Sankei

@@urls = {
    "affairs"=>"http://www.sankei.com/affairs/news/{0:%y%m%d}/afr{0:%y%m%d}{1:0>4}-n1.html",
    "politics"=>"http://www.sankei.com/politics/news/{0:%y%m%d}/plt{0:%y%m%d}{1:0>4}-n1.html",
    "world"=>"http://www.sankei.com/world/news/{0:%y%m%d}/wor{0:%y%m%d}{1:0>4}-n1.html",
    "economy"=>"http://www.sankei.com/economy/news/{0:%y%m%d}/ecn{0:%y%m%d}{1:0>4}-n1.html",
    "sports"=>"http://www.sankei.com/sports/news/{0:%y%m%d}/spo{0:%y%m%d}{1:0>4}-n1.html",
    "entertainments"=>"http://www.sankei.com/entertainments/news/{0:%y%m%d}/ent{0:%y%m%d}{1:0>4}-n1.html",
    "life"=>"http://www.sankei.com/life/news/{0:%y%m%d}/lif{0:%y%m%d}{1:0>4}-n1.html"
}

@@news_path = "/home/fujimaki/news_p"

#
# urlからニュースのタイトルと本文、掲載日時を取得します。
#
def get_news(handle)
    html = Oga.parse_xml(handle)
    [
        html.css("article h1").text,
        html.css(".fontMiddiumText").text,
        html.css("time").text(),
    ]
end

def urls()
    {
    "affairs"=>"http://www.sankei.com/affairs/news/{0:%y%m%d}/afr{0:%y%m%d}{1:0>4}-n1.html",
    "politics"=>"http://www.sankei.com/politics/news/{0:%y%m%d}/plt{0:%y%m%d}{1:0>4}-n1.html",
    "world"=>"http://www.sankei.com/world/news/{0:%y%m%d}/wor{0:%y%m%d}{1:0>4}-n1.html",
    "economy"=>"http://www.sankei.com/economy/news/{0:%y%m%d}/ecn{0:%y%m%d}{1:0>4}-n1.html",
    "sports"=>"http://www.sankei.com/sports/news/{0:%y%m%d}/spo{0:%y%m%d}{1:0>4}-n1.html",
    "entertainments"=>"http://www.sankei.com/entertainments/news/{0:%y%m%d}/ent{0:%y%m%d}{1:0>4}-n1.html",
    "life"=>"http://www.sankei.com/life/news/{0:%y%m%d}/lif{0:%y%m%d}{1:0>4}-n1.html"
    }
end

def path()
    "/home/fujimaki/news_p"
end

def news(date)
    urls().each{|category,v|
        path = File.join([path(), category, date.strftime("%y%m%d")])
        FileUtils.makedirs(path)
        (1..10000).each{|n|
            url = v.gsub("{0:%y%m%d}", date.strftime("%y%m%d")).gsub("{1:0>4}", sprintf("%04d", n))
            begin
                title, text, date_time = get_news(open(url))
                Date.parse(date_time)
            rescue => e
                break
            end
            md5 = Digest::MD5.new.update(text).to_s
            h =  {"category"=>category,"date"=>date_time,"title"=>title,"text"=>text,"url"=>url,"md5"=>md5}
            open(File.join([path,md5]), "w") { |fp|
                JSON.dump(h, fp)
            }
            puts url 
        }
    }
end

end

#args = {}
#opt = OptionParser.new
#opt.on('-d date') {|v| args[:d] = v }
#opt.parse!(ARGV)

#date = (args[:d] ? Date.parse(args[:d]) : DateTime.now)
#sankei = Sankei.new.execute(date)




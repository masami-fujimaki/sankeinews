# -*- coding: UTF-8 -*-

import argparse
import codecs
import dateutil.parser
import datetime
import hashlib
import json
import os
from pyquery import PyQuery as pq
import urllib2
import sys

urls = [
        ["affairs","http://www.sankei.com/affairs/news/{0:%y%m%d}/afr{0:%y%m%d}{1:0>4}-n1.html"],
        ["politics","http://www.sankei.com/politics/news/{0:%y%m%d}/plt{0:%y%m%d}{1:0>4}-n1.html"],
        ["world","http://www.sankei.com/world/news/{0:%y%m%d}/wor{0:%y%m%d}{1:0>4}-n1.html"],
        ["economy","http://www.sankei.com/economy/news/{0:%y%m%d}/ecn{0:%y%m%d}{1:0>4}-n1.html"],
        ["sports","http://www.sankei.com/sports/news/{0:%y%m%d}/spo{0:%y%m%d}{1:0>4}-n1.html"],
        ["entertainments","http://www.sankei.com/entertainments/news/{0:%y%m%d}/ent{0:%y%m%d}{1:0>4}-n1.html"],
        ["life","http://www.sankei.com/life/news/{0:%y%m%d}/lif{0:%y%m%d}{1:0>4}-n1.html"],
       ]

paths = ["/home/fujimaki/news", "/{0}", "/{0:%y%m%d}"]


def get_news(url, category, date):
    news = []
    for n in range(1,10000):
        try:
    	    news_url = url.format(date, n)
            print news_url
            d =  pq(news_url)
        except urllib2.HTTPError:
            break

        try:
           #message = d(".fontMiddiumText").text().encode('latin1').decode('utf-8')
           message = d(".fontMiddiumText").text().encode('latin1')
        except UnicodeDecodeError:
           continue
           #raise
           
        if message is None or message == "":
           break
        m = hashlib.md5()
        #m.update(message.encode('utf-8'))
        m.update(message)
        news.append({
            "category": category,
            "date": "{0:%Y-%m-%d}".format(date),
            "text":  message,
            "md5": m.hexdigest(),
            "url": news_url,
        })
    return news

def _check_dir(path):
    if not os.path.exists(path):
        os.mkdir(path)
    return path
       
def execute(date):
    for category, url in urls:
        path = _check_dir(paths[0])
        path = _check_dir(path+paths[1].format(category))
        path = _check_dir(path+paths[2].format(date))

        for news in get_news(url, category, date):
            fp = open(path+"/"+news["md5"], "w") 
            json.dump(news, fp)
            fp.close()

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("date", nargs='?', help="news date")
    args = p.parse_args()
    if args.date:
        date = dateutil.parser.parse(args.date)
    else:
        date = datetime.date.today()

    execute(date)

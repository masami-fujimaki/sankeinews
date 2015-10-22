# -*- coding: UTF-8 -*-

import argparse
import dateutil.parser
import datetime
import hashlib
import json
import os
from pyquery import PyQuery as pq
import urllib2
import sys

urls = [
        {"affairs","http://www.sankei.com/affairs/news/{0:%y%m%d}/afr{0:%y%m%d}{1:0>4}-n1.html"},
       ]

paths = ["./news", "/{0}", "/{0:%y%m%d}"]

def get_news(url, category, date):
    news = []
    for n in range(1,10000):
        try:
    	    news_url = url.format(date, n)
            print news_url
            d =  pq(news_url)
        except urllib2.HTTPError:
            break

        message = d(".fontMiddiumText").text()
        if message is None or message == "":
           break
        m = hashlib.md5()
        m.update(message.encode('utf-8'))
        news.append({"category": category, "date": "{0:%Y-%m-%d}".format(date), "text":  message, "md5": m.hexdigest()})
    return news

def _check_dir(path):
    if not os.path.exists(path):
        os.mkdir(path)
    return path
       
if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("date", nargs='?', help="news date")
    args = p.parse_args()
    if args.date:
        date = dateutil.parser.parse(args.date)
    else:
        date = datetime.date.today()
    print date

    path = _check_dir(paths[0])
 
    for category, url in urls:
        path = _check_dir(path+paths[1].format(category))
        path = _check_dir(path+paths[2].format(date))

        for news in get_news(url, category, date):
            fp = open(path+"/"+news["md5"],"w")
            json.dump(news, fp)
            fp.close()

# -*- coding: utf-8 -*-

from datetime import datetime
import json
import os
from pymongo import MongoClient
import sys

pathes = [
    "/home/fujimaki/news_p/politics",
    "/home/fujimaki/news_p/world",
    "/home/fujimaki/news_p/economy",
    "/home/fujimaki/news_p/sports",
    "/home/fujimaki/news_p/entertainments",
    "/home/fujimaki/news_p/line",
    "/home/fujimaki/news_p/affairs",
]

def read_news(f):
    with open(f, "r") as fp:
        news = json.load(fp)
    
    news['date'] = datetime.strptime(news['date'], "%Y.%m.%d %H:%M")
    return news

def insert_db(db, path):
    for (root, dirs, files) in os.walk(path):
        for file in files:
            news = read_news(os.path.join(root,file))
            try:
                if db.news.find({"md5": news['md5']}).count() == 0:
                    result = db.news.insert_one(news)
                    #print "insert-{0}".format(news['url'])
                else:
                    print "skip-{0}".format(os.path.join(root,file))
            except:
                print os.path.join(root,file)
                raise

if __name__ == "__main__":
    client = MongoClient()
    db = client.sankei

    # create index
    db.news.create_index("date")
    db.news.create_index("md5")

    for path in pathes:
        insert_db(db, path)


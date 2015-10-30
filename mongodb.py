# -*- coding: utf-8 -*-

from datetime import datetime
import json
import os
from pymongo import MongoClient
import sys

path = "/home/fujimaki/news_p"

def read_news(f):
    with open(f, "r") as fp:
        news = json.load(fp)
    
    print f
    news['date'] = datetime.strptime(news['date'], "%Y.%m.%d %H:%M")
    return news

if __name__ == "__main__":
    client = MongoClient()
    db = client.test

    for (root, dirs, files) in os.walk(path):
        for file in files:
            news = read_news(os.path.join(root,file))
            try:
                print news['url']
                result = db.news.insert_one(news)
            except:
                print os.path.join(root,file)
                raise



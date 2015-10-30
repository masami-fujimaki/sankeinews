# -*- coding: utf-8 -*-

import codecs
import json
import os
import sys

#path = "./news"
path = "/home/fujimaki/news_p"

if __name__ == "__main__":
    for (root, dirs, files) in os.walk(path):
        for file in files:
            with open(os.path.join(root,file), "r")  as fp:
                try:
                   news = json.load(fp)
                except:
                   print os.path.join(root, file)
                   raise
                   #continue
                print "-----------------------------------"
                print news["url"]
                print news["title"]
                print news["text"]
             

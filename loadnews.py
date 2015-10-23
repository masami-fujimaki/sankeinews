# -*- coding: utf-8 -*-

import json
import os
import sys

path = "/home/fujimaki/news/affairs/"

if __name__ == "__main__":
    for (root, dirs, files) in os.walk(path):
        for file in files:
            fp = open(os.path.join(root,file), "r") 
            news = json.load(fp)
            print news["text"]
            fp.close()
            sys.exit(0)
             

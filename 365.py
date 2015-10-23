# -*- coding:utf-8 -*-

import datetime
import sankeinews

base = datetime.datetime.today()
for date in [base - datetime.timedelta(days=x) for x in range(0, 364)]:
    sankeinews.execute(date)  

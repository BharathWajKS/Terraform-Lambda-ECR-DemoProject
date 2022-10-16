from urllib.request import urlopen
# import requests  # (planning to use requests instead of urllib)
import json
import time
import datetime

def set_start_unix_time(h = 1):  
    last_hour_date_time = datetime.datetime.now() - datetime.timedelta(minutes = h*60)
    unixtime = time.mktime(last_hour_date_time.timetuple())
    return unixtime

def get_item(url):
    webUrl = urlopen(url)
    if (webUrl.getcode() == 200):
        data  = webUrl.read().decode('utf-8')
    else:
        raise ConnectionError("Error {} from server, cannot retrieve results ".format(str(webUrl.getcode())))
    item = json.loads(data)
    return item 

def get_url(t):
    url = "https://hacker-news.firebaseio.com/v0/item/" + str(t) + ".json?print=pretty"
    return url

def handler(event, context):
    current_unixtime = int(time.time())
    print("current_unixtime = %s" %current_unixtime)

    # Set start unixtime
    # past hours : h
    h = float(event['hour'])
    start_time = set_start_unix_time(h)
    print("start_time = %s" %start_time)

    # Max Item ID
    url = "https://hacker-news.firebaseio.com/v0/maxitem.json?print=pretty"
    max_item_id = get_item(url)
    print('max_item_id = %s' %max_item_id)

    # Bottom to top (child -> parent)
    # Starting from the current time (from child node) to the past h hours 
    # until the root parent (story). 
    # In the process, tracks the depth and get the max depth route,
    # and save the list of nodes of the IDs.
    max_depth = 0
    max_thread = []
    root_item = None
    for id in range(max_item_id,0,-1):
        depth = 0
        thread = [id]
        url =get_url(id)
        item = get_item(url)         
        if item['time'] > start_time:
            if item['type'] == "comment":  
                while "parent" in item:
                    parent_id = item['parent']
                    url =get_url(parent_id)
                    item = get_item(url)  
                    depth += 1
                    thread.append(parent_id)
                    if depth > max_depth:
                        max_depth = depth  
                        max_thread = thread
                        root_item = item 
            #else:
                    #print("current max_depth = %s" %max_depth)
                    #print("current thread = %s" %max_thread)
        else:
            break
      
    print("final max_depth = %s" %max_depth)
    print("final thread = %s" %max_thread)
    return {
        'past hour': h,
        'max_thread': max_thread,
        'root_item': root_item
    }
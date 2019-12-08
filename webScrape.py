#############
# ToDo:
#   Dedupe word list
#   Not exit when URL is unreachable
#	Check for https first
#	Get base URL w/o http/https


import re
import sys
import requests
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("URL", help="URL to start from")
parser.add_argument("-o", default="word.list", help="Location to save file (default=word.list")
parser.add_argument("-d", type=int, default=2, help="Depth to spider (default=2)")
parser.add_argument("-l", type=int, default=4, help="Length of word to search for (default=4)")
parser.add_argument("-v", help="Display verbose output", action="store_true")

args = parser.parse_args()

class webNode():
    def __init__(self, url, depth):
        self.url = url
        self.depth = depth

#def getContent(url):

def searchContent(data):
    regex = r"\b\w{%s,15}\b" % args.l
    words = re.findall(r"\b\w{%s,15}\b" % args.l,data)
    outfile = open(args.o,"a")
    for word in words:
        outfile.write(word+"\n\r")
    outfile.close()

def addURLs(hrefs):
    for urlItem in hrefs:
        shouldAdd = True
        newURL = urlItem.replace("href=",'').replace('"','',2)
        if args.URL in newURL and node.depth < args.d:
            for x in webListings:
                if newURL == x.url:
                    shouldAdd = False
            if shouldAdd:
                if args.v:
                    print "Adding URL: " + newURL
                webListings.append(webNode(newURL,node.depth+1))

# Adds first node into array
webListings = []
webListings.append(webNode(args.URL,0))

# Loops through each node dynamical
for node in webListings:

    # If verbose print logging information
    if args.v:
        print "Working on: " + node.url + ":" + str(node.depth)
    
    # Try website connection
    try:
        data = requests.get(node.url)
    except:
        print "Host unreachable:  " + node.url
        exit() #-------------------------------THAKE THIS LINE OUT AND JUST SKIP TO NEXT LOOP
    
    # Pull all href, parse down to just URL then add to webListings
    addURLs(re.findall('href=".+?"',data.text))
    searchContent(data.text)

    
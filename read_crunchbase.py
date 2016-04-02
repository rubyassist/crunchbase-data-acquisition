# Usage:
#    mkdir -p ./crunchbasedata
#    python read_crunchbase.py

import time
import os
import random
import sys
import json
import pandas as pd
import urllib2


# CrunchBase Key
# **** Replace the CB_KEY below with your API key ****
CB_KEY = '<insert key here>'  

DEST_DIR = './crunchbasedata'


# input: a url as a string
# output: returns the page object form urlopen
def get_page_from_url(url):
    request = urllib2.Request(url)
    try:
        page = urllib2.urlopen(request)
        break
    except urllib2.URLError, e:
        if hasattr(e, 'reason'):
            print 'Failed to reach url'
            print 'Reason: ', e.reason
        elif hasattr(e, 'code'):
            if e.code == 404:  # page not found
                print 'Error: ', e.code
            cnt -= 1
            if cnt == 0:
                return None
            time.sleep(2)

    return page.read()


def read_crunchbase():
    co_type = "company"
    global companies_df

    # change the page number(s) as necessary:
    start_page = 1
    end_page = 100
    for page_no in range(start_page, end_page):
        if page_no in last:
            continue

        companies_df = pd.DataFrame()

        url = "https://api.crunchbase.com/v/3/organizations?" \
              "organization_types=%s&page=%d&user_key=%s" % \
              (co_type, page_no, CB_KEY)
        print "working on URL: ", url

        page = get_page_from_url(url)
        if not page:
            continue

        decoded = page.decode('ASCII', 'ignore')
        print (decoded)
        results = json.loads(decoded, strict=False)['data']['items']

        for co in results:
            dic = co['properties']
            dic['uuid'] = co['uuid']
            companies_df = companies_df.append(co['properties'],
                                               ignore_index=True)

    print_info_to_csv(companies_df, page_no)


def print_info_to_csv(companies_df, page_no):
    fn = os.path.join(DEST_DIR, '%d.csv' % page_no)
    companies_df.to_csv(fn, encoding='utf-8')
    print 'Done, saved to ', fn


def get_all_files(dest):
    f = []
    for (dirpath, dirnames, filenames) in os.walk(dest):
        f.extend(filenames)
        break
    return f


def get_last_success(dest):
    f = get_all_files(dest)
    res = {}
    for fn in f:
        curr = int(fn.split('.')[0])
        res[curr] = True

    return res


def merge_csv(dest):
    f = get_all_files(dest)
    
    mn = -1
    mx = -1
    companies_df = pd.DataFrame()
    for fn in f:
        companies_df = companies_df.append(pd.read_csv(os.path.join(dest, fn)))
        curr = int(fn.split('.')[0])
        if mx == -1 or curr > mx:
            mx = curr
        if mn == -1 or curr < mn:
            mn = curr

    fn = 'getCompany%d_%d.csv' % (mn, mx)
    companies_df.to_csv(fn, encoding='utf-8')
    print 'Saved to', fn, 'in current dir.'


def main():
    last = get_last_success(DEST_DIR)
    read_crunchbase(last)
    merge_csv(DEST_DIR)


main()

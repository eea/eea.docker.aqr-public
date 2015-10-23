#!/usr/bin/env python

import re
import os
import xml
# based on https://github.com/hackorama/java-props-in-python/blob/master/jprops.py
def read_properties(filename):

    LINE_BREAKS = '\n\r\f' #end-of-line, carriage-return, form-feed
    ESC_DELIM = r'\\' # '\'
    ESCAPED_ESC_DELIM = r'\\\\' # '\\'
    COMMENT_LINE = re.compile('\s*[#!].*') # starts with #|! ignore white space
    MULTI_LINE = re.compile(r'.*[\\]\s*$') # ending with '\' ignore white space
    # non escaped  =|:|' ', include surrounding non escaped white space
    SPLIT_DELIM = re.compile(r'(?<!\\)\s*(?<!\\)[=: ]\s*')
    # match escape characters '\', except escaped '\\' and unicode escape '\u'
    VALID_ESC_DELIM = r'(?<!\\)[\\](?!u)'
    DEFAULT_ELEMENT = ''
    propfile = open(filename)
    result = {}
    natural_line = propfile.readline()
    while natural_line:
        # skip blank lines and comment lines, process only valid logical lines
        if natural_line.strip() and COMMENT_LINE.match(natural_line) is None:
            logical_line = natural_line.lstrip().rstrip(LINE_BREAKS)
            # remove multi line delim and append adjacent lines
            while MULTI_LINE.match(logical_line):
                logical_line = logical_line.rstrip()[:-1] + propfile.readline().lstrip().rstrip(LINE_BREAKS)
            pair = SPLIT_DELIM.split(logical_line, 1)
            if len(pair) == 1: pair.append(DEFAULT_ELEMENT)
            pair = [re.sub(VALID_ESC_DELIM, '', item) for item in pair]
            pair = [re.sub(ESCAPED_ESC_DELIM, ESC_DELIM, item) for item in pair]
            pair = [unicode(item, 'unicode_escape') for item in pair]
            result[pair[0]] = pair[1] # add key, element to result dict
        natural_line = propfile.readline()
    propfile.close()
    return result

if __name__ == "__main__":
    properties =  read_properties('/docker/deployment/papers/WEB-INF/classes/ecas-config.properties')

    server_name = os.getenv('SERVER_NAME')
    server_port = os.getenv('SERVER_PORT')
    service_url = os.getenv('SERVICE_URL')
    
    if(server_name):
        properties['edu.yale.its.tp.cas.client.filter.serverName']=server_name

    if(server_port):
        properties['eu.cec.digit.ecas.client.filter.serverPort']=server_port

    if(service_url):
        properties['edu.yale.its.tp.cas.client.filter.serviceUrl']=service_url

    f = open('/docker/deployment/papers/WEB-INF/classes/ecas-config.properties', 'w')
    for key in properties:
        value = properties[key]
        f.write("{}={}\n".format(key,value))
    f.close()

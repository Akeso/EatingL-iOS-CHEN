#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
import shutil
import getopt
import re
import json
import base64
from typing import ValuesView

contentDict = {"NSPhotoLibraryAddUsageDescription":"EATSystemAlbumAdd",
               "NSUserTrackingUsageDescription":"EATATTAlert"}

root_path = os.path.abspath(os.path.dirname(__file__))
out_path = os.path.join(root_path, '')
file_name = 'InfoPlist.strings'

origin_path = os.path.join(root_path, '../String')

files = os.listdir(out_path)
for file in files:
    if file.find('.lproj') != -1 :
        shutil.rmtree(os.path.join(out_path, file))

files = os.listdir(origin_path)
for file in files:
    if file.find('.lproj') == -1 :
        continue

    content = ""
    fkv = {}
    f = open(os.path.join(origin_path, file+'/Localizable.strings'), 'rt')
    try:
        while True:
            line = f.readline()
            if line:
                line = line.strip('\n')
                if '=' in line and ';' in line:
                    lines = line.split('=')
                    k = lines[0].strip().strip('"')
                    v = lines[-1].strip().strip(';')
                    fkv[k] = v
            else:
                break
    finally:
        f.close()

    for (ck, cv) in contentDict.items() :
        if cv in fkv:
            value = fkv[cv]
            if value is not None :
                content += ck+" = "+value+";\n"

    fn = file.split('.')[0]
    outnames = [fn]

    if fn == 'no':
        outnames = ['nb', 'nn']
    elif fn == 'en':
        outnames = ['en']
    elif fn == 'zh-TW':
        outnames = ['zh-Hant']
    
    for outname in outnames:
        out_dir = os.path.join(out_path, outname+'.lproj')
        os.mkdir(out_dir)
        if content is not None:
            fp = open(os.path.join(out_dir, file_name), 'w')
            fp.write(content)
            fp.close()




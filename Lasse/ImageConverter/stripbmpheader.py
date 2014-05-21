#!/usr/bin/env python

from sys import argv

headerData = None
rawData = None

with open(argv[1],'r') as bmpFile:
	fileContent = bmpFile.read()
	headerData = fileContent[0:54]
	rawData = fileContent[54:]

with open(argv[1] + 'raw','wb') as rawFile:
	rawFile.write(rawData)

with open(argv[1] + 'header','wb') as headerFile:
	headerFile.write(headerData)





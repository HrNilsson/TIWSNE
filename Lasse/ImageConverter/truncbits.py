#!/usr/bin/env python

import sys

trunc = int(sys.argv[2])

with open(sys.argv[1],'r') as bmpRawFile:
	fileContent = bmpRawFile.read()

	fileContent = bytearray(fileContent)

	for i in range(len(fileContent)):
		fileContent[i] = (fileContent[i] >> trunc) << trunc			

	with open(sys.argv[1] + 'truncated','wb') as truncFile:
		truncFile.write(fileContent)

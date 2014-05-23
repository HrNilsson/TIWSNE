#!/usr/bin/env python

import sys

with open(sys.argv[1],'r') as bmpRawFile:
	fileContent = bmpRawFile.read()

	fileContent = bytearray(fileContent)

	for i in range(len(fileContent)):
		fileContent[i] = (fileContent[i] >> 2) << 2			

	with open(sys.argv[1] + 'truncated','wb') as truncFile:
		truncFile.write(fileContent)

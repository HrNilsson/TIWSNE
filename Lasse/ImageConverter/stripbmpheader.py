#!/usr/bin/env python

//cat picheader picraw >> pic

import sys
import struct

headerData = None
rawData = None

with open(sys.argv[1],'r') as bmpFile:
	fileContent = bmpFile.read()

	if(fileContent[0] != 'B' or fileContent[1] != 'M'):
		sys.exit('Unknown format!')

	bitmapOffset = struct.unpack('<I', fileContent[10:14])[0]
	headerData = fileContent[0:bitmapOffset]
	rawData = fileContent[bitmapOffset:]

with open(sys.argv[1] + 'raw','wb') as rawFile:
	rawFile.write(rawData)

with open(sys.argv[1] + 'header','wb') as headerFile:
	headerFile.write(headerData)






#include "ImageTypes.h"


module QuantCompressC @safe() {
	
	provides interface QuantCompress;
	
	
}

implementation{
	
	command imageVector QuantCompress.compressVector(uint8_t * inputVec) {
		
		imageVector imVec;
		
		imVec.px0 = inputVec[0]>>2;
		imVec.px1 = inputVec[1]>>2;
		imVec.px2 = inputVec[2]>>2;
		imVec.px3 = inputVec[3]>>2;
		imVec.px4 = inputVec[4]>>2;
		imVec.px5 = inputVec[5]>>2;

		return imVec;
	}
}
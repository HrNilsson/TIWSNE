
module QuantCompressC @safe() {
	
	provides interface QuantCompress;
		
}

implementation {
	
	command imageVector QuantCompress.compressVector(nx_uint8_t * inputVec) {
	
		imageVector imVec;
	
		imVec.px0 = inputVec[0]>>2;
		imVec.px1 = inputVec[1]>>2;
		imVec.px2 = inputVec[2]>>2;
		imVec.px3 = inputVec[3]>>2;
		imVec.px4 = inputVec[4]>>2;

		imVec.notFull = 0;

		return imVec;
	}

	command void QuantCompress.deCompressVector(imageVector imVec, nx_uint8_t *outputVec){
	
		outputVec[0] = imVec.px0<<2;
		
		if (imVec.notFull < 3) {
			outputVec[1] = imVec.px1<<2;
			outputVec[2] = imVec.px2<<2;
			outputVec[3] = imVec.px3<<2;
			outputVec[4] = imVec.px4<<2;
		}
			
//		outputVec[1] = imVec.px1<<2;
//	
//		if (imVec.notFull < 3) {
//			outputVec[2] = imVec.px2<<2;
//	
//			if (imVec.notFull < 2) {
//				outputVec[3] = imVec.px3<<2;
//	
//				if (imVec.notFull < 1) {
//					outputVec[4] = imVec.px4<<2;
//				}
//			}
//		}
	}
}
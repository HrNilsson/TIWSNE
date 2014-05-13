#include "ImageTypes.h"

interface QuantCompress{

	command imageVector compressVector(uint8_t * inputVec);
	command void deCompressVector(imageVector, uint8_t * outputVec);


}
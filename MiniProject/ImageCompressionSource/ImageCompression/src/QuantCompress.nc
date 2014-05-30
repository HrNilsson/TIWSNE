#include "ImageCompression.h"

interface QuantCompress{

	command imageVector compressVector(nx_uint8_t * inputVec);
	command void deCompressVector(imageVector, nx_uint8_t * outputVec);


}
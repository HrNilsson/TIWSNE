#ifndef IMAGE_COMPRESSION_H
#define IMAGE_COMPRESSION_H

enum {
   AM_IMAGECOMPRESSION = 6
 };
 
 enum STATE {
 	IDLE,
 	
 	RECEIVING_FROM_PC,
 	SENDING_UNCOMPRESSED_TO_MOTE,
 	SENDING_COMPRESSED_TO_MOTE,
 	
 	RECEIVING_FROM_MOTE,
 	SENDING_UNCOMPRESSED_TO_PC,
 	SENDING_COMPRESSED_TO_PC 	
 };


typedef nx_struct imageVectors {
	
	// Six pixels in one structure
	uint8_t px0 : 6;
	uint8_t px1 : 6;
	uint8_t px2 : 6;
	uint8_t px3 : 6;
	uint8_t px4 : 6;
	
	// Fill to 32 bits
	uint8_t fill: 2;
	
} imageVector;

typedef nx_struct PictureMsg {
  nx_uint8_t pixels[113];
} PictureMsg;

typedef nx_struct CompressedPictureMsg {
	imageVector pixelVectors[28]; // 112 bytes  
} CompressedPictureMsg;

#endif /* IMAGE_COMPRESSION_H */

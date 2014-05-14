#ifndef IMAGE_COMPRESSION_H
#define IMAGE_COMPRESSION_H

enum AM_ID_TYPES {
   AM_COMPRESSED_IMAGE = 6,
   AM_UNCOMPRESSED_IMAGE = 7
 };
 
 enum STATE {
 	IDLE,
 	
 	RECEIVING_FROM_PC,
 	SENDING_UNCOMPRESSED_TO_MOTE,
 	SENDING_COMPRESSED_TO_MOTE,
 	
 	RECEIVING_FROM_MOTE,
 	SENDING_UNCOMPRESSED_TO_PC,
 	SENDING_COMPRESSED_TO_PC,
 	NUMBER_OF_STATES 	
 } STATE;
 
 enum WIRELESS_DEFINES {
 	TOTAL_UNCOMPRESSED_PACKETS = 586, // 256*256/(122 bytes pr. packet) 
 	TOTAL_COMPRESSED_PACKETS = 469, //Uncompressed*4/5 Assuming compression of << 2
 	NO_OF_UNCOMPRESSED_PIXELS = 110,
 	NO_OF_COMPRESSED_PIXELS = 27,
 	TIMEOUT_WAIT_FOR_ACK = 100,
 };
 
 enum MOTE_IDS {
 	AM_SENDER_ID = 49,  
 	AM_RECEIVER_ID = 37
 };


typedef nx_struct imageVectors {
	
	// Five pixels in one structure
	nx_uint8_t px0 : 6;
	nx_uint8_t px1 : 6;
	nx_uint8_t px2 : 6;
	nx_uint8_t px3 : 6;
	nx_uint8_t px4 : 6;
	
	// Fill to 32 bits
	nx_uint8_t fill: 2;
	
} imageVector;

typedef nx_struct UncompressedMsg {
  nx_uint8_t pixels[NO_OF_UNCOMPRESSED_PIXELS];
  nx_uint16_t seqNo;
} UncompressedMsg;

typedef nx_struct CompressedPictureMsg {
	imageVector pixelVectors[NO_OF_COMPRESSED_PIXELS]; // 108 bytes
	nx_uint16_t seqNo;  
} CompressedPictureMsg;

typedef nx_struct AckMsg {
	nx_uint8_t ack;  
} AckMsg;



#endif /* IMAGE_COMPRESSION_H */

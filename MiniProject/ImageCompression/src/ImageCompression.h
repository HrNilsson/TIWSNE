#ifndef IMAGE_COMPRESSION_H
#define IMAGE_COMPRESSION_H

enum AM_ID_TYPES {
   AM_COMPRESSED_IMAGE = 6,
   AM_UNCOMPRESSED_IMAGE,
 };
 
 enum STATE {
 	IDLE,
 	
 	RECEIVING_FROM_PC,
 	SENDING_UNCOMPRESSED_TO_MOTE,
 	SENDING_COMPRESSED_TO_MOTE,
 	
 	RECEIVING_UNCOMPRESSED_FROM_MOTE,
 	RECEIVING_COMPRESSED_FROM_MOTE,
 	SENDING_UNCOMPRESSED_TO_PC,
 	SENDING_COMPRESSED_TO_PC,
 	NUMBER_OF_STATES 	
 } STATE;
 
 enum WIRELESS_DEFINES {
 	TOTAL_UNCOMPRESSED_PACKETS = 596, // 256*256/(110 bytes pr. packet) 
 	TOTAL_COMPRESSED_PACKETS = 486, //Uncompressed*4/5 Assuming compression of << 2
 	NO_OF_UNCOMPRESSED_PIXELS = 110,
 	NO_OF_COMPRESSED_PIXELS = 27,
 	TIMEOUT_WAIT_FOR_ACK = 100,
 	UNCOMPRESSED_IMAGE_REST = 86,
 	COMPRESSED_IMAGE_REST = 52,
 };
 
 enum MOTE_IDS {
 	AM_SENDER_ID = 49,  
 	AM_RECEIVER_ID = 37
 };

typedef enum TaskFlag {
	INIT,
	READ_FLASH,
	SAVE_FLASH,
	COMPRESS,
	DECOMPRESS,
	SEND_PACKET,
	RETRANSMIT_PACKET,
	SEND_TO_PC,
	POST_TASK,
}TaskFlag;

typedef nx_struct imageVectors {
	
	// Five pixels in one structure
	nx_uint8_t px0 : 6;
	nx_uint8_t px1 : 6;
	nx_uint8_t px2 : 6;
	nx_uint8_t px3 : 6;
	nx_uint8_t px4 : 6;
	
	// Fill to 32 bits
	nx_uint8_t notFull: 2;
	
} imageVector;

typedef nx_struct UncompressedMsg {
  nx_uint8_t pixels[NO_OF_UNCOMPRESSED_PIXELS];
  nx_uint16_t seqNo;
} UncompressedMsg;

typedef nx_struct CompressedMsg {
	imageVector pixelVectors[NO_OF_COMPRESSED_PIXELS]; // 108 bytes
	nx_uint16_t seqNo;  
} CompressedMsg;

typedef nx_struct AckMsg {
	nx_uint16_t seqNo;  
} AckMsg;



#endif /* IMAGE_COMPRESSION_H */

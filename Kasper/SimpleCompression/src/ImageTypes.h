#ifndef IMAGE_TYPES_H
#define IMAGE_TYPES_H

#define SUCCES 1
#define FAIL 0


typedef struct imageVectors {
	
	// Five pixels in one structure
	uint8_t px0 : 6;
	uint8_t px1 : 6;
	uint8_t px2 : 6;
	uint8_t px3 : 6;
	uint8_t px4 : 6;
	
	// Fill to 32 bits
	uint8_t notFull: 2; // Number of empty px-elements
	
} imageVector;

#endif /* IMAGE_TYPES_H */

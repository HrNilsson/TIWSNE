#ifndef IMAGE_TYPES_H
#define IMAGE_TYPES_H

#include <stdio.h>
#define SUCCES 1
#define FAIL 0

typedef struct imageVectors {
	
	// Six pixels in one structure
	uint8_t px0 : 6;
	uint8_t px1 : 6;
	uint8_t px2 : 6;
	uint8_t px3 : 6;
	uint8_t px4 : 6;
	uint8_t px5 : 6;
	
	// Fill to 32 bits
	uint8_t fill: 2;
	
} imageVector;

#endif /* IMAGE_TYPES_H */

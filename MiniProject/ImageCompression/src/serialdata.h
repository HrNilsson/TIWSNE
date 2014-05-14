#ifndef SERIALDATA_H
#define SERIALDATA_H

enum { 	AM_SERIALDATA_MSG = 99,
	MAX_SERIALDATA_LENGTH = 112, //when TOSH_DATA_LENGTH is defined as 113(max) and reliable_msg(uses 1 byte for cookie field) is used.
	};

typedef nx_struct serialdata_msg {
  nx_uint8_t data[MAX_SERIALDATA_LENGTH]; 
} serialdata_msg_t;

#endif /* SERIALDATA_H */
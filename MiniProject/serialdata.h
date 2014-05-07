#ifndef SERIALDATA_H
#define SERIALDATA_H

enum { AM_SERIALDATA_MSG = 99 };

typedef nx_struct serialdata_msg {
  nx_uint8_t data[];
} serialdata_msg_t;

#endif /* SERIALDATA_H */

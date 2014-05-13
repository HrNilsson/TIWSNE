#ifndef TEMPERATUREMEAS_H
 #define TEMPERATUREMEAS_H
 
 enum {
   AM_TEMPERATURE_MEAS = 6,
   TIMER_PERIOD_MILLI = 1000
 };
 
 typedef nx_struct TemperatureMeasMsg {
  nx_uint16_t nodeid;
  nx_uint16_t reading;
} TemperatureMeasMsg;

#endif
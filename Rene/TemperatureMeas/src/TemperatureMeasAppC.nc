#include <Timer.h>
 #include "TemperatureMeas.h"
 
 configuration TemperatureMeasAppC {
 }
 implementation {
   components MainC;
   components LedsC;
   components TemperatureMeasC as App;
   components new TimerMilliC() as Timer0;
   components ActiveMessageC;
   components new AMSenderC(AM_TEMPERATURE_MEAS);
   components new SensirionSht11C() as Sensor;
 
   App.Boot -> MainC;
   App.Leds -> LedsC;
   App.Timer0 -> Timer0;
   App.Packet -> AMSenderC;
   App.AMPacket -> AMSenderC;
   App.AMSend -> AMSenderC;
   App.AMControl -> ActiveMessageC;
   App.Read -> Sensor.Temperature;
 }
#include "ImageCompression.h"

configuration ImageCompressionAppC{
}
implementation{
	components MainC;
   	components LedsC;
	components UserButtonC;
   	components ImageCompressionC as App;
   	components ActiveMessageC;
   	components new AMSenderC(AM_IMAGECOMPRESSION);
   	components new AMReceiverC(AM_IMAGECOMPRESSION);
   	
   	App.Boot -> MainC;
   	App.Leds -> LedsC;
   	App.GetButton -> UserButtonC; 
   	App.NotifyButton -> UserButtonC; 
   	App.Packet -> AMSenderC;
   	App.AMPacket -> AMSenderC;
   	App.AMSend -> AMSenderC;
   	App.AMControl -> ActiveMessageC;
   	App.Receive -> AMReceiverC;
   	
}
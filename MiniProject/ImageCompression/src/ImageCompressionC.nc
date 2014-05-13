#include "ImageCompression.h"

module ImageCompressionC{
	uses interface Boot;
  	uses interface Leds;
  	uses interface Packet;
  	uses interface AMPacket;
  	uses interface AMSend;
  	uses interface SplitControl as AMControl;
  	uses interface Receive;
  	uses interface PacketLink;
}

implementation{
	uint8_t state = IDLE;
	message_t msg;


	event void Boot.booted(){
		// Wait for picture from PC
	}


	event void AMControl.startDone(error_t error){
		// Prepare msg for retransmission
		call PacketLink.setRetries(&msg, 50);
		call PacketLink.setRetryDelay(&msg, 100);
		
		// Send msg
		
	}
	
	event void AMControl.stopDone(error_t error){
		
	}



	event void AMSend.sendDone(message_t *pMsg, error_t error){
		
	}

	

	event message_t * Receive.receive(message_t *pMsg, void *payload, uint8_t len){
		return pMsg;
	}


}
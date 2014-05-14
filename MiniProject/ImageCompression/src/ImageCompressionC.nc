#include "ImageCompression.h"
#include "UserButton.h"

module ImageCompressionC{
	uses interface Boot;
  	uses interface Leds;
  	uses interface Timer<TMilli> as Timer;
  	
  	uses interface Get<button_state_t> as GetButton;
    uses interface Notify<button_state_t> as NotifyButton;
    
  	uses interface SplitControl as AMControl;
  	
  	uses interface AMSend as CompressedSend;
  	uses interface Receive as CompressedReceive;
  	uses interface Packet as CompressedPacket;
  	uses interface AMPacket as CompressedAMPacket;
  	
  	uses interface AMSend as UncompressedSend;
  	uses interface Receive as UncompressedReceive;
  	uses interface Packet as UncompressedPacket;
  	uses interface AMPacket as UncompressedAMPacket;
}

implementation{
	uint8_t state = IDLE;
	message_t msg;
	uint8_t packetId = 0;
	bool sendingImage = FALSE;

	event void Boot.booted(){
		call NotifyButton.enable(); // Enable key press
		
	}


	event void AMControl.startDone(error_t error){
		// Just entered RECEIVE_FROM_PC state:
		
		
	}
	
	event void AMControl.stopDone(error_t error){
		
	}



	event void CompressedSend.sendDone(message_t *pMsg, error_t error){
		
	}

	

	event message_t * CompressedReceive.receive(message_t *pMsg, void *payload, uint8_t len){
		return pMsg;
	}
	
	
	event void UncompressedSend.sendDone(message_t *pMsg, error_t error){
		
	}

	

	event message_t * UncompressedReceive.receive(message_t *pMsg, void *payload, uint8_t len){
		return pMsg;
	}



	event void NotifyButton.notify(button_state_t btnState){
		if ( btnState == BUTTON_PRESSED ) {
      		state = ++state % NUMBER_OF_STATES;
      		call Leds.set(state); //This should be turned of when battery consumption is compared. 
    	} 
    	
    	switch(state) {
    	case IDLE:
    		call AMControl.stop();
    		break;
    		
		case RECEIVING_FROM_PC:
			call AMControl.start();
			break;
			
		case SENDING_UNCOMPRESSED_TO_MOTE:
			sendingImage = TRUE;
			
			while(sendingImage) {
				// Read from flash
				
				// Transmit
				// Start timer
					
				// wait for ack
				// increment packetId	
			}
			break;
			
 		case SENDING_COMPRESSED_TO_MOTE:
 			break;
 	
 		case RECEIVING_FROM_MOTE:
 			break;
 			
 		case SENDING_UNCOMPRESSED_TO_PC:
 			break;
 	
 		case SENDING_COMPRESSED_TO_PC:
 			break;
			
		default:
			break;	
    		
		}
	}

	event void Timer.fired(){
		
	}
}
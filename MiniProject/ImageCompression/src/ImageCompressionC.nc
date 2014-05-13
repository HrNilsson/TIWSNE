#include "ImageCompression.h"
#include "UserButton.h"

module ImageCompressionC{
	uses interface Boot;
  	uses interface Leds;
  	uses interface Packet;
  	uses interface AMPacket;
  	uses interface AMSend;
  	uses interface SplitControl as AMControl;
  	uses interface Receive;
  	uses interface Get<button_state_t> as GetButton;
    uses interface Notify<button_state_t> as NotifyButton;
}

implementation{
	uint8_t state = IDLE;
	message_t msg;

	event void Boot.booted(){
		call NotifyButton.enable(); // Enable key press
		
	}


	event void AMControl.startDone(error_t error){
		
		// Prepare msg for retransmission
		
		
		// Send msg
		
	}
	
	event void AMControl.stopDone(error_t error){
		
	}



	event void AMSend.sendDone(message_t *pMsg, error_t error){
		
	}

	

	event message_t * Receive.receive(message_t *pMsg, void *payload, uint8_t len){
		return pMsg;
	}



	event void NotifyButton.notify(button_state_t btnState){
		if ( btnState == BUTTON_PRESSED ) {
      		state = ++state % NUMBER_OF_STATES;
      		call Leds.set(state);
    	} 
	}
}
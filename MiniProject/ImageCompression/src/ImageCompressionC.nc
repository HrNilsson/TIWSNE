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
	
	
	uses interface BlockWrite as UncompressedStore;
	uses interface BlockRead as UncompressedRestore;
 
	uses interface BlockWrite as CompressedStore;
	uses interface BlockRead as CompressedRestore;
 
}

implementation{
	uint8_t state = IDLE;
	message_t msg;
	uint8_t packetId = 0;
	bool waitingForAck = FALSE;
	bool sendingImage = FALSE;
	bool busySending = FALSE;
	
	nx_uint8_t flashDataUncompressed[NO_OF_UNCOMPRESSED_PIXELS];
	nx_uint8_t flashDataCompressed[NO_OF_COMPRESSED_PIXELS];
	
	void MainLoop(void) {
	
		while(1) {
	
			switch(state) {
				case IDLE:
				call AMControl.stop();
				break;
	
				case RECEIVING_FROM_PC:
				call AMControl.start();
				break;
	
				case SENDING_UNCOMPRESSED_TO_MOTE:
				sendingImage = TRUE;
	
				while(sendingImage) 
				{
					// Read from flash
	
					//flashDataUncompressed = restore(); 
	
					// increment packetId
					packetId++;
					UncompressedMsg* msgPl = (UncompressedMsg*)(call UncompressedPacket.getPayload(&msg, sizeof (UncompressedMsg)));
					msgPl->seqNo = packetId;
					msgPl->pixels = flashDataUncompressed;
	
					// Transmit
					call UncompressedSend.send(AM_RECEIVER_ID, &msg, sizeof(flashDataUncompressed)); 
					// Start timer
					call Timer.startOneShot(TIMEOUT_WAIT_FOR_ACK);
					// wait for ack
	
	
					if(packetId == TOTAL_UNCOMPRESSED_PACKETS)
					{
						sendingImage = FALSE;
					}	
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
	}
	
	event void Boot.booted(){
		call NotifyButton.enable(); // Enable key press
	
		MainLoop(); // Start main loop	
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
	
		if (len == sizeof(AckMsg)) {
			if(call Timer.isRunning() == TRUE) 
			{
				call Timer.stop();
			}
	
			AckMsg* ackMsg = (AckMsg*)payload;
			if(ackMsg->ack == TRUE) 
			{
				waitingForAck = FALSE;
			} else {
				//
			}
	
		}
	
	
		return pMsg;
	}

	event void Timer.fired(){
	
	}


	event void NotifyButton.notify(button_state_t btnState){
		if ( btnState == BUTTON_PRESSED ) {
			state = ++state % NUMBER_OF_STATES;
			call Leds.set(state); //This should be turned of when battery consumption is compared. 
		} 
	
	
	}
	
	event void UncompressedStore.writeDone(storage_addr_t addr, void * buf, storage_len_t len, error_t error)
	{
	}
 
	event void UncompressedStore.eraseDone(error_t error)
	{
	
	}
 
	event void UncompressedStore.syncDone(error_t error)
	{
	
	}
 
	event void UncompressedRestore.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t cnt, error_t error)
	{
	
	}
 
	event void UncompressedRestore.readDone(storage_addr_t addr,void * buf, storage_len_t len, error_t error)
	{
	}
 
	event void CompressedStore.writeDone(storage_addr_t addr, void * buf, storage_len_t len, error_t error)
	{
	}
 
	event void CompressedStore.eraseDone(error_t error)
	{
	
	}
 
	event void CompressedStore.syncDone(error_t error)
	{
	
	}
 
	event void CompressedRestore.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t cnt, error_t error)
	{
	
	}
 
	event void CompressedRestore.readDone(storage_addr_t addr,void * buf, storage_len_t len, error_t error)
	{
	}
}
#include "ImageCompression.h"
#include "UserButton.h"
#include "serialdata.h"

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
 
 	uses interface SplitControl as SerialControl;
	uses interface Receive as SerialReceive;
	uses interface AMSend as SerialAMSend;
}

implementation{
	//--------------------------VARIABLE DECLARATION----------------------------//
	nx_uint8_t state;
	message_t msg;
	nx_uint8_t transSeqNo;
	
	TaskFlag taskFlag = INIT;
	
	nx_uint8_t flashDataUncompressed[NO_OF_UNCOMPRESSED_PIXELS];
	nx_uint8_t flashDataCompressed[NO_OF_COMPRESSED_PIXELS];
	
	//--------------------------TASK PROTOTYPES----------------------------------//
	task void ReceivingFromPcTask();
	task void SendUncompressedToMoteTask();
	task void SendCompressedToMoteTask();
	task void ReceivingFromMoteTask();
	task void SendUncompressedToPcTask();
	task void SendCompressedToPcTask();
	
	//---------------------------EVENTS------------------------------------------//
	event void Boot.booted(){
			call NotifyButton.enable(); // Enable key press
			state = IDLE;
			transSeqNo = 0;
	}
	
	event void NotifyButton.notify(button_state_t btnState){
			if ( btnState == BUTTON_PRESSED ) {
			state = ++state % NUMBER_OF_STATES;
			call Leds.set(state); //This should be turned of when battery consumption is compared. 
			
			switch(state) {
				case IDLE:
					//Make sure to shot down radio.
					call AMControl.stop(); 
					break;
	
				case RECEIVING_FROM_PC:
					
					break;
	
				case SENDING_UNCOMPRESSED_TO_MOTE:
					call AMControl.start();
					post SendUncompressedToMoteTask();
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

//---------------------------EVENTS - WIRELESS TRANMISSION------------------------------------------//
	
	event void AMControl.startDone(error_t error){
	
	}
	
	event void AMControl.stopDone(error_t error){
	
	}

	event void CompressedSend.sendDone(message_t *pMsg, error_t error){
	
	}	

	event message_t * CompressedReceive.receive(message_t *pMsg, void *payload, uint8_t len){
			return pMsg;
	}
	
	event void UncompressedSend.sendDone(message_t *pMsg, error_t error){
		call Timer.startOneShot(TIMEOUT_WAIT_FOR_ACK);
	}

	event message_t * UncompressedReceive.receive(message_t *pMsg, void *payload, uint8_t len){
	
		if (len == sizeof(AckMsg)) {	
			AckMsg* ackMsg = (AckMsg*)payload;
			if(ackMsg->seqNo == transSeqNo) 
			{				
				taskFlag = POST_TASK;
				call Timer.stop();
				
				post SendUncompressedToMoteTask();
				
			} else {
				// Wrong packet
			}
	
		}
	
	
		return pMsg;
	}

	event void Timer.fired(){
		taskFlag = RETRANSMIT_PACKET;
		post SendUncompressedToMoteTask();
	}

	
//---------------------------EVENTS - FLASH HANDLING------------------------------------------//

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
		taskFlag = SEND_PACKET;
		post SendUncompressedToMoteTask();
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

	event void SerialControl.startDone(error_t error)
	{
	}

	event void SerialControl.stopDone(error_t error)
	{
	}

//---------------------------EVENTS - SERIAL TRANSMISSION------------------------------------------//

	event message_t * SerialReceive.receive(message_t *pMsg, void *payload, uint8_t len)
	{
		return pMsg;
	}

	event void SerialAMSend.sendDone(message_t *pMsg, error_t error)
	{
	}



//-----------------------------------TASKS--------------------------------------//

	task void ReceivingFromPcTask() {
		
	}
	
	task void SendUncompressedToMoteTask() {

	storage_addr_t addr = 0;
	
		if(state == SENDING_UNCOMPRESSED_TO_MOTE)
		{
			switch(taskFlag) {
				case INIT:
				{
					// Read from flash
					call UncompressedRestore.read(addr, &flashDataUncompressed, NO_OF_UNCOMPRESSED_PIXELS); // CHECK THIS!?
					break;
				}
			
				case SEND_PACKET:
				{ 
					// Update payload
					UncompressedMsg* msgPl = (UncompressedMsg*)(call UncompressedPacket.getPayload(&msg, sizeof (UncompressedMsg)));
					msgPl->seqNo = ++transSeqNo;
					memcpy(&(msgPl->pixels), &flashDataUncompressed, sizeof(flashDataUncompressed));
			
					// Transmit
					call UncompressedSend.send(AM_RECEIVER_ID, &msg, sizeof(UncompressedMsg));
					break; 
				}		
				// Start timer - this is done in sendDone() for faster handling.
				
				// wait for received ack or timeout.
					
				case RETRANSMIT_PACKET:
				{
					// Transmit
					call UncompressedSend.send(AM_RECEIVER_ID, &msg, sizeof(UncompressedMsg));
					break;
				} 
		
				case POST_TASK:
				{
					if(transSeqNo != TOTAL_UNCOMPRESSED_PACKETS)
					{
						post SendUncompressedToMoteTask();	
					}
					break;
				}
							
				default:
				{
					break;
				}	
			}
		}
	}
	
	task void SendCompressedToMoteTask() {
		
	}
	
	task void ReceivingFromMoteTask() {
		
	}
	
	task void SendUncompressedToPcTask() {
		
	}
	
	task void SendCompressedToPcTask() {
		
	}



}
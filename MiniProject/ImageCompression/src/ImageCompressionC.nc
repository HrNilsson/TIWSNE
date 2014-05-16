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
	storage_addr_t storageAddr = 0;
	
	TaskFlag taskFlag = INIT;
	
	nx_uint8_t flashDataUncompressed[NO_OF_UNCOMPRESSED_PIXELS];
	nx_uint8_t flashDataCompressed[NO_OF_COMPRESSED_PIXELS];
	
	//--------------------------TASK PROTOTYPES----------------------------------//
	task void ReceivingFromPcTask();
	task void SendUncompressedToMoteTask();
	task void SendCompressedToMoteTask();
	task void ReceivingUncompressedFromMoteTask();
	task void ReceivingCompressedFromMoteTask();
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
					taskFlag = INIT;
					//storageAddr = 0;
					break;
	
				case SENDING_UNCOMPRESSED_TO_MOTE:
					taskFlag = INIT;
					transSeqNo = 0;
					//storageAddr = 0;
					
					call AMControl.start();
					post SendUncompressedToMoteTask();
					break;
	
				case SENDING_COMPRESSED_TO_MOTE:
					taskFlag = INIT;
					transSeqNo = 0;
					//storageAddr = 0;
					post SendCompressedToMoteTask();
					break;
	
				case RECEIVING_UNCOMPRESSED_FROM_MOTE:
					taskFlag = INIT;
					transSeqNo = 0;
					//storageAddr = 0;
					break;
	
				case RECEIVING_COMPRESSED_FROM_MOTE:
					taskFlag = INIT;
					transSeqNo = 0;
					//storageAddr = 0;
					break;
	
				case SENDING_UNCOMPRESSED_TO_PC:
					taskFlag = INIT;
					//storageAddr = 0;
					break;
	
				case SENDING_COMPRESSED_TO_PC:
					taskFlag = INIT;
					//storageAddr = 0;
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
		if (state == SENDING_COMPRESSED_TO_MOTE) { 
			call Timer.startOneShot(TIMEOUT_WAIT_FOR_ACK);
		}
	}	

	event message_t * CompressedReceive.receive(message_t *pMsg, void *payload, uint8_t len){
		
		if (state == SENDING_COMPRESSED_TO_MOTE) {	
			if (len == sizeof(AckMsg)) {	
				AckMsg* ackMsg = (AckMsg*)payload;
				if(ackMsg->seqNo == transSeqNo) 
				{				
					taskFlag = POST_TASK;
					call Timer.stop();
					
					post SendCompressedToMoteTask();
				}
			}
		} else if (state == RECEIVING_COMPRESSED_FROM_MOTE) {
			if(len == sizeof(CompressedMsg)) {
				CompressedMsg* compressedMsg = (CompressedMsg*)payload;
				if(compressedMsg->seqNo == transSeqNo) 
				{
					memcpy(&flashDataCompressed, &(compressedMsg->pixelVectors), sizeof(flashDataCompressed));
					
					taskFlag = SAVE_FLASH;
					post ReceivingCompressedFromMoteTask();
				} 
				else if (compressedMsg->seqNo == transSeqNo-1) 
				{
					taskFlag = RETRANSMIT_PACKET;
					post ReceivingCompressedFromMoteTask();
				}
					
			}
		}
	
		return pMsg;
	}
	
	event void UncompressedSend.sendDone(message_t *pMsg, error_t error){
		if (state == SENDING_UNCOMPRESSED_TO_MOTE) { 
			call Timer.startOneShot(TIMEOUT_WAIT_FOR_ACK);
		}
	}

	event message_t * UncompressedReceive.receive(message_t *pMsg, void *payload, uint8_t len){
	
		if (state == SENDING_UNCOMPRESSED_TO_MOTE) {	
			if (len == sizeof(AckMsg)) {	
				AckMsg* ackMsg = (AckMsg*)payload;
				if(ackMsg->seqNo == transSeqNo) 
				{				
					taskFlag = POST_TASK;
					call Timer.stop();
					
					post SendUncompressedToMoteTask();
				}
			}
		} else if (state == RECEIVING_UNCOMPRESSED_FROM_MOTE) {
			if(len == sizeof(UncompressedMsg)) {
				UncompressedMsg* uncompressedMsg = (UncompressedMsg*)payload;
				if(uncompressedMsg->seqNo == transSeqNo) 
				{
					memcpy(&flashDataUncompressed, &(uncompressedMsg->pixels), sizeof(flashDataUncompressed));
					
					taskFlag = SAVE_FLASH;
					post ReceivingUncompressedFromMoteTask();
				}	
				else if (uncompressedMsg->seqNo == transSeqNo-1) 
				{
					taskFlag = RETRANSMIT_PACKET;
					post ReceivingUncompressedFromMoteTask();
					
				}
			}
		}
	
		return pMsg;
	}

	event void Timer.fired(){
		
		taskFlag = RETRANSMIT_PACKET;
		
		if(state == SENDING_UNCOMPRESSED_TO_MOTE) 
		{
			post SendUncompressedToMoteTask();
		} 
		else if (state == SENDING_COMPRESSED_TO_MOTE)
		{
			post SendCompressedToMoteTask();	
		}
	}

	
//---------------------------EVENTS - FLASH HANDLING------------------------------------------//

	event void UncompressedStore.writeDone(storage_addr_t addr, void * buf, storage_len_t len, error_t error)
	{
		if(state == RECEIVING_UNCOMPRESSED_FROM_MOTE) {
			taskFlag = SEND_PACKET;
			post ReceivingUncompressedFromMoteTask();
		}
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
		switch(state) {
			case SENDING_UNCOMPRESSED_TO_MOTE:
			{
				taskFlag = SEND_PACKET;
				post SendUncompressedToMoteTask();
				break;
			}
		
			case SENDING_COMPRESSED_TO_MOTE:
			{
				taskFlag = COMPRESS;
				post SendCompressedToMoteTask();
				break;
			}
			
			default:
				break;
		}
	}
 
	event void CompressedStore.writeDone(storage_addr_t addr, void * buf, storage_len_t len, error_t error)
	{
		if(state == RECEIVING_COMPRESSED_FROM_MOTE) {
			taskFlag = SEND_PACKET;
			post ReceivingCompressedFromMoteTask();
		}
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
		// Save everything uncompressed
	}
	
	task void SendUncompressedToMoteTask() {

		if(state == SENDING_UNCOMPRESSED_TO_MOTE)
		{
			switch(taskFlag) {
				case INIT:
				{
					// Read from flash
					call UncompressedRestore.read(storageAddr, &flashDataUncompressed, sizeof(flashDataUncompressed)); // CHECK THIS!?
					//update storage address:
					// storageAddr += over nine thousand!
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
		
		if(state == SENDING_COMPRESSED_TO_MOTE)
		{
			switch(taskFlag) {
				case INIT:
				{
					// Read from flash
					call UncompressedRestore.read(storageAddr, &flashDataUncompressed, sizeof(flashDataUncompressed)); // CHECK THIS!?
					//update storage address:
					// storageAddr += over nine thousand!
					break;
				}
			
				case COMPRESS:
				{
					//Compress this shiiiiiit to flashDataCompressed
					taskFlag = SEND_PACKET;
					post SendCompressedToMoteTask();
					break;
				}
				
				case SEND_PACKET:
				{ 
					// Update payload
					CompressedMsg* msgPl = (CompressedMsg*)(call CompressedPacket.getPayload(&msg, sizeof (CompressedMsg)));
					msgPl->seqNo = ++transSeqNo;
					memcpy(&(msgPl->pixelVectors), &flashDataCompressed, sizeof(flashDataCompressed));
			
					// Transmit
					call CompressedSend.send(AM_RECEIVER_ID, &msg, sizeof(CompressedMsg));
					break; 
				}		
				// Start timer - this is done in sendDone() for faster handling.
				
				// wait for received ack or timeout.
					
				case RETRANSMIT_PACKET:
				{
					// Transmit
					call CompressedSend.send(AM_RECEIVER_ID, &msg, sizeof(CompressedMsg));
					break;
				} 
		
				case POST_TASK:
				{
					if(transSeqNo != TOTAL_COMPRESSED_PACKETS)
					{
						post SendCompressedToMoteTask();	
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
	
	task void ReceivingUncompressedFromMoteTask() {
		if(state == RECEIVING_UNCOMPRESSED_FROM_MOTE)
		{
			switch(taskFlag) {
				case SAVE_FLASH:
				{
					// save flashDataUncompressed in flash
					call UncompressedStore.write(storageAddr, &flashDataUncompressed, sizeof(flashDataUncompressed));
					//update storage address:
					// storageAddr += over nine thousand!
					break;
				}
				
				case SEND_PACKET:
				{
					// Update payload
					AckMsg* msgPl = (AckMsg*)(call UncompressedPacket.getPayload(&msg, sizeof (AckMsg)));
					msgPl->seqNo = transSeqNo;
			
					// Transmit
					call UncompressedSend.send(AM_SENDER_ID, &msg, sizeof(AckMsg));
					transSeqNo++;
					break; 			
				}
				
				case RETRANSMIT_PACKET:
				{
					// Update payload
					AckMsg* msgPl = (AckMsg*)(call UncompressedPacket.getPayload(&msg, sizeof (AckMsg)));
					msgPl->seqNo = transSeqNo - 1;
			
					// Transmit
					call UncompressedSend.send(AM_SENDER_ID, &msg, sizeof(AckMsg));	
					break;
				}
				
				default:
					break;
			}
		}
	}
	
	task void ReceivingCompressedFromMoteTask() {
		if(state == RECEIVING_COMPRESSED_FROM_MOTE)
		{
			switch(taskFlag) {
				case SAVE_FLASH:
				{
					// save flashDataCompressed in flash
					call CompressedStore.write(storageAddr, &flashDataCompressed, sizeof(flashDataCompressed));
					//update storage address:
					// storageAddr += over nine thousand!
					break;
				}
				
				case SEND_PACKET:
				{
					// Update payload
					AckMsg* msgPl = (AckMsg*)(call CompressedPacket.getPayload(&msg, sizeof (AckMsg)));
					msgPl->seqNo = transSeqNo;
			
					// Transmit
					call CompressedSend.send(AM_SENDER_ID, &msg, sizeof(AckMsg));
					transSeqNo++;
					break; 			
				}
				
				case RETRANSMIT_PACKET:
				{
					// Update payload
					AckMsg* msgPl = (AckMsg*)(call CompressedPacket.getPayload(&msg, sizeof (AckMsg)));
					msgPl->seqNo = transSeqNo - 1;
			
					// Transmit
					call CompressedSend.send(AM_SENDER_ID, &msg, sizeof(AckMsg));	
					break;
				}
				
				default:
					break;
			}
		}
	}
	
	task void SendUncompressedToPcTask() {
		
	}
	
	task void SendCompressedToPcTask() {
		
	}
}
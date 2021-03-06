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
	uses interface Set<bool> as SerialFlow;
	
	uses interface QuantCompress as Comp;

}

implementation{
	//--------------------------VARIABLE DECLARATION----------------------------//
	nx_uint8_t state;
	message_t msg;
	bool toggleLeds;
	nx_uint16_t transSeqNo;
	nx_uint16_t flashCnt;
	message_t serialPacket;
	uint8_t deCompressCnt = 0;
	
	TaskFlag taskFlag = INIT;
	
	nx_uint8_t PCSerialBuffer[MAX_SERIALDATA_LENGTH];
	nx_uint8_t flashDataUncompressed[NO_OF_UNCOMPRESSED_PIXELS];
	nx_uint8_t flashDataLongUncompressed[135];
	imageVector flashDataCompressed[NO_OF_COMPRESSED_PIXELS];
	
	//-------------------------HELPER PROTOTYPES---------------------------------//
	void StartReceiveFromPcTask();
	void BlinkLeds();
	
	//--------------------------TASK PROTOTYPES----------------------------------//
	task void SendUncompressedToMoteTask();
	task void SendCompressedToMoteTask();
	task void ReceivingUncompressedFromMoteTask();
	task void ReceivingCompressedFromMoteTask();
	task void SendUncompressedToPcTask();
	task void SendCompressedToPcTask();
	
	//---------------------------EVENTS------------------------------------------//
	event void Boot.booted(){
		
		state = IDLE;
		transSeqNo = 0;
		toggleLeds = FALSE;
		flashCnt = 0;
		
		call UncompressedStore.erase();
		call CompressedStore.erase();
		
		
	}
	
	event void NotifyButton.notify(button_state_t btnState){
		
		/*printf("Hi I am writing to you from my TinyOS application!!\n");
	  	printf("Here is a uint8: %u\n", state);
	  	printfflush();				*/

		if ( btnState == BUTTON_PRESSED ) {
		state = ++state % NUMBER_OF_STATES;
		call Leds.set(state); //This should be turned of when battery consumption is compared. 
		
			switch(state) {
				case IDLE:
					//Make sure to shot down radio.
					call AMControl.stop(); 
					break;
	
				case RECEIVING_FROM_PC:
					flashCnt = 0;
					StartReceiveFromPcTask();
					taskFlag = INIT;
					break;
	
				case SENDING_UNCOMPRESSED_TO_MOTE:
					taskFlag = READ_FLASH;
					transSeqNo = 0;
					flashCnt = 0;
					
					call AMControl.start();
					break;
	
				case SENDING_COMPRESSED_TO_MOTE:
					taskFlag = READ_FLASH;
					transSeqNo = 0;
					flashCnt = 0;
					post SendCompressedToMoteTask();
					break;
	
				case RECEIVING_UNCOMPRESSED_FROM_MOTE:
					taskFlag = READ_FLASH;
					transSeqNo = 1;
					flashCnt = 0;
					break;
	
				case RECEIVING_COMPRESSED_FROM_MOTE:
					taskFlag = INIT;
					transSeqNo = 1;
					flashCnt = 0;
					break;
	
				case SENDING_UNCOMPRESSED_TO_PC:
					taskFlag = READ_FLASH;
					flashCnt = 0;
					if(call SerialControl.start() != SUCCESS)
					{
						//We assume it its already started!!
						post SendUncompressedToPcTask();
					}
					break;
	
				case SENDING_COMPRESSED_TO_PC:
					taskFlag = READ_FLASH;
					flashCnt = 0;
					post SendCompressedToPcTask();
					break;
	
				default:
					break;	
	
			}
		}
	}

//---------------------------EVENTS - WIRELESS TRANMISSION------------------------------------------//
	
	event void AMControl.startDone(error_t error){
		post SendUncompressedToMoteTask();
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
					
					taskFlag = DECOMPRESS;
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
			flashCnt ++;
			taskFlag = SEND_PACKET;
			if (flashCnt == SERIAL_DATA_NUMBER_OF_PACKETS)
			{
				call UncompressedStore.sync();
			}
			post ReceivingUncompressedFromMoteTask();
		}
		else if(state == RECEIVING_FROM_PC)
		{
			flashCnt ++;
			call SerialFlow.set(TRUE);
			
			if(flashCnt == SERIAL_DATA_NUMBER_OF_PACKETS)
			{		
				call SerialControl.stop();
				call UncompressedStore.sync(); 	
			}
		}
		else if(state == RECEIVING_COMPRESSED_FROM_MOTE) {
			flashCnt ++;
			taskFlag = SEND_PACKET;
			if (flashCnt == TOTAL_COMPRESSED_PACKETS)
			{
				call UncompressedStore.sync();
			}
			post ReceivingCompressedFromMoteTask();
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
				flashCnt ++;
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
			
			case SENDING_UNCOMPRESSED_TO_PC:
			{
				flashCnt++;
				taskFlag = SEND_TO_PC;
				post SendUncompressedToPcTask();	
				break;
			} 
			
			case SENDING_COMPRESSED_TO_PC: 
			{
				flashCnt++;
				taskFlag = SEND_TO_PC;
				post SendCompressedToPcTask();
				break;
			}
			
			default:
				break;
		}
	}
 
	event void CompressedStore.writeDone(storage_addr_t addr, void * buf, storage_len_t len, error_t error)
	{
		if(state == RECEIVING_COMPRESSED_FROM_MOTE) {
			flashCnt ++;
			taskFlag = SEND_PACKET;
			if (flashCnt == TOTAL_COMPRESSED_PACKETS)
			{
				call CompressedStore.sync();
			}
			post ReceivingCompressedFromMoteTask();
		}
	}
 
	event void CompressedStore.eraseDone(error_t error)
	{
		call NotifyButton.enable(); // Enable key press
	}
 
	event void CompressedStore.syncDone(error_t error)
	{
	
	}
 
	event void CompressedRestore.computeCrcDone(storage_addr_t addr, storage_len_t len, uint16_t cnt, error_t error)
	{
	
	}
 
	event void CompressedRestore.readDone(storage_addr_t addr,void * buf, storage_len_t len, error_t error)
	{
		if(state == SENDING_COMPRESSED_TO_PC) 
		{
			flashCnt++;
			taskFlag = SEND_TO_PC;
			post SendCompressedToPcTask();
		}

	}

	event void SerialControl.startDone(error_t error)
	{
		if(state == SENDING_UNCOMPRESSED_TO_PC)
		{
			post SendUncompressedToPcTask();
		}
	}

	event void SerialControl.stopDone(error_t error)
	{
	}

//---------------------------EVENTS - SERIAL TRANSMISSION------------------------------------------//

	event message_t * SerialReceive.receive(message_t *pMsg, void *payload, uint8_t len)
	{
		call SerialFlow.set(FALSE);
		BlinkLeds();
		
		memcpy(PCSerialBuffer,payload,MAX_SERIALDATA_LENGTH);
		
		if(flashCnt < SERIAL_DATA_NUMBER_OF_PACKETS-1)
		{
			call UncompressedStore.write(flashCnt*MAX_SERIALDATA_LENGTH,PCSerialBuffer,MAX_SERIALDATA_LENGTH);
		}
		else if(flashCnt == SERIAL_DATA_NUMBER_OF_PACKETS-1)
		{
			call UncompressedStore.write(flashCnt*MAX_SERIALDATA_LENGTH,PCSerialBuffer,SERIAL_DATA_REST);		
		}
		else
		{
			//Error to many packets received from PC
		}
		
		return pMsg;
	}

	event void SerialAMSend.sendDone(message_t *pMsg, error_t error)
	{
		switch(state)
		{
			case SENDING_UNCOMPRESSED_TO_PC:
			{
				if(flashCnt == SERIAL_DATA_NUMBER_OF_PACKETS) 
				{
					call Leds.set(0);	
				} 
				else 
				{
					BlinkLeds();
					taskFlag = READ_FLASH;
					post SendUncompressedToPcTask();
				}
				
				break;
			}
			
			case SENDING_COMPRESSED_TO_PC:
			{
				if(flashCnt == SERIAL_DATA_NUMBER_OF_PACKETS) 
				{
					call Leds.set(0);	
				} 
				else 
				{
					BlinkLeds();
					taskFlag = READ_FLASH;
					post SendCompressedToPcTask();
				}
				break;
			}
			default:
				break;
		}
	}

//----------------------------------HELPERS-------------------------------------//

	void StartReceiveFromPcTask()
	{
		call SerialControl.start();
	}
	
	void BlinkLeds()
	{
		#ifdef BLINK_LEDS
		if(toggleLeds) {
			call Leds.set(0);
			toggleLeds = FALSE;
		} else {
			call Leds.set(state);
			toggleLeds = TRUE;
		}
		#endif
	}

//-----------------------------------TASKS--------------------------------------//

	
	task void SendUncompressedToMoteTask() {

		if(state == SENDING_UNCOMPRESSED_TO_MOTE)
		{
			switch(taskFlag) {
				case READ_FLASH:
				{
					// Read from flash
					if (flashCnt < TOTAL_UNCOMPRESSED_PACKETS)
					{
						call UncompressedRestore.read(flashCnt*NO_OF_UNCOMPRESSED_PIXELS, flashDataUncompressed, NO_OF_UNCOMPRESSED_PIXELS);
					}
					else if (flashCnt >= TOTAL_UNCOMPRESSED_PACKETS)
					{
						call UncompressedRestore.read(flashCnt*NO_OF_UNCOMPRESSED_PIXELS, &flashDataUncompressed, UNCOMPRESSED_IMAGE_REST);
					}

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
						BlinkLeds();
						taskFlag = READ_FLASH;
						post SendUncompressedToMoteTask();	
					} else {
						call Leds.set(0);
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
				case READ_FLASH:
				{
					if (flashCnt < 486)
					{
						call UncompressedRestore.read(flashCnt*135, flashDataLongUncompressed, 135);
					}
					else if (flashCnt >= 486)
					{
						call UncompressedRestore.read(flashCnt*135, flashDataLongUncompressed, 61); 	
					}
					break;
				}
			
				case COMPRESS:
				{
					
					uint8_t i = 0;
					
					if (flashCnt < 486)
					{
						for(i=0 ; i <= 135 ; i = i+5) {
	
							flashDataCompressed[i/5] = call Comp.compressVector(flashDataLongUncompressed+i);
	
						}
					}
					
					else if (flashCnt >= 486)
					{
						//call UncompressedRestore.read(flashCnt*NO_OF_UNCOMPRESSED_PIXELS, flashDataUncompressed, UNCOMPRESSED_IMAGE_REST); 
						
						for(i=0 ; i <= 61 ; i = i+5) {
						
							flashDataCompressed[i/5] = call Comp.compressVector(flashDataLongUncompressed+i);
						
						}	
						
						flashDataCompressed[i/5+1] = call Comp.compressVector(flashDataLongUncompressed+i);
						flashDataCompressed[i/5+1].notFull = 0x3; // Signal imageVector with only one pixel						
					}
					
					/*for(i=0; i < 27; i++) 
					{
						flashDataCompressed[i] = (imageVector)0x55555555;
					}*/
					
					flashCnt++;
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
					if(transSeqNo != 486)
					{
						BlinkLeds();
						taskFlag = READ_FLASH;
						post SendCompressedToMoteTask();	
					} else {
						call Leds.set(0);
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
					BlinkLeds();
					
					if (flashCnt < TOTAL_UNCOMPRESSED_PACKETS)
					{
						call UncompressedStore.write(flashCnt*NO_OF_UNCOMPRESSED_PIXELS, flashDataUncompressed, NO_OF_UNCOMPRESSED_PIXELS);
					}
					else if (flashCnt >= TOTAL_UNCOMPRESSED_PACKETS)
					{
						call UncompressedStore.write(flashCnt*NO_OF_UNCOMPRESSED_PIXELS, flashDataUncompressed, UNCOMPRESSED_IMAGE_REST); 	
					}
					
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
					
					if(transSeqNo == TOTAL_UNCOMPRESSED_PACKETS + 1)  
 					{
 						taskFlag = POST_TASK;
 						post ReceivingUncompressedFromMoteTask();
 					}
					break; 			
				}
				
				case RETRANSMIT_PACKET:
				{
					// Update payload
					AckMsg* msgPl = (AckMsg*)(call UncompressedPacket.getPayload(&msg, sizeof (AckMsg)));
					msgPl->seqNo = transSeqNo - 1;
			
					// Transmit
					call UncompressedSend.send(AM_SENDER_ID, &msg, sizeof(AckMsg));
					
					if(transSeqNo == TOTAL_UNCOMPRESSED_PACKETS + 1)  
 					{
 						taskFlag = POST_TASK;
 						post ReceivingUncompressedFromMoteTask();
 					}	
					break;
				}
				
				case POST_TASK:
				{
					call Leds.set(0);
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
				case DECOMPRESS:
				{
					for (deCompressCnt = 0; deCompressCnt < 27; deCompressCnt++)
					{
						call Comp.deCompressVector(flashDataCompressed[deCompressCnt], &flashDataLongUncompressed[deCompressCnt*5]);
					}
					
					/*for (deCompressCnt = 0; deCompressCnt < 135; deCompressCnt++)
					{
						flashDataLongUncompressed[deCompressCnt] = 0x55;
					}*/
					
					taskFlag = SAVE_FLASH;
					post ReceivingCompressedFromMoteTask();
					break;
				}	
			
				case SAVE_FLASH:
				{
					BlinkLeds();
					
					if (flashCnt < TOTAL_COMPRESSED_PACKETS)
					{
						call UncompressedStore.write(flashCnt*135, flashDataLongUncompressed, 135);
					}
					else if (flashCnt >= TOTAL_COMPRESSED_PACKETS)
					{
						call UncompressedStore.write(flashCnt*135, flashDataLongUncompressed, 61); 	
					}
										
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
					
					if(transSeqNo == TOTAL_COMPRESSED_PACKETS + 1)  
 					{
 						taskFlag = POST_TASK;
 						post ReceivingCompressedFromMoteTask();
 					}
					break; 			
				}
				
				case RETRANSMIT_PACKET:
				{
					// Update payload
					AckMsg* msgPl = (AckMsg*)(call CompressedPacket.getPayload(&msg, sizeof (AckMsg)));
					msgPl->seqNo = transSeqNo - 1;
			
					// Transmit
					call CompressedSend.send(AM_SENDER_ID, &msg, sizeof(AckMsg));
					
					if(transSeqNo == TOTAL_COMPRESSED_PACKETS + 1)  
 					{
 						taskFlag = POST_TASK;
 						post ReceivingCompressedFromMoteTask();
 					}	
					break;
				}
				
				case POST_TASK:
				{
					call Leds.set(0);
					break;
				} 
				
				default:
					break;
			}
		}
	}
	
	task void SendUncompressedToPcTask() 
	{
		switch(taskFlag)
		{
			case READ_FLASH:
			{ 
				if(flashCnt < SERIAL_DATA_NUMBER_OF_PACKETS-1)
				{
					call UncompressedRestore.read(flashCnt*MAX_SERIALDATA_LENGTH,PCSerialBuffer,MAX_SERIALDATA_LENGTH);
				}
				else if(flashCnt == SERIAL_DATA_NUMBER_OF_PACKETS-1)
				{
					call UncompressedRestore.read(flashCnt*MAX_SERIALDATA_LENGTH,PCSerialBuffer,SERIAL_DATA_REST);
				} 
				break;
			}
			case SEND_TO_PC:
			{
				void * payload = call SerialAMSend.getPayload(&serialPacket, MAX_SERIALDATA_LENGTH);
				
				memcpy(payload,PCSerialBuffer,MAX_SERIALDATA_LENGTH);
				
				call SerialAMSend.send(AM_BROADCAST_ADDR, &serialPacket, MAX_SERIALDATA_LENGTH);
				
				break;
			}
			default:
				break;
		}
		
		
	}
	
	task void SendCompressedToPcTask() 
	{
		switch(taskFlag)
		{
			case READ_FLASH:
			{ 
				if(flashCnt < SERIAL_DATA_NUMBER_OF_PACKETS-1)
				{
					call UncompressedRestore.read(flashCnt*MAX_SERIALDATA_LENGTH,PCSerialBuffer,MAX_SERIALDATA_LENGTH);
				}
				else if(flashCnt == SERIAL_DATA_NUMBER_OF_PACKETS-1)
				{
					call UncompressedRestore.read(flashCnt*MAX_SERIALDATA_LENGTH,PCSerialBuffer,SERIAL_DATA_REST);
				} 
				break;
			}
			case SEND_TO_PC:
			{
				void * payload = call SerialAMSend.getPayload(&serialPacket, MAX_SERIALDATA_LENGTH);
				
				memcpy(payload,PCSerialBuffer,MAX_SERIALDATA_LENGTH);
				
				call SerialAMSend.send(AM_BROADCAST_ADDR, &serialPacket, MAX_SERIALDATA_LENGTH);
				
				break;
			}
			default:
				break;
		}		
		
	}
}

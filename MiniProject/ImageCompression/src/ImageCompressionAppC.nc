#include "ImageCompression.h"
#include "StorageVolumes.h"

#define TOSH_DATA_LENGTH 113

configuration ImageCompressionAppC {
}
implementation {
	components MainC;
	components LedsC;
	components UserButtonC;
	components new TimerMilliC() as Timer;
	components ImageCompressionC as App;
	components ActiveMessageC;
	components ReliableSerialC;
  	components SerialActiveMessageC;

	// Transceiver for compressed data format
	components new AMSenderC(AM_COMPRESSED_IMAGE) as CompressedSender;
	components new AMReceiverC(AM_COMPRESSED_IMAGE) as CompressedReceiver;

	// Transceiver for uncompressed data format 
	components new AMSenderC(AM_UNCOMPRESSED_IMAGE) as UncompressedSender;
	components new AMReceiverC(AM_UNCOMPRESSED_IMAGE) as UncompressedReceiver;
	
	components new BlockStorageC(VOLUME_PICTURERAW) as UncompressedFlashVolume;
	components new BlockStorageC(VOLUME_PICTURECOMPRESSED) as CompressedFlashVolume;	
	
	
	App.Boot->MainC;
	App.Leds->LedsC;
	App.Timer->Timer;

	App.GetButton->UserButtonC;
	App.NotifyButton->UserButtonC;

	App.AMControl->ActiveMessageC;

	App.CompressedSend->CompressedSender;
	App.CompressedReceive->CompressedReceiver;
	App.CompressedPacket->CompressedSender;
	App.CompressedAMPacket->CompressedSender;

	App.UncompressedSend->UncompressedSender;
	App.UncompressedReceive->UncompressedReceiver;
	App.UncompressedPacket->UncompressedSender;
	App.UncompressedAMPacket->UncompressedSender;
	
	App.UncompressedStore->UncompressedFlashVolume.BlockWrite;
	App.UncompressedRestore->UncompressedFlashVolume.BlockRead;
	
	App.CompressedStore->CompressedFlashVolume.BlockWrite;
	App.CompressedRestore->CompressedFlashVolume.BlockRead;
	
	App.SerialControl -> SerialActiveMessageC;
  	App.SerialReceive -> ReliableSerialC;
  	App.SerialAMSend -> ReliableSerialC;
  	
  	components new TimerMilliC() as AckTimer;
	components new SerialAMSenderC(AM_RELIABLE_MSG) as DataSender;
	components new SerialAMSenderC(AM_ACK_MSG) as AckSender;
	  	
	ReliableSerialC.SubSend -> DataSender;
	ReliableSerialC.AckSend -> AckSender;
	//ReliableSerialC.SubReceive -> AM.Receive[AM_RELIABLE_MSG];
	//ReliableSerialC.AckReceive -> AM.Receive[AM_ACK_MSG];
	ReliableSerialC.Timer -> AckTimer;
}
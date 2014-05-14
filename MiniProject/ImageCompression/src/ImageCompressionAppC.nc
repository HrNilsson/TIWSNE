#include "ImageCompression.h"
#include "StorageVolumes.h"

configuration ImageCompressionAppC {
}
implementation {
	components MainC;
	components LedsC;
	components UserButtonC;
	components new TimerMilliC() as Timer;
	components ImageCompressionC as App;
	components ActiveMessageC;

	// Transceiver for compressed data format
	components new AMSenderC(AM_COMPRESSED_IMAGE) as CompressedSender;
	components new AMReceiverC(AM_COMPRESSED_IMAGE) as CompressedReceiver;

	// Transceiver for uncompressed data format 
	components new AMSenderC(AM_UNCOMPRESSED_IMAGE) as UncompressedSender;
	components new AMReceiverC(AM_UNCOMPRESSED_IMAGE) as UncompressedReceiver;

	components new BlockStorageC(VOLUME_PICTURERAW) as PictureRaw;
	components new BlockStorageC(VOLUME_PICTURECOMPRESSED) as PictureCompressed;
	
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

}
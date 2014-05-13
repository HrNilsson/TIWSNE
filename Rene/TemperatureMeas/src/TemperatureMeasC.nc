#include "Timer.h"
#include "TemperatureMeas.h"

module TemperatureMeasC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface SplitControl as AMControl;
	uses interface Read<uint16_t>;
}

implementation {
	bool busy = FALSE;
	message_t pkt;
	uint16_t reading = 0;

	event void Boot.booted() {
		call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
	}

	event void Timer0.fired() {
		call Read.read();
	}

	event void AMControl.startDone(error_t err) {
		if(err == SUCCESS) {
			if( ! busy) {
				TemperatureMeasMsg * btrpkt = (TemperatureMeasMsg * )(call Packet
						.getPayload(&pkt, sizeof(TemperatureMeasMsg)));
				btrpkt->nodeid = TOS_NODE_ID;
				btrpkt->reading = reading;

				if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(TemperatureMeasMsg)) = 
						= SUCCESS) {
					busy = TRUE;
				}
			}
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

	event void AMSend.sendDone(message_t * msg, error_t error) {
		if(&pkt == msg) {
			busy = FALSE;
			call AMControl.stop();
		}
	}

	event void Read.readDone(error_t result, uint16_t data) {
		if(result == SUCCESS) {
			reading = data;
			call AMControl.start();
		}
	}

}
// $Id: ReliableTestSerialC.nc,v 1.1 2009/02/26 18:10:45 idgay Exp $

/*									tab:4
 * "Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */ 

/**
 * Application to test that the TinyOS java toolchain can communicate
 * with motes over the serial port. 
 *
 *  @author Gilman Tolle
 *  @author Philip Levis
 *  
 *  @date   Aug 12 2005
 *
 **/ 

#include "Timer.h"
#include "serialdata.h"

#define NEW_PRINTF_SEMANTICS
#include "printf.h"

module DataTransfererC {
	uses {
		interface SplitControl as Control;
		interface Leds;
		interface Boot;
		interface Receive;
		interface AMSend;
		interface Timer<TMilli> as MilliTimer;
	}
}
implementation {
	message_t packet;
	uint8_t counter = 0;

	event void Boot.booted() {
		call Control.start();
	}
	
	void sendNextTestPacket()
	{
		serialdata_msg_t * rcm = call AMSend.getPayload(&packet, sizeof(serialdata_msg_t));
		
		rcm->data[0] = counter;
		rcm->data[111] = counter;
		counter++;
				
		if(call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(serialdata_msg_t)) != SUCCESS)
			printf("send success\n");
		else
			printf("send error\n");
			
		printfflush();
	}

	event void Control.startDone(error_t err) {
		sendNextTestPacket();
		printf("startDone\n");
		printfflush();
	}

	event void Control.stopDone(error_t err) {
	}

	event void MilliTimer.fired() {		
	}

	event message_t * Receive.receive(message_t * bufPtr, void * payload,
			uint8_t len) 
	{
		serialdata_msg_t * rcm;
		//printf("len: %u\n", len);
		//printfflush();
		
		if(len == sizeof(serialdata_msg_t)) 
		{
			rcm = (serialdata_msg_t * ) payload;
			call Leds.set(rcm->data[0]);
			
			//printf("data[111]]: %u\n", rcm->data[111]);
			//printfflush();
		}
		else
		{ 
			call Leds.set(1);
			//printf("fail.");
		}

		return bufPtr;
	}

	event void AMSend.sendDone(message_t * bufPtr, error_t error) {
		sendNextTestPacket();
	}
}
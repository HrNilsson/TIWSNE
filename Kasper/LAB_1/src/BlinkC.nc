// $Id: BlinkC.nc,v 1.5 2008/06/26 03:38:26 regehr Exp $

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


#include "Timer.h"
#include <UserButton.h>

#define IDLE 0
#define ONELED 1
#define TWOLED 2
#define THREELED 3
#define BLINK 4

module BlinkC @safe() {
	uses interface Timer<TMilli> as Timer0;
	uses interface Leds;
	uses interface Boot;
	uses interface Notify<button_state_t>;
}
implementation {
	bool m_started;
	int mode = IDLE;
	int blinkStep = 0;

	void StartTimer() {
		call Timer0.startPeriodic(250);
		m_started = TRUE;
	}

	void StopTimer() {
		call Timer0.stop();

		m_started = FALSE;	

	}
	
	void SetMode(int stateID) {
		switch (stateID) {
			case IDLE :
			StopTimer();
			call Leds.set(0);
			break;
			
			case ONELED :
			call Leds.set(1);
			break;
			
			case TWOLED :
			call Leds.set(3);
			break;
			
			case THREELED :
			call Leds.set(7);
			break;
			
			case BLINK :
			StartTimer();
			
			//call Leds.set(4); // DEBUG
			break;
			
			default:
			break;
		
		
		
		}	
		
	}
	
	event void Boot.booted() {
		//StartTimer();
		call Notify.enable();
	}

	event void Timer0.fired() {
		switch (blinkStep) {
			case 0:
			call Leds.set(0);
			break;
			
			case 1:
			call Leds.set(1);
			break;
			
			case 2:
			call Leds.set(3);
			break;
			
			case 3:
			call Leds.set(7);
			break;
			
			case 4:
			call Leds.set(3);
			break;
			
			case 5:
			call Leds.set(1);
			break;
		}
			
			blinkStep++;
			blinkStep = blinkStep % 6;
	}

	event void Notify.notify(button_state_t state) {
	
		if(state == BUTTON_PRESSED) {
			mode++;
			mode = mode % 5;	
	
		}
		else 
			if(state == BUTTON_RELEASED) {
			// Nothing yet!
		}
		
		SetMode(mode);
		
	}

}
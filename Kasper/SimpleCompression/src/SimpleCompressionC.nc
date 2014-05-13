/*
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */
/*
 * Copyright (c) 2002-2005 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Null is an empty skeleton application.  It is useful to test that the
 * build environment is functional in its most minimal sense, i.e., you
 * can correctly compile an application. It is also useful to test the
 * minimum power consumption of a node when it has absolutely no 
 * interrupts or resources active.
 *
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 * @date February 4, 2006
 */
 
#include "ImageTypes.h"
#include "printf.h"

uint8_t pixelVector[6] = {54, 74, 125, 125, 255};

module SimpleCompressionC @safe()
{
	uses interface Boot;
	uses interface QuantCompress as QC;
	uses interface Leds;
 
}
implementation
{
	
	imageVector test;
	uint8_t testResult[5];
	uint8_t i; // Loop counter
	uint8_t errorFlag = 0; //
	uint8_t test1, test2, diff; 
	bool temp;
	
	event void Boot.booted() {	
	
		call Leds.set(0); // turn all LEDS off
		test = call QC.compressVector(pixelVector);
		
		//test.px3 = 0x00;
		
		call QC.deCompressVector(test, testResult);
	
		for (i=0; i<5 ; i++) {
			
			test1 = pixelVector[i]>>2;
			test2 = testResult[i]>>2;
			
			diff = test1-test2;
	
//			temp = ((pixelVector[i]>>2)  == (testResult[i]>>2)); // Compare input and output
	
			if (~temp) {
				errorFlag++;
				
				call Leds.set(errorFlag); // Debug
			}
 
		}
	
		if (errorFlag == 0) {
			//call Leds.set(7);
		}
	
		else {
//			call Leds.led0On();
		}
	
	}
}













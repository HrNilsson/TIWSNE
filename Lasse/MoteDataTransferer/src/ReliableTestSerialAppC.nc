// $Id: ReliableTestSerialAppC.nc,v 1.1 2009/02/26 18:10:45 idgay Exp $

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
 * Copyright (c) 2002-2005 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */

/**
 * Application to test that the TinyOS java toolchain can communicate
 * with motes over the serial port. The application sends packets to
 * the serial port at 1Hz: the packet contains an incrementing
 * counter. When the application receives a counter packet, it
 * displays the bottom three bits on its LEDs. This application is
 * very similar to RadioCountToLeds, except that it operates over the
 * serial port. There is Java application for testing the mote
 * application: run TestSerial to print out the received packets and
 * send packets to the mote.
 *
 *  @author Gilman Tolle
 *  @author Philip Levis
 *  
 *  @date   Aug 12 2005
 *
 **/
 
 #define NEW_PRINTF_SEMANTICS
 #include "printf.h"

configuration ReliableTestSerialAppC {}
implementation {
  components DataTransfererC as App, LedsC, MainC, ReliableSerialC;
  components SerialActiveMessageC as AM;
  components new TimerMilliC();
  components PrintfC;

  App.Boot -> MainC.Boot;
  App.Control -> AM;
  App.Receive -> ReliableSerialC;
  App.AMSend -> ReliableSerialC;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;

  components new TimerMilliC() as AckTimer;
  components new SerialAMSenderC(AM_RELIABLE_MSG) as DataSender;
  components new SerialAMSenderC(AM_ACK_MSG) as AckSender;
  ReliableSerialC.SubSend -> DataSender;
  ReliableSerialC.AckSend -> AckSender;
  ReliableSerialC.SubReceive -> AM.Receive[AM_RELIABLE_MSG];
  ReliableSerialC.AckReceive -> AM.Receive[AM_ACK_MSG];
  ReliableSerialC.Timer -> AckTimer;
}



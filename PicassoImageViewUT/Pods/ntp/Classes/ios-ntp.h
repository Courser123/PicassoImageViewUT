/*╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
 ║ NetworkClock.h                                                                                   ║
 ║                                                                                                  ║
 ║ Created by Gavin Eadie on Oct17/10                                                               ║
 ║ Copyright 2010 Ramsay Consulting. All rights reserved.                                           ║
 ╚══════════════════════════════════════════════════════════════════════════════════════════════════╝*/

#ifndef ios_ntp_h
#define ios_ntp_h

#import "NetAssociation.h"
#import "NetworkClock.h"
#import "NSDate+NetworkClock.h"


#ifdef IOS_NTP_TEST
#define NTPLog(...) NSLog(__VA_ARGS__)
#else
#define NTPLog(...)
#endif

#endif
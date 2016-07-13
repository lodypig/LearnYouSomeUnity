//
//  UICustomTextField.m
//  Unity-iPhone
//
//  Created by tangt on 16/4/22.
//
//

#import <Foundation/Foundation.h>
#include "SysInfo.h"
//#import "Reachability.h"

@implementation SysInfo

    +(float)getBatteryLevel
    {
        [[UIDevice currentDevice] batteryLevel];
        return [[UIDevice currentDevice] batteryLevel];
    }
    
    +(int) getNetState
    {
        
        return 1;
//        Reachability *r = [Reachability reachabilityWithHostname:testPage];
//        return [r currentReachabilityStatus];
    }



#if defined(__cplusplus)
extern "C"{
#endif    
    float GetBatteryLevel() {
        NSLog("@excute");
        return [SysInfo getBatteryLevel];
    }
    
    
    int GetNetState() {
        return [SysInfo getNetState];
    }
    


    
#if defined(__cplusplus)
}
#endif


@end 
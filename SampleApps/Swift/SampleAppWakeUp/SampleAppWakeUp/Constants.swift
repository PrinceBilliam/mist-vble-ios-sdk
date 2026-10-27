//
//  Constants.swift
//  SampleAppWakeUp
//
//  Created by Rajesh Vishwakarma on 27/02/23.
//

import Foundation

struct MistSDK {
    
    struct SDK {
#if BILLY
    static let token = "TOKEN"
    static let orgId = "ORGID"
#else
    static let token = "TOKEN"
    static let orgId = "ORGID"
#endif
    }
   
    struct WakeUp {
        static let monitoringMessage = "The app is monitoring beacons. You can close the app now."
        static let notMonitoringMessage = "The app is not monitoring beacons."
    }
}

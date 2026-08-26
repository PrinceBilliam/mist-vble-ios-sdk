//
//  Constants.swift
//  SampleBlueDotWithIndoorLocation
//
//  Created by Rajesh Vishwakarma on 16/03/23.
//

import Foundation

struct MistSDK {
    
    struct SDK {
#if BILLY
    static let token = "WEBnLRFbdRzjvL5MXshkMewHBwUpcsdG"
    static let orgId = "b439d316-b0c0-4381-8dd3-23f8356fc24e"
#else
    static let token = "GSense1i1RDtJbPY6mb01cIIGmS7tgzu"
    static let orgId = "18e3a2f8-4e0c-4aee-beac-2d1109c1ce45"
#endif
    }
    
    struct WakeUp {
        static let monitoringMessage = "The app is monitoring beacons. You can close the app now."
        static let notMonitoringMessage = "The app is not monitoring beacons."
    }
}

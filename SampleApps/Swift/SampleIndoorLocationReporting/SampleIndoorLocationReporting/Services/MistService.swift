//
//  MistService.swift
//  SampleIndoorLocationReporting
//
//  Created by Rajesh Vishwakarma on 27/01/23.
//

import Foundation
import MistSDK

protocol MistService {
    func start()
    func stop()
}

class RealMistService: NSObject, MistService {
    private let mistManager = IndoorLocationManager.shared
    private let sdkConfig: Mist.Configuration
    
    init(orgId: String, token: String) {
        self.sdkConfig = .default(orgId: orgId, sdkToken: token)
    }
    
    func start() {
        // start mist indoor location service
        mistManager.start(with: sdkConfig, delegate: self)
    }
    
    func stop() {
        // stop mist indoor location service
        mistManager.stop()
    }
}

extension RealMistService: IndoorLocationDelegate {
    
    func didReceive(event: Mist.Event) {
        switch event {
            
        case .onReceivedClientInfo(let client):
            appLog(">>> onReceivedClientInfo UUID => \(client.deviceId ?? "-")")

        case .onReceivedAllMaps(let maps):
            appLog(">>> onReceivedAllMaps \(maps.count)")

        case .onMapUpdate(let map):
            appLog(">>> onMapUpdate \(map.name ?? "-")")

        case .onRelativeLocationUpdate(let relativeLocation):
            appLog(">>> didUpdateRelativeLocation x = \(relativeLocation.x) y = \(relativeLocation.y) lat = \(relativeLocation.lat), lon = \(relativeLocation.lon)")

        // ZONES
        case .onEnterZone(let zone):
            appLog(">>> didEnterZone \(zone.name!)")
        case .onExitZone(let zone):
            appLog(">>> didExitZone \(zone.name!)")

        // VirtualBeacons
        case .onRangeVirtualBeacon(let vBeacon):
            appLog(">>> didRangeVirtualBeacon \(vBeacon.name!)")

        case .onUpdateVirtualBeaconList(let vBeacons):
            appLog(">>> onUpdateVirtualBeaconList \(vBeacons.count)")

        case .onError(let error):
            appLog(">>> didErrorOccur = \(error.localizedDescription)")
            
        default:
            break
        }
    }
}

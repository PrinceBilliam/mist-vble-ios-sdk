//
//  MistSDKManager.swift
//  SampleBlueDotExperience
//
//  Created by Akhil Rana on 02/04/25.
//

import Foundation
import MistSDK

@objc public protocol MistSDKManagerDelegate: NSObjectProtocol {
    func didUpdateMap(_ map: MistMap)
    func didUpdateLocation(_ location: CGPoint)
    func didFailWithError(_ error: String)
}

public class MistSDKManager: NSObject {
    private let mistManager = IndoorLocationManager.shared
    private let sdkConfig: Mist.Configuration
    private var currentMap: MistMap?
    @objc public weak var delegate: MistSDKManagerDelegate?

    @objc public init(token: String, orgId: String) {
        self.sdkConfig = Mist.Configuration.init(orgId: orgId, sdkToken: token, logLevel: .verbose, enableLog: true)
    }

    @objc public func start() {
        mistManager.start(with: sdkConfig, delegate: self)
    }

    @objc public func stop() {
        mistManager.stop()
    }
}


extension MistSDKManager: IndoorLocationDelegate {
    public func didReceive(event: Mist.Event) {
        switch event {
        case .onMapUpdate(let map):
            let mistMap = map.toMistMap
            currentMap = mistMap
            delegate?.didUpdateMap(mistMap)

        case .onRelativeLocationUpdate(let relativeLocation):
            guard let map = currentMap else { return }
            let location = CGPoint(x: relativeLocation.x * map.ppm, y: relativeLocation.y * map.ppm)
            NSLog(">>> didUpdateRelativeLocation x = %f y = %f lat = %f lon = %f", location.x, location.y, relativeLocation.lat, relativeLocation.lon)
            delegate?.didUpdateLocation(location)

        case .onError(let error):
            delegate?.didFailWithError(error.localizedDescription)

        default:
            break
        }
    }
}

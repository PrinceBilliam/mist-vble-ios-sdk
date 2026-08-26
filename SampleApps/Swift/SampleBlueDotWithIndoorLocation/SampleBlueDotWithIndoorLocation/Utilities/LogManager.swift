//
//  LogManager.swift
//  SampleBlueDotWithIndoorLocation
//

import Foundation

extension Notification.Name {
    static let newLogMessage = Notification.Name("newLogMessage")
}

class LogManager {
    static let shared = LogManager()
    private(set) var logs: [String] = []

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss.SSS"
        return f
    }()

    private init() {}

    func append(_ message: String) {
        let timestamp = dateFormatter.string(from: Date())
        let entry = "[\(timestamp)] \(message)"
        logs.append(entry)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .newLogMessage, object: entry)
        }
    }
}

func appLog(_ items: Any..., separator: String = " ") {
    let message = items.map { "\($0)" }.joined(separator: separator)
    debugPrint(message)
    LogManager.shared.append(message)
}

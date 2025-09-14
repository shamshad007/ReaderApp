//
//  Reachability.swift
//  ReaderApp
//
//  Created by Md Shamshad Akhtar on 14/09/25.
//

import Foundation
import Network

class NetworkChecker {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    var onStatusChange: ((Bool) -> Void)?

    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            let isAvailable = path.status == .satisfied
            DispatchQueue.main.async {
                self.onStatusChange?(isAvailable)
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}


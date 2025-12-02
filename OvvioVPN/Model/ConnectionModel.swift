//
//  ConnectionModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import SwiftUI

// Connection State
enum VPNConnectionState {
    case disconnected
    case connecting // Optional intermediate state
    case connected
    case disconnecting // Optional intermediate state
}

// Simple Server Info for Display
struct ConnectedServerInfo: Identifiable {
    let id = UUID()
    let flagImageName: String
    let country: String
    let cityAndIP: String // e.g., "Paris - 198.162.12.1"
    let pingMillis: Int

    var pingColor: Color {
        switch pingMillis {
        case 0..<50: return .green
        case 50..<100: return .orange
        default: return .red
        }
    }
}

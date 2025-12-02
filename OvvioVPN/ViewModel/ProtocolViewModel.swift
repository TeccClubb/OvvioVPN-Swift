//
//  ProtocolViewModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import Combine
import SwiftUI


class SelectProtocolViewModel : ObservableObject{
    @Published var availableProtocol : [ProtocolInfo] = [
    ProtocolInfo(name: "WireGuard", description: "Experience next-gen speed with lightweight encryption and instant connectivity.", iconName: "rocket", strength: 5),
    ProtocolInfo(name: "OpenVPN", description: "Experience next-gen speed with lightweight encryption and instant connectivity.", iconName: "rocket", strength: 5)
    ]
    
    @Published var selectedProtocol : UUID? = nil
    
    init() {
        selectedProtocol = availableProtocol.first?.id
    }
    
    func selectProtocol(_ protocolInfo : ProtocolInfo) {
        selectedProtocol = protocolInfo.id
        print("Selcted Protcol : \(protocolInfo.name)")
    }
    
    

}

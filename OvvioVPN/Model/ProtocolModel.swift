//
//  ProtocolModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import SwiftUI

struct ProtocolInfo:Identifiable,Equatable {
    let id = UUID()
    let name : String
    let description : String
    let iconName : String
    let strength : Int
}

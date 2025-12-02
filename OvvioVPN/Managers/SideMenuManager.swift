//
//  SideMenuManager.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import SwiftUI
import Combine // For ObservableObject

// This class holds the state of our side menu
class SideMenuManager: ObservableObject {
    @Published var isSideMenuOpen: Bool = false
//    @Published var alertDetails: CustomAlertDetails? = nil
    func open() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isSideMenuOpen = true
        }
    }

    func close() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isSideMenuOpen = false
        }
    }

    func toggle() {
        if isSideMenuOpen {
            close()
        } else {
            open()
        }
    }
}

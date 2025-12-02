//
//  OnboardingModel.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 27/10/2025.
//

import Foundation
import SwiftUI

// Optional: Struct for small feature tags shown on pages 2 & 3
struct FeatureTag: Identifiable {
    let id = UUID()
    let iconName: String // SF Symbol name
    let text: String
}

struct OnboardingPageData: Identifiable {
    let id = UUID()
    let imageName: String // Your asset name
    let titlePart1: String
    let titlePart2: String? // Optional second part for multi-color title
    let description: String
}

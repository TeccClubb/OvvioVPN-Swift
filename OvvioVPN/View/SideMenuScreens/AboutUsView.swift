//
//  AboutUsView.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 28/10/2025.
//

import Foundation
import SwiftUI

struct AboutUsView: View {
    @Environment(\.dismiss) var dismiss // To handle the back button

    var body: some View {
        VStack(spacing: 0) { // Main container
            
            // --- 1. Custom Header ---
            // Uses the same header style as your other screens
            AboutUsHeader(title: "About Us", action: {
                dismiss()
            })
            .background(Color(.systemBackground)) // Match background

            // --- 2. Scrollable Content ---
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    
                    // --- Hero Graphic ---
                    // A professional-looking hero image using your app logo
                    ZStack {
                        Circle()
                            .fill(Color.accentPurple.opacity(0.1)) // Faint glow
                            .frame(width: 150, height: 150)
                            .blur(radius: 20)
                        
                        Image(.logo) // Your app logo asset
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .padding(20)
                            .background(.regularMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    }
                    .padding(.top, 20)

                    // --- Main Content ---
                    VStack(alignment: .leading, spacing: 25) {
                        
                        // --- Our Mission Section ---
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Our Mission")
                                .font(.PoppinsBold(size: 24))
                                .foregroundColor(.primary) // Adaptive color
                            
                            Text("At Ovvio VPN, we believe in a free and open internet. Our mission is to provide cutting-edge privacy and security solutions that empower individuals to browse, stream, and communicate without fear of surveillance or data breaches.")
                                .font(.body)
                                .foregroundColor(.secondary) // Adaptive gray
                                .lineSpacing(5)
                        }

                        // --- Why Choose Us Section ---
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Why Choose Ovvio?")
                                .font(.PoppinsBold(size: 24))
                                .foregroundColor(.primary)
                            
                            BulletPointView(icon: "shield.lefthalf.filled", text: "Robust Encryption: Industry-leading protocols protect your data.")
                            BulletPointView(icon: "speedometer", text: "Blazing Fast Speeds: Stream and browse without buffering.")
                            BulletPointView(icon: "network", text: "Global Server Network: Access content from anywhere.")
                            BulletPointView(icon: "hand.raised.fill", text: "No-Log Policy: We never track, store, or share your online activity.")
                            BulletPointView(icon: "person.2.fill", text: "24/7 Customer Support: Always here to help you.")
                        }

                        // --- Our Team Section ---
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Our Team")
                                .font(.PoppinsBold(size: 24))
                                .foregroundColor(.primary)
                            
                            Text("We are a dedicated team of cybersecurity experts, developers, and privacy advocates passionate about building a safer internet for everyone. Our diverse backgrounds and shared commitment drive us to innovate and deliver the best possible VPN experience.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(5)
                        }
                        
                        // --- Social Media Links ---
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Connect With Us")
                                .font(.PoppinsBold(size: 24))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 25) {
                                Link(destination: URL(string: "https://twitter.com/ovviovpn")!) {
                                    Image(systemName: "x.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color(.label)) // Adaptive black/white
                                }
                                Link(destination: URL(string: "https://facebook.com/ovviovpn")!) {
                                    Image(systemName: "f.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue) // Facebook blue
                                }
                                Link(destination: URL(string: "mailto:support@ovviovpn.com")!) {
                                    Image(systemName: "envelope.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.accentPurple) // Your brand color
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center) // Center the social links
                        .padding(.top)

                    } // End content VStack
                    .padding() // Padding inside the ScrollView
                    
                } // End ScrollView
                
            } // End main VStack
            .background(Color(.white).ignoresSafeArea()) // Use system grouped background
            .navigationBarHidden(true)
            .ignoresSafeArea(.container, edges: .bottom) // Allow content to scroll to bottom edge
        }
    }
}

// MARK: - Helper Views (Included in the file)

// Reusable Bullet Point View
struct BulletPointView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundColor(.accentPurple) // Your accent color
                .frame(width: 20) // Align icons
            Text(text)
                .font(.body)
                .foregroundColor(.secondary) // Use secondary for body text
            Spacer()
        }
    }
}

// Your AboutUsHeader struct (Adapted for Light/Dark mode)
struct AboutUsHeader: View {
    let title: String
    let action : () -> Void
    
    var body: some View {
        HStack {
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.medium))
                    .foregroundColor(Color(.label)) // Adaptive color
                    .padding(8)
                    .clipShape(Circle())
            }

            Spacer()
            Text(title)
                .font(.PoppinsSemiBold(size: 20))
                .foregroundColor(Color(.label)) // Adaptive color
            Spacer()

            Circle().fill(Color.clear).frame(width: 40, height: 40) // Balance layout
        }
        .padding(.horizontal)
        .padding(.top, 5)
        .padding(.bottom, 10)
    }
}


// --- Placeholders (Remove if you have these elsewhere) ---

// --- End Placeholders ---


// MARK: - Previews
#Preview {
    NavigationStack {
        AboutUsView()
    }
}

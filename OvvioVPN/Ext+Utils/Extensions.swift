//
//  Extensions.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 27/10/2025.
//

import Foundation

import SwiftUI


extension Font{
    static func PoppisRegular(size:CGFloat) -> Font{
        return .custom("Poppins-Regular", size: size)
    }
    
    static func PoppinsMedium(size:CGFloat) -> Font {
        return .custom("Poppins-Medium", size: size)
    }
    static func PoppinsBold(size:CGFloat) -> Font {
        return .custom("Poppins-Bold", size: size)
    }
    static func PoppinsSemiBold(size: CGFloat) -> Font{
        return .custom("Poppins-SemiBold",size: size)
    }
    static func Orbitron(size:CGFloat) -> Font{
        return .custom("Orbitron-Variable.ttf", size: size)
    }
}

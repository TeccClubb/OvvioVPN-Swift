//
//  APIRoutes.swift
//  OvvioVPN
//
//  Created by Saad Suleman on 29/10/2025.
//

import Foundation
import Alamofire

enum VPNAPI: URLRequestConvertible {

  case signup(name: String, email: String, password: String)
  case login(email: String, password: String,deviceId:String,deviceName:String,platform:String,deviceType:String,IpAdress:String)
  case googleLogin(token:String)
  case appleLogin(idtoken:String)
     
  case forgotPassword(email: String)
  case getServer(platform: String, token: String)
  case getUser(token: String)

  case getPlans
  case addPurchase(planId: String, token: String)
  case getActivePurchase(token: String)
  case privacyPolicy
  case feedback(email: String, subject: String, message: String, token: String)
  case delAccount(token: String)
  case registerClient(ip: String, client_name: String, password: String, token: String)  // ✅ NEW CASE
  case requestQRCode
  case manualLogin(email: String, password: String, device_id: String)

  // Registering  client for VPN connectivity
  case checkClientStatus(ip: String, clientName: String, token: String)
  case deleteClient(ip: String, clientName: String, token: String)

  var baseURL: String {
    return APIConstant.baseURL
  }

  var path: String {
    switch self {
    case .signup: return "/api/signup"
    case .login: return "/api/login"
    case.googleLogin : return "api/login/google"
    case.appleLogin : return "api/login/apple"
    case .forgotPassword: return "/api/forgot-password"
    //        case .QRLogin: return "/api/login/qr/status"
    case .getServer: return "/api/servers"
    case .getUser: return "/api/user"

    case .getPlans: return "/api/plans"
    case .addPurchase: return "/api/purchase/add"
    case .getActivePurchase: return "/api/subscription/active"
    case .privacyPolicy: return "/api/options"
    case .feedback: return "/api/feedback/store"
    case .delAccount: return "/api/user/delete"
    case .registerClient: return "/api/vpn/register-client"
    case .requestQRCode: return "/api/login/qr/request"
    case .manualLogin: return "/api/login"

    case .checkClientStatus(_, let clientName, _):
      return "/api/ikev2/clients/\(clientName)"
    case .deleteClient(_, let clientName, _):
      return "/api/ikev2/clients/\(clientName)"

    }
  }

  var method: HTTPMethod {
    switch self {
    case .signup, .login,.appleLogin, .googleLogin,.forgotPassword, .addPurchase, .feedback, .registerClient, .requestQRCode,
      .manualLogin:
      return .post
    case .getServer, .getUser, .getPlans, .getActivePurchase, .privacyPolicy, .checkClientStatus:
      return .get
    case .delAccount, .deleteClient:
      return .delete
    }
  }

  var parameters: Parameters? {
    switch self {
    case .signup(let name, let email, let password):
      return ["name": name, "email": email, "password": password]
    case .login(let email, let password, let deviceId, let deviceName, let platform, let deviceType, let ipAddress):
        return [
            "email": email,
            "password": password,
            "device_id": deviceId,
            "device_name": deviceName,
            "platform": platform,
            "device_type": deviceType,
            "ip_address": ipAddress
        ]

    case.googleLogin(let token) :
        return ["token" : token]
    case.appleLogin(idtoken: let token):
        return ["id_token" : token]
    case .forgotPassword(let email):
      return ["email": email]

    case .getServer(let platform, _):
      return ["platform": platform]
    case .getUser, .getPlans, .getActivePurchase, .privacyPolicy, .delAccount, .requestQRCode:
      return nil
    case .addPurchase(let planId, _):
      return ["plan_id": planId]
    case .feedback(let email, let subject, let message, _):
      return [
        "email": email,
        "subject": subject,
        "message": message,
      ]
    case .registerClient(let ip, let client_name, let password, _):
      return [
        "ip": ip,
        "client_name": client_name,
        "password": password,
      ]  // ✅ NEW BODY
    case .manualLogin(let email, let password, let deviceID):
      return [
        "email": email,
        "password": password,
        "device_id": deviceID,
      ]
    case .checkClientStatus, .deleteClient:
      return nil

    }
  }

  var headers: HTTPHeaders? {
    switch self {
    case .signup, .login,.appleLogin,.googleLogin, .forgotPassword, .privacyPolicy, .requestQRCode, .manualLogin:
      return [
        "Content-Type": "application/json",
        "Accept": "application/json",
      ]
    case .getServer(_, let token),
      .getUser(let token),
      .addPurchase(_, let token),
      .getActivePurchase(let token),
      .feedback(_, _, _, let token),
      .delAccount(let token),
      .registerClient(_, _, _, let token):
      return [
        "Authorization": "Bearer \(token)",
        "Accept": "application/json",
        "Content-Type": "application/json",
      ]
    case .getPlans:
      return nil

    case .checkClientStatus(_, _, let token),
      .deleteClient(_, _, let token):
      return [
        "X-Api-Token": token,
        "Accept": "application/json",
        "Content-Type": "application/json",
      ]

    }
  }

  func asURLRequest() throws -> URLRequest {
    let url = try baseURL.asURL()
    var request = URLRequest(url: url.appendingPathComponent(path))
    request.method = method

    // Add headers
    if let headers = headers {
      for header in headers {
        request.setValue(header.value, forHTTPHeaderField: header.name)
      }
    }

    // Encode parameters
    switch method {
    case .get:
      return try URLEncoding.default.encode(request, with: parameters)
    default:
      return try JSONEncoding.default.encode(request, with: parameters)
    }
  }
}

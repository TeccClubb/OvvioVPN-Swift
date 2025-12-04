import Foundation
import Alamofire

class APIManager {
    static let shared = APIManager()
    private init() {}

    func request<T: Decodable>(
        _ api: VPNAPI,
        completion: @escaping (Result<T, AFError>, Data?) -> Void
    ) {
        AF.request(api)
            .validate(statusCode: 200..<600) // Accept all valid HTTP responses
            .responseData { response in
                
               //  Print response for debugging
                #if DEBUG
                if let data = response.data {
                    print("📦 API Response:", String(data: data, encoding: .utf8) ?? "nil")
                }
                print("🌐 Status Code:", response.response?.statusCode ?? 0)
                #endif
                
                // Always pass response.data back, whether success or failure
                let responseData = response.data

                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(decoded), responseData)
                    } catch {
                        let afError = AFError.responseSerializationFailed(reason: .decodingFailed(error: error))
                        completion(.failure(afError), responseData)
                    }

                case .failure(let error):
                    completion(.failure(error), responseData)
                }
            }
    }
}

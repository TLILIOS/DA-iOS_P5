//
//  service.swift
//  Aura
//
//  Created by MacBook Air on 20/09/2024.
//

import Foundation
enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
}

enum NetworkEndPoint {
    case auth(username: String, password: String)
    case account
     
    var method: HTTPMethod {
        switch self {
        case .account: return .get
        case .auth: return .post
        }
    }
    var path: String {
        switch self {
        case .account: return "account"
        case .auth: return "auth"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .auth(let username, let password):
            return ["username": username, "password": password]
        case .account:
            return [:]
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case url
    case unknown
    case parsing
    case server(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .url: return "URL is invalid"
        case .unknown: return "Unknown error"
        case .parsing: return "Error parsing data"
        case .server(let statusCode): return "Server error with status code \(statusCode)"
        }
    }
}

final class NetworkService {
    
    private enum Constant {
        static let urlString = "http://127.0.0.1:8080/"
    }
    
    private let session: URLSession
    private let token: String //Token ajouté
    
    init(session: URLSession = .shared, token: String) {
        self.session = session
        self.token = token //Initialisation du token
    }
    
    
    
    func fetch<T:Decodable>(endpoint: NetworkEndPoint) async -> Result<T, Error> {
        guard let url = URL(string: Constant.urlString + endpoint.path) else {
            return .failure(NetworkError.url)
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        print("Token being used: \(token)")
        
        // Ajout du token dans l'en-tete Authorization
        request.setValue("Bearer\(token)", forHTTPHeaderField: "Authorization")
        // Handle parameters for non-GET requests
        if endpoint.method != .get {
            request.httpBody = try? JSONSerialization.data(withJSONObject: endpoint.parameters, options: .prettyPrinted)
            request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(NetworkError.unknown)
            }
            print("HTTP Response Status Code: \(httpResponse.statusCode)")
            if let responseData = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseData)")
            }
            switch httpResponse.statusCode {
            case 200 ... 299:
                do {
                    let dataparsed = try JSONDecoder().decode(T.self, from: data)
                    return .success(dataparsed)
                } catch {
                    print("Parsing failed: \(error.localizedDescription)")
                    return .failure(NetworkError.parsing)
                }
            case 300 ... 399:
                return .failure(NetworkError.server(statusCode: httpResponse.statusCode))
            case 400 ... 499:
                return .failure(NetworkError.server(statusCode: httpResponse.statusCode))
            case 500 ... 599:
                return .failure(NetworkError.server(statusCode: httpResponse.statusCode))
            default:
                return .failure(NetworkError.unknown)
            }
        } catch {
            print("Network error:\(error.localizedDescription)")
            return .failure(NetworkError.unknown)
        }
        
        
    }
}

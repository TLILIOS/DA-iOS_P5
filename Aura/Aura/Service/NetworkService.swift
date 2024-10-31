//
//  service.swift
//  Aura
//
//  Created by MacBook Air on 20/09/2024.
//

import Foundation
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkEndPoint {
    case auth(username: String, password: String)
    case account
    case transfer(recipient: String, amount: Decimal)
    
    var method: HTTPMethod {
        switch self {
        case .account: return .get
        case .auth: return .post
        case .transfer:
            return .post
        }
    }
    var path: String {
        switch self {
        case .account: return "account"
        case .auth: return "auth"
        case .transfer:
            return "account/transfer"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .auth(let username, let password):
            return ["username": username, "password": password]
        case .account:
            return [:]
        case .transfer(let recipient, let amount):
            return ["recipient": recipient, "amount": amount]
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case url
    case unknown
    case parsing
    case unauthorized
    case server(statusCode: Int)
    case token
    
    var errorDescription: String? {
        switch self {
        case .url: return "URL is invalid"
        case .unknown: return "Unknown error"
        case .parsing: return "Error parsing data"
        case .token: return "Token is invalid"
        case .server(let statusCode): return "Server error with status code \(statusCode)"
        case .unauthorized:
            return "Unauthorized"
        }
    }
}

class NetworkService {
    
    @Published var errorMessage: String?
    private enum Constant {
        static let urlString = "http://127.0.0.1:8080/"
    }
    
    private let session: URLSession
    
    
    init(session: URLSession = .shared) {
        self.session = session
    }
   
    
    func fetch<T:Decodable>(endpoint: NetworkEndPoint) async -> Result<T, Error> {
        // Construction de l'URL
        guard let url = URL(string: Constant.urlString + endpoint.path) else {
            return .failure(NetworkError.url)
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        // Ajout du token dans l'en-tete de la rquete
        request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
       if let token = KeychainService.shared.getValue(for: "authToken") {
           print("Token found in Keychain: \(token)")
           // Update Network Service avec le token
           
           request.setValue(token, forHTTPHeaderField: "token")
          
        }
        
        
    // Gestion des paramètres pour les requêtes non-GET
        if endpoint.method != .get {
            if let httpBody = try? JSONSerialization.data(withJSONObject: endpoint.parameters, options: .prettyPrinted) {
                request.httpBody = httpBody
            } else {
                // un retour d'erreur si l'encodage échoue
                return .failure(NetworkError.parsing)
            }
        }
        
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "No Body")")
        
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
                if data.isEmpty {
                    // Si la réponse est vide, retourner Void si c'est possible
                    return .success(EmptyResponse() as! T) // Utiliser Void si aucune donnée n'est attendue
                } else {
                    // Si la réponse contient des données, les décoder
                    
                    let dataparsed = try JSONDecoder().decode(T.self, from: data)
                    return .success(dataparsed)
                }
                
            case 300 ... 399:
                return .failure(NetworkError.server(statusCode: httpResponse.statusCode))
            case 401:
                return .failure(NetworkError.unauthorized)
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


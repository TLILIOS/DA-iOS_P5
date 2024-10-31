//
//@testable import Aura
//import Foundation
//
//class MockNetworkService: NetworkService {
//    var shouldReturnError = false
//    var mockAccountDetailResponse: AccountDetailResponse?
//    var mockAuthResponse: AuthenticationResponse?
//    var mockTransactionResponse: EmptyResponse?// Propriété pour la réponse de transfert
//    override func fetch<T>(endpoint: NetworkEndPoint) async -> Result<T, Error> where T: Decodable {
//        if shouldReturnError {
//            return .failure(NetworkError.unauthorized)// Retourne une erreur si le flag est activé
//        }
//        // Retourne une réponse simulée en fonction de l'endpoint utilisé
//        switch endpoint {
//        case .auth:
//            // Tente de renvoyer la réponse simulée pour l'authentification
//            if let authResponse = mockAuthResponse as? T {
//                print("Mock: Réponse d'authentification réussie avec un token.")
//                return .success(authResponse)
//            } else {
//                print("Mock: Pas de réponse d'authentification simulée trouvée.")
//            }
//        case .account:
//            // Tente de renvoyer la réponse simulée pour le détail du compte
//            if let accountResponse = mockAccountDetailResponse as? T {
//                return .success(accountResponse)
//            }
//       
//        case .transfer(let recipient, let amount): // Gestion de l'endpoint avec paramètres
//            if let transactionResponse = mockTransactionResponse as? T {
//                print("Mock: Réponse de transfert réussie pour \(recipient) d'un montant de \(amount)")
//                return .success(transactionResponse)
//            }
//            
//        }
//        
//        return .failure(NetworkError.parsing) // Erreur par défaut si rien n'est renvoyé
//        
//    }
//}
@testable import Aura
import Foundation

enum NetworkError: Error, LocalizedError {
    case unauthorized
    case networkFailure
    case parsing
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Unauthorized access."
        case .networkFailure:
            return "Network error"
        case .parsing:
            return "Parsing error"
        }
    }
}
class MockNetworkService: NetworkService {
    var shouldReturnError = false
    var errorType: NetworkError = .unauthorized // Propriété pour définir le type d'erreur
    var mockAccountDetailResponse: AccountDetailResponse?
    var mockAuthResponse: AuthenticationResponse?
    var mockTransactionResponse: EmptyResponse?

    override func fetch<T>(endpoint: NetworkEndPoint) async -> Result<T, Error> where T: Decodable {
        if shouldReturnError {
            // Retourne le type d'erreur spécifié
            return .failure(errorType)
        }

        // Retourne une réponse simulée en fonction de l'endpoint utilisé
        switch endpoint {
        case .auth:
            if let authResponse = mockAuthResponse as? T {
                print("Mock: Réponse d'authentification réussie avec un token.")
                return .success(authResponse)
            } else {
                print("Mock: Pas de réponse d'authentification simulée trouvée.")
            }
        case .account:
            if let accountResponse = mockAccountDetailResponse as? T {
                return .success(accountResponse)
            }
        case .transfer(let recipient, let amount):
            if let transactionResponse = mockTransactionResponse as? T {
                print("Mock: Réponse de transfert réussie pour \(recipient) d'un montant de \(amount)")
                return .success(transactionResponse)
            }
        }

        return .failure(NetworkError.parsing) // Erreur par défaut si rien n'est renvoyé
    }
}

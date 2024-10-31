//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    var onLoginSucceed: (() -> Void)
    
    //Initializing without a token for the login process
    var networkService: NetworkService
    var keychainService: KeychainServiceProtocol
    // Injection du service de Keychain pour faciliter le test
        
   
    init(_ callback: @escaping () -> (), networkService: NetworkService = NetworkService(), keychainService: KeychainServiceProtocol = KeychainService.shared) { // Injection de dépendance
        self.onLoginSucceed = callback
        self.networkService = networkService
        self.keychainService = keychainService
        
// Utilisation d'un service partagé par défaut
    }
    //Verification de la validité de l'email
    func isValidEmail(_ email: String) -> Bool {
        // Vérifier si l'email n'est pas vide
            guard !email.isEmpty else {
                errorMessage = "Invalid email format"
                print("Email vide détecté, message d'erreur défini sur: \(errorMessage ?? "nil")")

                return false
            }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValid = emailPred.evaluate(with: email)
        if !isValid {
                errorMessage = "Invalid email format"
                print("Format email invalide, message d'erreur défini sur: \(errorMessage ?? "nil")")
            }
        return isValid
    }
    
    func login() {
        Task { @MainActor in
            
            guard isValidEmail(username) else {
                errorMessage = "Invalid email format"
                return
            }
            let result = await self.isValidAuthent(username: self.username, password: self.password)
            
            switch result {
            case .success(let response):
                guard  !response.token.isEmpty else {
                    errorMessage = "Token is empty."
                    return
                }
                // Save Token in keychain
                if saveToken(response.token) {
                    print("Login successful with token: \(response.token)")
                    onLoginSucceed()
                } else {
                    errorMessage = "Token could not be saved."
                }
            
            case .failure(let error):
                if let networkError = error as? NetworkError {
                                errorMessage = "Login failed: \(networkError.localizedDescription)"
                            } else {
                                errorMessage = "Login failed: \(error.localizedDescription)"
                            }
            }
        }
        
    }
    private func saveToken(_ token: String) -> Bool {
        print("Attempting to save token: '\(token)' with key 'authToken'")
        let saveResult = keychainService.setValue(token, for: "authToken")
        if saveResult {
            print("Token '\(token)' saved successfully with key 'authToken'")

        } else {
            print("Error: Unable to save the token to the Keychain.")
            
        }
        return saveResult
            
    }
    // Async function to validate authentication
    private func isValidAuthent(username: String, password: String) async -> Result<AuthenticationResponse, Error> {
        return await networkService.fetch(endpoint: .auth(username: username, password: password))
    }
}

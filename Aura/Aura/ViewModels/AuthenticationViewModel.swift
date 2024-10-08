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

    let onLoginSucceed: (() -> ())
    
    //Initializing without a token for the login process
    private var networkService = NetworkService( token: "")
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    //Verification de la validité de l'email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func login() {
        Task { @MainActor in
            guard isValidEmail(username) else {
                            print("Erreur : L'email est invalide.")
                            return
                        }
            let result = await self.isValidAuthent(username: self.username, password: self.password)
            
            switch result {
            case .success(let response):
                // Log the response to ensure we are receiving the token
                                print("Authentication successful, response: \(response)")
                guard !response.token.isEmpty else {
                    print("Error: Token is empty")
                    return
                }
                // Save Token in keychain
                let saveResult = KeychainService.shared.setValue(response.token, for: "authToken")
                if saveResult {
                    print("Token saved successfully")
                } else {
                    print("Error: Could not save token")
                    return // On quitte la fonction si le token n'est pas sauvegardé
                }
//                // Récupère le token depuis le Keychain pour validation
//                if let savedToken = KeychainService.shared.getValue(for: "authToken") {
//                    print("Saved token: \(savedToken)")
//                } else {
//                    print("Error: Could not retrieve saved token")
//                    return
//                }
                // Update network service with new token for future requests
                self.networkService = NetworkService(token: response.token)
                
                print("Login successful with token:\(response.token)")
                onLoginSucceed() // Exécute le callback de succès
            case .failure(let error):
                print("Login failed with error:\(error.localizedDescription)")
                
            }
        }
        
    }
    // Async function to validate authentication
    private func isValidAuthent(username: String, password: String) async -> Result<AuthenticationResponse, Error> {
        // Using the network service without a token for authentication
        let result: Result<AuthenticationResponse, Error> = await self.networkService.fetch(endpoint: .auth(username: username, password: password))
        switch result {
            case .success(let response):
                return .success(response) // Assurez-vous que cela renvoie l'objet décodé
            case .failure(let error):
                return .failure(error)
            }
    }
}

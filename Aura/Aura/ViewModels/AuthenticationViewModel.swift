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
           
            let result = await self.isValidAuthent(username: self.username, password: self.password)
            
            switch result {
            case .success(let response):
                // Save Token in UserDefaults
                KeychainService.shared.save(key: "userToken", value: response.token)
                
                // Update network service with new token for future requests
                self.networkService = NetworkService(token: response.token)
                
                print("Login successful with token:\(response.token)")
                onLoginSucceed()
            case .failure(let error):
                print("Login failed with error:\(error.localizedDescription)")
                
            }
        }
        
    }
    // Async function to validate authentication
    private func isValidAuthent(username: String, password: String) async -> Result<AuthenticationResponse, Error> {
        // Using the network service without a token for authentication
        return await self.networkService.fetch(endpoint: .auth(username: username, password: password))
    }
}

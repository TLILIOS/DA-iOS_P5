//
//  AuthenticationViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AuthenticationViewModel: ObservableObject {
    let authentUrl = URL(string: "http://127.0.0.1:8080/auth")!
    @Published var username: String = ""
    @Published var password: String = ""
   
    let onLoginSucceed: (() -> ())
    
    init(_ callback: @escaping () -> ()) {
        self.onLoginSucceed = callback
    }
    // To Do 1
    func login() {
        var request = URLRequest(url: authentUrl)
        request.httpMethod = "POST"
        
        let body = "methode=login&forma=email&type=json&username=test@aura.app&password=test123"
        request.httpBody = body.data(using: .utf8)
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return
            }
            guard let responseJSON = try? JSONDecoder().decode([String: String].self, from: data),
                  let token = responseJSON["token"] else {
                return
            }
            print(token)
        }
        task.resume()
        
        print("login with \(username) and \(password)")
        onLoginSucceed()
    }
}

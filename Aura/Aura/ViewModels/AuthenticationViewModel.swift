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
    @Published var errorMessage: String?
    let onLoginSucceed: (() -> ())
    
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
        // Validation de l'email avant l'envoi de la requête
                guard isValidEmail(username) else {
                    errorMessage = "E-mail invalide. Veuillez entrer un E-mail correcte."
                    return
                }
        var request = URLRequest(url: authentUrl)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["username": username, "password": password]
        
        //Convertir le dictionnaire en données JSON
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Erreur de conversion du body en JSON")
            return
        }
        request.httpBody = httpBody
        
        //Démarrez la tâche de session
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Erreur de requête : \(error?.localizedDescription ?? "Pas d'erreur")")
                return
            }
            
            guard let httpresponse = response as? HTTPURLResponse, httpresponse.statusCode == 200 else {
                print("Erreur de réponse : \(response.debugDescription)")
                return
            }
            //Essayez de décoder la réponse JSON
            do {
                if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                   let token = responseJSON["token"] {
                    //Le token est reçu avec succès
                    print("Token recu: \(token)")
                    //Stocker le token dans UserDefaults
                    UserDefaults.standard.set(token, forKey: "authToken")
                    //Appeler le callback sur le thread principal après la connexion réussie
                    DispatchQueue.main.sync {
                        //Appeler le callback sur le thread principal une fois le login réussi
                        self.onLoginSucceed()
                    }
                } else {
                    print("Format de réponse inattendu")
                }
                //            print(token)
            } catch {
                print("Erreur de décodage JSON : \(error)")
            }
        }
        task.resume()
        //Log pour vérifier que les valeurs d'entrée sont correctes
        print("login with \(username) and \(password)")
        onLoginSucceed()
    }
}

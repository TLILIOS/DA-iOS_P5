//
//  MoneyTransferViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class MoneyTransferViewModel: ObservableObject {
    @Published var recipient: String
    
    @Published var transferMessage: String?
    @Published var errorMessage: String?
    @Published var amount: Decimal
    @Published var amountString: String = "" {
        didSet {
            amount = Decimal(string: amountString) ?? 0
        }
    }
    
    private var networkService: NetworkService
    
    init(networkService: NetworkService, amount: Decimal, recipient: String) {
        self.networkService = networkService
        self.amount = amount
        self.recipient = recipient
        
    }
    
    @MainActor func sendMoney() async {
        // Valider le destinataire avant d'envoyer de l'argent
        guard isValidRecipient(recipient) else {
            errorMessage = "Destinataire invalide"
            return
        }
       
        let endpoint = NetworkEndPoint.transfer(recipient: recipient, amount: amount)
        // Envoie d'argent via le NetworkService
        let result: Result<EmptyResponse, Error> = await networkService.fetch(endpoint: endpoint)
        
        switch result {
        case .success:
            print("Transfert réussi")
            transferMessage = "Transfert de \(amount) à destination de \(recipient) a été effectué avec succès ✅"
        case .failure(let error):
            errorMessage = error.localizedDescription
            print("Erreur de transfert: \(error.localizedDescription)")
        }
    }
    
    //     Fonction pour valider le destinataire (email ou téléphone français)
    private func isValidRecipient(_ recipient: String) -> Bool {
        // Vérification si c'est un email
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        // Vérification si c'est un numéro de téléphone français (format +33 ou 0)
        let phonePattern = "^((\\+33|0)[1-9])([0-9]{8})$"
        let phonePred = NSPredicate(format: "SELF MATCHES %@", phonePattern)
        
        return emailPred.evaluate(with: recipient) || phonePred.evaluate(with: recipient)
    }
    
}


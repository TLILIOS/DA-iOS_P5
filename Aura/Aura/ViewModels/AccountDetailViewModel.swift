//
//  AccountDetailViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AccountDetailViewModel: ObservableObject {
    @Published var totalAmount: String = ""
    @Published var recentTransactions: [Transaction] = []
    @Published var errorMessage: String?
    var allTransactions: [Transaction] = []
    private var networkService = NetworkService(token: "")
    
    
    @MainActor func fetchAccountDetails()  async {
        guard let token = KeychainService
            .shared.getValue(for: "authToken") else {
            self.errorMessage = "Token not found"
            print("Token not found in Keychain")
            return
        }
        print("Token found in Keychain: \(token)")
        // Update Network Service avec le token
        self.networkService = NetworkService(token: token)
        
        let endpoint: NetworkEndPoint = .account
        let result: Result<[Transaction], Error> = await self.networkService.fetch(endpoint: endpoint)
        
        switch result {
        case .success(let transactions):
            self.recentTransactions = transactions
            self.allTransactions = transactions
            
            // Conversion et calcul du montant total
            let totalAmount = transactions.reduce(0.0) { total, transactions in total + (Double(transactions.amount) ?? 0.0)
            }
            self.totalAmount = String(format: "%.2f", totalAmount)
            print("Succes: Fetched account details")
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            print("Error:\(error.localizedDescription)")
        }
    
    }
}

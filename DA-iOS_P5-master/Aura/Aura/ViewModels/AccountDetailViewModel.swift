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
    var networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    @MainActor func fetchAccountDetails()  async {
        let endpoint: NetworkEndPoint = .account
        let result: Result<AccountDetailResponse, Error> = await self.networkService.fetch(endpoint: endpoint)
        
        switch result {
        case .success(let accountDetailResponse):
            self.recentTransactions = accountDetailResponse.transactions
            self.allTransactions = accountDetailResponse.transactions
            
            // Conversion et calcul du montant total
            let totalAmount = accountDetailResponse.transactions.reduce(Decimal(0.0)) { total, transactions in (total + transactions.value)
            }
            self.totalAmount = NSDecimalNumber(decimal: totalAmount).stringValue
            print("Succes: Fetched account details")
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            print("Error:\(error.localizedDescription)")
        }
        
    }
}

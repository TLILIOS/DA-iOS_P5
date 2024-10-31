//
//  AppViewModel.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import Foundation

class AppViewModel: ObservableObject {
    @Published var isLogged: Bool
    @Published var amount: Decimal
    @Published var recipient: String
    // Instance de NetworkService partagée
    private let networkService: NetworkService
    init() {
        isLogged = false
        networkService = NetworkService()
        amount = 0
        recipient = ""
    }
    
    var authenticationViewModel: AuthenticationViewModel {
        return AuthenticationViewModel { [weak self] in
            self?.isLogged = true
            
        }
    }
    
    var accountDetailViewModel: AccountDetailViewModel {
        return AccountDetailViewModel()
    }
    // Initialisation du ViewModel pour le transfert d'argent avec NetworkService injecté
    var moneyTransferViewModel: MoneyTransferViewModel {
        return MoneyTransferViewModel(networkService: networkService, amount: amount, recipient: recipient)
    }
   
}

//
//  AccountDetailViewModelTests.swift
//  AuraTests
//
//  Created by MacBook Air on 25/10/2024.
//

import Foundation
import XCTest
@testable import Aura

final class AccountDetailViewModelTests: XCTestCase {
    var viewModel: AccountDetailViewModel!
    var mockNetworkService: MockNetworkService!
    
    override func setUp() {
        super.setUp()
        
        // Initialisation du mock et du viewModel
        mockNetworkService = MockNetworkService()
        // Injection du service simulé
        viewModel = AccountDetailViewModel(networkService: mockNetworkService)
        
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    // Test: Vérifier le succès du chargement des détails du compte
    func testFetchAccountDetailsSuccess() async {
        // Préparer une réponse simulée
        let mockTransactions = [
            Transaction(label: "Achat 1", value: 50), Transaction(label: "Achat 2", value: 100)
        ]
        let mockResponse = AccountDetailResponse(transactions: mockTransactions, currentBalance: 150)
        mockNetworkService.mockAccountDetailResponse = mockResponse
        
        await viewModel.fetchAccountDetails()
        
        // Vérification des valeurs
        XCTAssertEqual(viewModel.recentTransactions, mockTransactions)
        XCTAssertEqual(viewModel.allTransactions, mockTransactions)
        XCTAssertEqual(viewModel.totalAmount, "150")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // Test: Vérifier la gestion de l'erreur de réseau
    func testFetchAccountDetailsFailure() async {
        // Configurer le mock pour retourner une erreur
        mockNetworkService.shouldReturnError = true
        
        await viewModel.fetchAccountDetails()
        
        // Vérification que le message d'erreur est défini
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.recentTransactions.count, 0)
        XCTAssertEqual(viewModel.totalAmount, "")
    }
}

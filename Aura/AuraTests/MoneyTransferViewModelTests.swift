import XCTest
@testable import Aura

final class MoneyTransferViewModelTests: XCTestCase {
    var viewModel: MoneyTransferViewModel!
    var mockNetworkService: MockNetworkService!

    override func setUp() {
        super.setUp()
        // Initialisation du mock et du viewModel
        mockNetworkService = MockNetworkService()
        viewModel = MoneyTransferViewModel(networkService: mockNetworkService, amount: 0, recipient: "")
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    // Test: Vérifier la mise à jour de `amount` lorsqu'on modifie `amountString`
        func testAmountStringDidSet() {
            viewModel.amountString = "123.45" // Affectation d'une valeur sous forme de chaîne
            XCTAssertEqual(viewModel.amount, Decimal(123.45), "La valeur de `amount` devrait être mise à jour à 123.45")

            viewModel.amountString = "invalid" // Test d'une chaîne non numérique
            XCTAssertEqual(viewModel.amount, Decimal(0), "La valeur de `amount` devrait être 0 si `amountString` n'est pas valide")

            viewModel.amountString = "1000" // Test d'une valeur entière
            XCTAssertEqual(viewModel.amount, Decimal(1000), "La valeur de `amount` devrait être mise à jour à 1000")
        }
    func testSendMoneyWithValidRecipient() async {
            // Définissez une réponse de transfert simulée pour un test sans erreur
            mockNetworkService.mockTransactionResponse = EmptyResponse()
            
            // Définir un destinataire valide et un montant
            viewModel.recipient = "test@example.com"
            viewModel.amount = 100
            
            await viewModel.sendMoney()
            
            // Vérifier qu'il n'y a pas de message d'erreur
            XCTAssertNil(viewModel.errorMessage, "Aucun message d'erreur ne devrait être défini pour un destinataire valide.")
            XCTAssertEqual(viewModel.transferMessage, "Transfert de 100 à destination de test@example.com a été effectué avec succès ✅")
        }
    // Test: Vérifier le succès de l'envoi d'argent
    func testSendMoneySuccess() async {
        let mockResponse = EmptyResponse() // Assurez-vous que ce type de réponse est défini dans votre modèle
        mockNetworkService.mockTransactionResponse = mockResponse // Définissez la réponse simulée pour le transfert
        viewModel.recipient = "test@example.com"
        viewModel.amount = 100
        
        await viewModel.sendMoney()
        
        XCTAssertEqual(viewModel.transferMessage, "Transfert de 100 à destination de test@example.com a été effectué avec succès ✅")
        XCTAssertNil(viewModel.errorMessage)
    }
    // Test: Vérifier le message d'erreur pour un destinataire invalide
        func testInvalidRecipient() async {
            viewModel.recipient = "invalidRecipient" // Destinataire invalide
            await viewModel.sendMoney()
            
            XCTAssertEqual(viewModel.errorMessage, "Destinataire invalide", "Le message d'erreur devrait indiquer que le destinataire est invalide.")
            XCTAssertNil(viewModel.transferMessage, "Aucun message de transfert ne devrait être défini pour un destinataire invalide.")
        }

 
    // Test: Vérifier la gestion de l'erreur lors de l'envoi d'argent
    func testSendMoneyFailure() async {
        mockNetworkService.shouldReturnError = true // Configurez le mock pour simuler une erreur
        viewModel.recipient = "test@example.com"
        viewModel.amount = 100
        
        await viewModel.sendMoney()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Unauthorized") // Ajustez le message d'erreur selon votre logique
        XCTAssertNil(viewModel.transferMessage)
    }
}


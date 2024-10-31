import XCTest
@testable import Aura

final class AuthenticationViewModelTests: XCTestCase {
    var viewModel: AuthenticationViewModel!
    var mockNetworkService: MockNetworkService!
    var mockKeychainService: MockKeychainService!
    var loginSucceeded: Bool = false
    
    override func setUp() {
        super.setUp()
        loginSucceeded = false
        mockNetworkService = MockNetworkService()
        mockKeychainService = MockKeychainService()
        viewModel = AuthenticationViewModel({ self.loginSucceeded = true }, networkService: mockNetworkService, keychainService: mockKeychainService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        mockKeychainService = nil
        super.tearDown()
    }
    
    func testValidEmailDoesNotSetErrorMessage() {
        // Initialiser un email valide
        viewModel.username = "valid@example.com"
        viewModel.password = "password"
        
        // Appeler la validation de l'email
        viewModel.login()
        
        // Vérifier qu'aucun message d'erreur n'est défini
        XCTAssertNil(viewModel.errorMessage, "Expected no error message for a valid email format.")
    }
    
    func testValidEmailFormat() {
        // Initialiser un email vide
        viewModel.username = ""
        
        // Appeler la fonction de validation d'email
        let isValid = viewModel.isValidEmail(viewModel.username)
        
        // Vérifier que le résultat est faux et que le message d'erreur est défini correctement
        XCTAssertFalse(isValid, "Expected validation to fail for empty email.")
        XCTAssertEqual(viewModel.errorMessage, "Invalid email format", "Expected error message for empty email format.")
        viewModel.username = "test@example.com"
        XCTAssertTrue(viewModel.isValidEmail(viewModel.username), "Expected email format to be valid.")
        
        viewModel.username = "invalid-email"
        XCTAssertFalse(viewModel.isValidEmail(viewModel.username), "Expected email format to be invalid.")
        
    }
    
    func testInvalidEmailFormats() {
        let invalidEmails = [" user@domain.com", "user@.com", "user@", "@domain.com"]
        for email in invalidEmails {
            viewModel.username = email
            XCTAssertFalse(viewModel.isValidEmail(viewModel.username), "Expected email format \(email) to be invalid.")
        }
    }
    
    func testLoginSucceedsWhenCredentialsAreCorrect() async {
        let expectation = XCTestExpectation(description: "Wait for login to succeed")
        
        let expectedToken = "validToken123"
        mockNetworkService.mockAuthResponse = AuthenticationResponse(token: expectedToken)
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        
        viewModel.login()
        
        // Attendre que la mise à jour de la variable soit terminée
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(self.viewModel.errorMessage, "Expected no error message on successful login.")
            XCTAssertTrue(self.loginSucceeded, "Expected login to succeed.")
            XCTAssertEqual(self.mockKeychainService.savedToken, expectedToken, "Expected token to be saved in Keychain.")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testLoginFailsWithInvalidCredentials() async {
        let expectation = XCTestExpectation(description: "Wait for login to fail with invalid credentials")
        
        mockNetworkService.shouldReturnError = true
        viewModel.username = "test@example.com"
        viewModel.password = "wrongpassword"
        
        viewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNotNil(self.viewModel.errorMessage, "Expected error message for invalid credentials.")
            XCTAssertFalse(self.loginSucceeded, "Expected login to fail.")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testTokenSaveFailureShowsErrorMessage() async {
        let expectation = XCTestExpectation(description: "Wait for token save failure to show error message")
        
        let expectedToken = "tokenToSave"
        mockNetworkService.mockAuthResponse = AuthenticationResponse(token: expectedToken)
        mockKeychainService.saveResult = false // Simuler l'échec de la sauvegarde
        
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        
        viewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "Token could not be saved.", "Expected error message when token save fails.")
            XCTAssertFalse(self.loginSucceeded, "Expected login to not succeed when token save fails.")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testLoginFailsWithEmptyToken() async {
        let expectation = XCTestExpectation(description: "Wait for login to fail with empty token")
        
        mockNetworkService.mockAuthResponse = AuthenticationResponse(token: "") // Token vide
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        
        viewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "Token is empty.", "Expected error message for empty token.")
            XCTAssertFalse(self.loginSucceeded, "Expected login to fail when token is empty.")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    func testLoginNetworkError() async {
        let expectation = XCTestExpectation(description: "Wait for network error")
        
        mockNetworkService.shouldReturnError = true
        mockNetworkService.errorType = .networkFailure // Définit une erreur de type réseau
        viewModel.username = "test@example.com"
        viewModel.password = "password"
        
        viewModel.login()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.viewModel.errorMessage, "Login failed: Network error", "Expected network error message.")
            XCTAssertFalse(self.loginSucceeded, "Expected login to fail on network error.")
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    
    func testInitialState() {
        XCTAssertEqual(viewModel.username, "", "Expected username to be initially empty.")
        XCTAssertEqual(viewModel.password, "", "Expected password to be initially empty.")
        XCTAssertNil(viewModel.errorMessage, "Expected errorMessage to be initially nil.")
    }
}


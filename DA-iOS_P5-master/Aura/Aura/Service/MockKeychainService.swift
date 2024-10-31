
import Foundation
class MockKeychainService: KeychainServiceProtocol {
    
    var saveResult: Bool = true
    private var storage: [String: String] = [:]
    var shouldReturnError = false // Propriété pour simuler un échec d'enregistrement
    var savedToken: String?
    
    // Sauvegarde d'une valeur avec possibilité d'échec simulé
    func setValue(_ value: String, for key: String) -> Bool {
        guard !shouldReturnError else { return false } // Échec simulé si `shouldReturnError` est activé
        storage[key] = value
        savedToken = value
        return saveResult // Retourne le résultat de sauvegarde simulé
    }
    
    // Récupération d'une valeur avec échec simulé
    func getValue(for key: String) -> String? {
        guard !shouldReturnError else { return nil } // Échec simulé si `shouldReturnError` est activé
        return storage[key]
    }
    
    // Suppression d'une valeur par clé, avec vérification de l'existence de la clé

    func deleteValue(for key: String) -> Bool {
        guard !shouldReturnError, storage[key] != nil else { return false } // Simule un échec de suppression
              storage.removeValue(forKey: key) // Supprime la valeur
              return true // Indique que la suppression a réussi
    }
    
    func removeValue(for key: String) -> Bool {
        storage.removeValue(forKey: key) != nil
    }
}

//
//  KeychainService.swift
//  Aura
//
//  Created by MacBook Air on 26/09/2024.
//
import Foundation
import Security

final class KeychainService {

    static let shared = KeychainService()
    
    private init() {}
    
    func save(key: String, value: String) -> OSStatus {
        // Convertir la valeur en données
        let data = value.data(using: .utf8)!
        
        // Créer une requête pour stocker la valeur
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Supprimer une ancienne valeur si elle existe
        SecItemDelete(query as CFDictionary)
        
        // Ajouter la nouvelle valeur
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    func getValue(for key: String) -> String? {
        // Créer une requête pour récupérer la valeur
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        
        // Exécuter la requête
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // Vérifier le statut
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    func deleteValue(for key: String) -> OSStatus {
        // Créer une requête pour supprimer la valeur
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        return SecItemDelete(query as CFDictionary)
    }
}

//
//  KeychainService.swift
//  Aura
//
//  Created by MacBook Air on 26/09/2024.
//
import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    // Stocker une valeur
    func setValue(_ value: String, for key: String) -> Bool {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Supprimer l'ancien objet s'il existe déjà
        SecItemDelete(query as CFDictionary)
        
        // Ajouter le nouvel objet
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }

    func getValue(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        if status == errSecSuccess, let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    // Supprimer une valeur pour une cle donnee
    func deleteValue(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
    //Verifier si une valeur existe pour une cle donnee
    func valueExists(for key: String) -> Bool {
        return getValue(for: key) != nil
    }
}

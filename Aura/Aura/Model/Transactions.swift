//
//  Transactions.swift
//  Aura
//
//  Created by MacBook Air on 25/09/2024.
//

import Foundation

struct Transaction: Codable, Identifiable, Equatable {
    var id = UUID()
    let label: String
    let value: Decimal
    enum CodingKeys: String, CodingKey {
        case label
        case value
    }
    // Custom init to decode Decimal
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.label = try container.decode(String.self, forKey: .label)

            // Decode `value` as Double first, then convert to Decimal
            let doubleValue = try container.decode(Double.self, forKey: .value)
            self.value = Decimal(doubleValue)
        }

        // Encode Decimal as Double for encoding
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(label, forKey: .label)
            
            // Convert Decimal to Double for encoding
            let doubleValue = NSDecimalNumber(decimal: value).doubleValue
            try container.encode(doubleValue, forKey: .value)
        }
    // Initialiseur personnalisé pour les tests ou les valeurs par défaut
    init(id: UUID = UUID(), label: String, value: Decimal) {
        self.id = id
        self.label = label
        self.value = value
    }
    
    // Conformité à `Equatable` en comparant les valeurs de toutes les propriétés
    static func == (lhs: Transaction, rhs: Transaction) -> Bool {
        lhs.id == rhs.id && lhs.label == rhs.label && lhs.value == rhs.value
    }
}

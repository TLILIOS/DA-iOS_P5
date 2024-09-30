//
//  Transactions.swift
//  Aura
//
//  Created by MacBook Air on 25/09/2024.
//

import Foundation

struct Transaction: Decodable, Identifiable {
    var id = UUID()
    let description: String
    let amount: String
}

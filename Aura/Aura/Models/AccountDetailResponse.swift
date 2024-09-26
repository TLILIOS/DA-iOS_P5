//
//  AccountDetailResponse.swift
//  Aura
//
//  Created by MacBook Air on 26/09/2024.
//

import Foundation
struct AccountDetailResponse: Decodable {
    let transactions: [Transaction]
    let currentBalance: Double
        
}

//
//  RecentTransactionsView.swift
//  Aura
//
//  Created by MacBook Air on 03/10/2024.
//

import SwiftUI

struct RecentTransactionsView: View {
    var transactions: [Transaction]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Transactions")
                .font(.headline)
                .padding([.horizontal])
            List(transactions.prefix(3)) { transaction in
                transactionRow(transaction)
                
            }
        }
    }
    // Fonction pour générer une ligne de transaction
    private func transactionRow(_ transaction: Transaction) -> some View {
        HStack {
            Image(systemName: (transaction.value >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill"))
                .foregroundColor(transaction.value >= 0 ? .green : .red)
            Text(transaction.label)
            Spacer()
            Text(NSDecimalNumber(decimal:transaction.value).stringValue)
                .fontWeight(.bold)
                .foregroundColor(transaction.value >= 0 ? .green : .red)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .padding([.horizontal])
    }
}

#Preview {
    RecentTransactionsView(transactions: [])
}

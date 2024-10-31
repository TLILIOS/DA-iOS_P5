//
//  AllTransactionsView.swift
//  Aura
//
//  Created by MacBook Air on 12/09/2024.
//

import SwiftUI

struct AllTransactionsView: View {
    @StateObject var viewModel = AccountDetailViewModel()
    var transaction: [Transaction]
    var body: some View {
        List(viewModel.recentTransactions) { transaction in
            HStack {
                Text(transaction.label)
                Spacer()
                Text(NSDecimalNumber(decimal:transaction.value).stringValue)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchAccountDetails()
            }
            
        }
    }
}

#Preview {
    AllTransactionsView(transaction: [])
}


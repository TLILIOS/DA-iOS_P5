//
//  AllTransactionsView.swift
//  Aura
//
//  Created by MacBook Air on 12/09/2024.
//

import SwiftUI

struct AllTransactionsView: View {
    @StateObject var viewModel = AccountDetailViewModel()
    var body: some View {
        List(viewModel.recentTransactions) { transaction in
                    HStack {
                        Text(transaction.description)
                        Spacer()
                        Text(transaction.amount)
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
    AllTransactionsView()
}

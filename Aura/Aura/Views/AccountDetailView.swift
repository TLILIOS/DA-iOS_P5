//
//  AccountDetailView.swift
//  Aura
//
//  Created by Vincent Saluzzo on 29/09/2023.
//

import SwiftUI

struct AccountDetailView: View {
    @ObservedObject var viewModel: AccountDetailViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Large Header displaying total amount
                HeaderView(totalAmount: viewModel.totalAmount)
                
                // Display recent transactions
                
                RecentTransactionsView(transactions: viewModel.recentTransactions)
                // Button to see details of transactions
                NavigationLink(destination: AllTransactionsView(transaction: viewModel.recentTransactions)) {
                    // Show transaction details
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("See Transaction Details")
                    }
                    .padding()
                    .background(Color(hex: "#94A684"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding([.horizontal, .bottom])
                
                Spacer()
            }
            // Appel de l'API lors de l'apparition de la vue
            .onAppear {
                Task {
                    await viewModel.fetchAccountDetails()
                }
                
            }
            .onTapGesture {
                self.endEditing(true)  // This will dismiss the keyboard when tapping outside
            }
        }
    }
}




#Preview {
    AccountDetailView(viewModel: AccountDetailViewModel())
}

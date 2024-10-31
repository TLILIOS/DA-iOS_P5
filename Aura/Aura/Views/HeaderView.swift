//
//  HeaderView.swift
//  Aura
//
//  Created by MacBook Air on 03/10/2024.
//

import SwiftUI

struct HeaderView: View {
    var totalAmount: String
    var body: some View {
        // Large Header displaying total amount
        VStack(spacing: 10) {
            Text("Your Balance")
                .font(.headline)
            Text(totalAmount)
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(Color(hex: "#94A684")) // Using the green color you provided
            Image(systemName: "eurosign.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .foregroundColor(Color(hex: "#94A684"))
        }
        .padding(.top)
    }
}

#Preview {
    HeaderView(totalAmount: "$7.000.000")
}

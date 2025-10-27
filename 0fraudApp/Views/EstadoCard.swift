//
//  EstadoCard.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//

import SwiftUI

struct EstadoCard: View {
    let title: String
    let color: Color
    let count: Int

    var body: some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.8), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6))
                )
        )
        .shadow(color: color.opacity(0.08), radius: 2, x: 0, y: 1) 
        .padding(.horizontal, 4)
    }
}

//
//  ComponentSuccessSummary.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import SwiftUI

struct ComponentSuccessSummary: View {
    let messages: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Operación exitosa")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            ForEach(messages, id: \.self) { msg in
                Text("✅ \(msg)")
                    .font(.subheadline)
                    .foregroundColor(.green.opacity(0.9))
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal)
        .transition(.opacity.combined(with: .scale))
        .animation(.easeOut(duration: 0.25), value: messages)
    }
}

#Preview {
    ComponentSuccessSummary(messages: ["Perfil actualizado correctamente."])
}

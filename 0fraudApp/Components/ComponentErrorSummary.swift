//
//  ComponentErrorSummary.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import SwiftUI

struct ComponentErrorSummary: View {
    let errors: [String]

    var body: some View {
        if !errors.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Se encontraron problemas:")
                    .font(.footnote).bold()
                ForEach(errors.prefix(3), id: \.self) { e in
                    HStack(alignment: .top, spacing: 6) {
                        Text("❌")
                        Text(e).font(.footnote)
                    }
                }
                if errors.count > 3 {
                    Text("…y \(errors.count - 3) más")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(Color(.systemRed).opacity(0.12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemRed).opacity(0.35), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    ComponentErrorSummary(errors: ["Perfil actualizado incorrectamente."])
}

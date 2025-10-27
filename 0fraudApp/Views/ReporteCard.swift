//
//  ReporteCard.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//

import SwiftUI

struct ReporteCard: View {
    let reporte: ReporteBackend

    var body: some View {
        NavigationLink(destination: DetalleReporteView(reporte: reporte)) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(reporte.titulo)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(reporte.autorNombre ?? "Anónimo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(reporte.descripcion)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                Text(reporte.categoria ?? "Sin categoría")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity, alignment: .trailing)

            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

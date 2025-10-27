//
//  DetalleReporteView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//

import SwiftUI

struct DetalleReporteView: View {
    let reporte: ReporteBackend

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DetalleReporteCard(reporte: reporte)
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

struct DetalleReporteCard: View {
    let reporte: ReporteBackend

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text(reporte.titulo)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(reporte.autorNombre ?? "Anónimo")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                ReporteInfoRow(label: "Categoría", value: reporte.categoria ?? "Sin categoría")

                VStack(alignment: .leading, spacing: 4) {
                    Text("URL")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(reporte.url)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            if let url = URL(string: reporte.url) {
                                UIApplication.shared.open(url)
                            }
                        }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Descripción")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(reporte.descripcion)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !reporte.imagenes.isEmpty {
                ImagenesCarouselView(imagenes: reporte.imagenes)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

//
//  ResultadosView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//

import SwiftUI

struct ResultadosView: View {
    let reportes: [ReporteBackend]

    var body: some View {
        VStack {
            if reportes.isEmpty {
                Spacer()
                Text("No se encontraron reportes con esa información")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                resultadosList
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 8)
    }

    private var resultadosList: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(reportes) { reporte in
                        ReporteCard(reporte: reporte)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Resultados")
                .font(.title2)
                .bold()
            Spacer()
            Text("\(reportes.count) resultados")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

//
//  ReportDetailView.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import SwiftUI

struct ReportDetailView: View {
    let report: ReportSummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if let imageUrl = report.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        case .failure, .empty:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .frame(height: 160)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 42))
                                        .foregroundStyle(.secondary)
                                )
                        @unknown default:
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                                .frame(height: 160)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 42))
                                        .foregroundStyle(.secondary)
                                )
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 42))
                                .foregroundStyle(.secondary)
                        )
                }

                HStack {
                    Text(report.title)
                        .font(.title3.bold())
                    Spacer()
                    StatusBadge(status: report.status)
                }

                if let created = report.createdAt {
                    Text(created.formatted(date: .abbreviated, time: .shortened))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Divider()

                Text(report.description.isEmpty ? "Sin descripción." : report.description)
                    .font(.body)
            }
            .padding(16)
        }
        .navigationTitle("Detalle del Reporte")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ReportDetailView(
            report: ReportSummary(
                id: 1,
                title: "Reporte 1",
                description: "Descripción de ejemplo…",
                status: .enRevision,
                createdAt: .now,
                imageUrl: nil
            )
        )
    }
}

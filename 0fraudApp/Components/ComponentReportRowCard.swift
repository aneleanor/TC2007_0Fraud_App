//
//  ComponentReportRowCard.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import SwiftUI

struct ReportRowCard: View {
    let report: ReportSummary
    var onMoreInfo: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            if let imageUrl = report.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 65, height: 65)
                            .cornerRadius(10)
                            .clipped()
                    case .failure, .empty:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(width: 65, height: 65)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                                    .font(.title3)
                            )
                    @unknown default:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(width: 65, height: 65)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundStyle(.secondary)
                                    .font(.title3)
                            )
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(width: 65, height: 65)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                    )
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(report.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    StatusBadge(status: report.status)
                }
                Text(report.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .layoutPriority(1)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .buttonStyle(.plain)
    }
}

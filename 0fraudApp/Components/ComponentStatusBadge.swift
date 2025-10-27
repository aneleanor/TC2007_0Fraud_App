//
//  ComponentStatusBadge.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import SwiftUI

struct StatusBadge: View {
    let status: ReportStatus
    var body: some View {
        Text(status.displayText)
            .font(.footnote.bold())
            .foregroundStyle(color(for: status))
    }

    private func color(for s: ReportStatus) -> Color {
        switch s {
        case .aprobado:   return .green
        case .enRevision: return .yellow
        case .rechazado:  return .red
        case .desconocido:return .gray
        }
    }
}

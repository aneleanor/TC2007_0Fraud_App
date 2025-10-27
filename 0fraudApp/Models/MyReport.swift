//
//  MyReport.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import Foundation

enum ReportStatus: String, Codable, CaseIterable, Hashable {
    case aprobado, enRevision, rechazado, desconocido

    var displayText: String {
        switch self {
        case .aprobado:   return "Aprobado"
        case .enRevision: return "En Revisión"
        case .rechazado:  return "Rechazado"
        case .desconocido:return "—"
        }
    }
}

struct ReportSummary: Identifiable, Hashable, Codable {
    let id: Int
    let title: String
    let description: String
    let status: ReportStatus
    let createdAt: Date?
    let imageUrl: String?
}


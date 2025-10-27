//
//  MyReportsController.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import Foundation
import SwiftUI

struct ReportsController {

    @AppStorage("authToken") private var token: String = ""

    func fetchReportSummaries() async throws -> [ReportSummary] {
        guard let url = URL(string: "http://localhost:4000/reports/my-reports") else { return [] }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else { return [] }

        let rawReports = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []

        let summaries: [ReportSummary] = rawReports.compactMap { dict in
            guard
                let id = dict["id"] as? Int,
                let title = dict["titulo"] as? String ?? dict["title"] as? String,
                let description = dict["descripcion"] as? String ?? dict["description"] as? String,
                let estadoStr = dict["estado"] as? String
            else { return nil }

            let status: ReportStatus
            switch estadoStr.lowercased().trimmingCharacters(in: .whitespaces) {
            case "aprobado":   status = .aprobado
            case "pendiente":  status = .enRevision
            case "rechazado":  status = .rechazado
            default:           status = .desconocido
            }

            let createdAt: Date?
            if let dateStr = dict["fechaCreacion"] as? String {
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                createdAt = formatter.date(from: dateStr)
            } else {
                createdAt = nil
            }

            let imageUrl: String?
            if let imagenes = dict["imagenes"] as? [String], let firstImage = imagenes.first {
                imageUrl = firstImage
            } else {
                imageUrl = nil
            }

            return ReportSummary(id: id, title: title, description: description, status: status, createdAt: createdAt, imageUrl: imageUrl)
        }

        return summaries
    }
}


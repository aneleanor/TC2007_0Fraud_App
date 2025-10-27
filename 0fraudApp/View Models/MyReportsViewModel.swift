//
//  MyReportsViewModel.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón  on 13/10/25.
//

import SwiftUI

@MainActor
final class ReportsListViewModel: ObservableObject {
    @Published var reports: [ReportSummary] = []
    @Published var isLoading = false
    @Published var errors: [String] = []

    func load() async {
        isLoading = true
        errors.removeAll()
        defer { isLoading = false }

        let service = ReportsController()

        do {
            let fetchedReports = try await service.fetchReportSummaries()
            reports = fetchedReports.sorted { (report1, report2) in
                guard let date1 = report1.createdAt, let date2 = report2.createdAt else {
                    return false
                }
                return date1 > date2
            }
        } catch {
            print("Error al cargar reportes:", error.localizedDescription)
            errors = ["No pudimos cargar tus reportes.", error.localizedDescription]
        }
    }
}

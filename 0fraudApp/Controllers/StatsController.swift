//
//  StatsController.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import SwiftUI

@MainActor
final class StatsController: ObservableObject {
    @AppStorage("authToken") private var authToken = ""
    @AppStorage("refreshToken") private var refreshToken = ""
    
    @Published var categoryStats: [CategoryStat] = []
    @Published var monthlyStats:  [TimeSeriesPoint] = []
    @Published var topSites:      [SiteStat] = []
    @Published var statusStats:   [StatusStat] = []
    
    @Published var isLoading = false
    @Published var errors: [String] = []
    
    // MARK: - Cargar estadisticas
    func loadAll() async {
        errors.removeAll()
        isLoading = true
        defer { isLoading = false }
        
        guard !authToken.isEmpty else {
            self.errors = ["Token no disponible. Inicia sesión nuevamente."]
            return
        }

        
        let client = HTTPClient()
        
        do {
            async let sites = client.fetchTopSites(token: authToken)
            async let categories = client.fetchReportsByCategory(token: authToken)
            async let months = client.fetchReportsByMonth(token: authToken)
            
            self.topSites = try await sites
            self.categoryStats = try await categories
            self.monthlyStats = try await months
            
            print("Estadísticas cargadas correctamente")
            
        } catch let error as APIError {
            self.errors = [error.localizedDescription]
            print("APIError:", error.localizedDescription)
        } catch {
            self.errors = ["No se pudieron cargar las estadísticas."]
            print("Error genérico:", error.localizedDescription)
        }
    }
}

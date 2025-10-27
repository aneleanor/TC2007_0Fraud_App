//
//  HomeViewModel.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var reportes: [ReporteBackend] = []
    @Published var isLoading = false
    @Published var showResultados = false
    @Published var dailyTip: (titulo: String, contenido: String)?
    private var httpClient = HTTPClient()
    
    @AppStorage("authToken") var token: String = ""
    
    func buscarReportes(query: String? = nil, navigateToResults: Bool = false) {
        let q = query ?? searchText
        guard !q.isEmpty else { return }
        isLoading = true
        if navigateToResults {
            showResultados = false
        }

        let urlString = "http://localhost:4000/reports/search?q=\(q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, _ in
            DispatchQueue.main.async { self?.isLoading = false }
            guard let data = data else { return }

            if let decoded = try? JSONDecoder().decode([ReporteBackend].self, from: data) {
                DispatchQueue.main.async {
                    self?.reportes = decoded
                    if navigateToResults {
                        self?.showResultados = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.reportes = []
                    if navigateToResults {
                        self?.showResultados = true
                    }
                }
            }
        }.resume()
    }


        func fetchDailyTip() async {
            do {
                let tip = try await httpClient.fetchDailyTip()
                self.dailyTip = tip
            } catch {
                print("Error al obtener tip del día:", error.localizedDescription)
            }
        }
        
    
}

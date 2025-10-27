//
//  NewsAPIClient.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 22/10/25.
//

import Foundation

@MainActor
class NewsAPIClient: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiKey = "b73f20d3a2f64fe983c13a44abcf152a"

    func fetchNews() async {
        isLoading = true
        defer { isLoading = false }

        // Buscar noticias relacionadas con fraude y ciberseguridad
        let query = "\"ciberseguridad\" OR \"Phishing\" OR \"Cyber Attacks\""
        let domains = "bbc.com,elpais.com,cnn.com,infobae.com,elconfidencial.com"
        let urlString = "https://newsapi.org/v2/everything?q=\(query)&language=es&pageSize=10&domains=\(domains)&apiKey=\(apiKey)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        guard let url = URL(string: urlString) else {
            errorMessage = "URL inválida"
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                errorMessage = "Error del servidor"
                return
            }

            let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
            self.articles = decoded.articles
        } catch {
            errorMessage = "Error cargando noticias: \(error.localizedDescription)"
        }
    }
}

struct NewsResponse: Codable {
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    let id = UUID()
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
}

//
//  HTTPClient.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import Foundation
import SwiftUI

enum APIError: LocalizedError {
    case invalidResponse
    case http(Int, String?)
    case decoding(Error)
    case transport(Error)
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Respuesta inválida del servidor."
        case let .http(code, msg): return msg ?? "Error de servidor (\(code))."
        case let .decoding(e): return "Error decodificando respuesta: \(e.localizedDescription)"
        case let .transport(e): return "Error de red: \(e.localizedDescription)"
        case .sessionExpired: return "Tu sesión ha expirado. Inicia sesión nuevamente."
        }
    }
}

// MARK: - token refresh
actor TokenRefreshManager {
    private var refreshTask: Task<String, Error>?

    func refreshToken(refreshToken: String) async throws -> String {
        if let existingTask = refreshTask {
            return try await existingTask.value
        }

        let task = Task<String, Error> {
            let url = APIConfig.baseURL.appending(path: "/auth/refresh")

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = RefreshTokenRequest(refreshToken: refreshToken)
            request.httpBody = try JSONEncoder().encode(body)

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

            guard (200...299).contains(http.statusCode) else {
                throw APIError.sessionExpired
            }

            let refreshResponse = try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
            return refreshResponse.accessToken
        }

        refreshTask = task

        do {
            let newToken = try await task.value
            refreshTask = nil
            return newToken
        } catch {
            refreshTask = nil
            throw error
        }
    }
}

struct HTTPClient {
    private var accessToken: String?
    private let refreshManager = TokenRefreshManager()

    mutating func setAccessToken(_ token: String) {
        self.accessToken = token
    }

    // MARK: - hacer el request
    private func performAuthenticatedRequest<T: Decodable>(
        _ request: URLRequest,
        token: String,
        refreshToken: String,
        decode: Bool = true
    ) async throws -> (data: Data, newToken: String, decoded: T?) {
        var currentToken = token
        var currentRequest = request
        var attemptCount = 0

        while attemptCount < 2 {
            currentRequest.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: currentRequest)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

            if http.statusCode == 401 && attemptCount == 0 {
                do {
                    currentToken = try await refreshManager.refreshToken(refreshToken: refreshToken)
                    attemptCount += 1
                    continue
                } catch {
                    throw APIError.sessionExpired
                }
            }

            guard (200...299).contains(http.statusCode) else {
                let serverMessage = String(data: data, encoding: .utf8)
                throw APIError.http(http.statusCode, serverMessage)
            }
            
            if decode {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return (data: data, newToken: currentToken, decoded: decoded)
            } else {
                return (data: data, newToken: currentToken, decoded: nil)
            }
        }

        throw APIError.sessionExpired
    }


    // MARK: - Auth
    func login(correo: String, contrasena: String) async throws -> LoginResponse {
        let url = APIConfig.baseURL.appending(path: "/auth/login")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = LoginRequest(correo: correo, contrasena: contrasena)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        guard (200...299).contains(http.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8)
            throw APIError.http(http.statusCode, serverMessage)
        }

        return try JSONDecoder().decode(LoginResponse.self, from: data)
    }

    func register(correo: String, nombre: String, apellidos: String, contrasena: String) async throws {
        let url = APIConfig.baseURL.appending(path: "/users")

        print("📤 POST \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RegisterRequest(correo: correo, nombre: nombre, apellidos: apellidos, contrasena: contrasena)
        request.httpBody = try JSONEncoder().encode(body)

        if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        print("📥 Status: \(http.statusCode)")

        guard (200...299).contains(http.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8)
            print("⚠️ Server response: \(serverMessage ?? "no message")")
            throw APIError.http(http.statusCode, serverMessage)
        }

        print("✅ Registro completado")
    }

    // MARK: - Perfil de uduario
    func updateProfile(correo: String?, nombre: String?, apellidos: String?, contrasena: String?, token: String, refreshToken: String) async throws -> (response: UpdateProfileResponse, newToken: String) {
        let url = APIConfig.baseURL.appending(path: "/users")
        let body = UpdateProfileRequest(correo: correo, nombre: nombre, apellidos: apellidos, contrasena: contrasena)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let result: (data: Data, newToken: String, decoded: UpdateProfileResponse?) = try await performAuthenticatedRequest(
            request,
            token: token,
            refreshToken: refreshToken,
            decode: true
        )

        return (response: result.decoded!, newToken: result.newToken)
    }

    // MARK: - Categorias
   
    func fetchCategories(token: String) async throws -> [CategoryResponse] {
        let url = APIConfig.baseURL.appending(path: "/categories")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        guard (200...299).contains(http.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8)
            throw APIError.http(http.statusCode, serverMessage)
        }

        return try JSONDecoder().decode([CategoryResponse].self, from: data)
    }

    // MARK: - Reportes
    func createReport(titulo: String, descripcion: String, urlPagina: String?, idCategoria: Int, token: String) async throws {
        let url = APIConfig.baseURL.appending(path: "/reports")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = CreateReportRequest(titulo: titulo, descripcion: descripcion, urlPagina: urlPagina ?? "", idCategoria: idCategoria)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        guard (200...299).contains(http.statusCode) else {
            let serverMessage = String(data: data, encoding: .utf8)
            throw APIError.http(http.statusCode, serverMessage)
        }
    }

    func uploadReportImage(reportId: Int, imageData: Data, token: String, refreshToken: String) async throws -> (imageUrl: String, newToken: String) {
        let url = APIConfig.baseURL.appending(path: "/reports/\(reportId)/images")

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        let mimeType: String
        let ext: String
        if let _ = imageData.range(of: Data([0xFF, 0xD8, 0xFF]), options: [], in: 0..<min(3, imageData.count)) {
            mimeType = "image/jpeg"
            ext = "jpg"
        } else if imageData.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            mimeType = "image/png"
            ext = "png"
        } else {
            mimeType = "image/jpeg"
            ext = "jpg"
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"report.\(ext)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        struct UploadImageResponse: Decodable {
            let message: String
            let imageUrl: String
        }

        let result: (data: Data, newToken: String, decoded: UploadImageResponse?) = try await performAuthenticatedRequest(
            request,
            token: token,
            refreshToken: refreshToken,
            decode: true
        )

        return (imageUrl: result.decoded!.imageUrl, newToken: result.newToken)
    }

    func fetchMyReports(token: String, refreshToken: String) async throws -> (reports: [MyReportResponse], newToken: String) {
        let url = APIConfig.baseURL.appending(path: "/reports/my-reports")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let result: (data: Data, newToken: String, decoded: [MyReportResponse]?) = try await performAuthenticatedRequest(
            request,
            token: token,
            refreshToken: refreshToken,
            decode: false
        )

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let reports = try decoder.decode([MyReportResponse].self, from: result.data)

        return (reports: reports, newToken: result.newToken)
    }
    // MARK: - Dashboard del home
    func fetchReportsByCategory(token: String) async throws -> [CategoryStat] {
            let url = URL(string: "http://localhost:4000/analytics/reports-by-category")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200...299).contains(http.statusCode) else {
                let message = String(data: data, encoding: .utf8)
                throw APIError.http(http.statusCode, message)
            }

            struct APIResponse: Codable {
                let categoryName: String
                let reportCount: Int
            }

            let decoded = try JSONDecoder().decode([APIResponse].self, from: data)

            return decoded.enumerated().map { index, item in
                CategoryStat(id: index + 1, name: item.categoryName, count: item.reportCount)
            }
        }

        func fetchTopSites(token: String) async throws -> [SiteStat] {
            let url = URL(string: "http://localhost:4000/analytics/top-sites")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200...299).contains(http.statusCode) else {
                let message = String(data: data, encoding: .utf8)
                throw APIError.http(http.statusCode, message)
            }

            struct APIResponse: Codable {
                let urlPagina: String
                let reportCount: Int
            }

            let decoded = try JSONDecoder().decode([APIResponse].self, from: data)
            return decoded.map { SiteStat(site: $0.urlPagina, count: $0.reportCount) }
        }
    
    func fetchReportsByMonth(token: String) async throws -> [TimeSeriesPoint] {
        let url = URL(string: "http://localhost:4000/analytics/reports-by-month")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8)
            throw APIError.http(http.statusCode, message)
        }
        
        struct APIResponse: Codable {
            let month: String      // "2025-09"
            let reportCount: Int
        }
        
        let decoded = try JSONDecoder().decode([APIResponse].self, from: data)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        
        return decoded.compactMap { item in
            guard let date = formatter.date(from: item.month) else { return nil }
            return TimeSeriesPoint(date: date, count: item.reportCount)
        }
    }
    // MARK: - Tip del dia
    func fetchDailyTip() async throws -> (titulo: String, contenido: String) {
            let url = APIConfig.baseURL.appendingPathComponent("/tips/daily")
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            print("📥 fetchDailyTip -> status:", http.statusCode)
            if let body = String(data: data, encoding: .utf8) {
                print("📦 Response body:", body)
            }

            guard (200...299).contains(http.statusCode) else {
                throw APIError.http(http.statusCode, String(data: data, encoding: .utf8))
            }


            struct TipResponse: Codable {
                let titulo: String
                let contenido: String
            }

            let tip = try JSONDecoder().decode(TipResponse.self, from: data)
            return (titulo: tip.titulo, contenido: tip.contenido)
        }

}

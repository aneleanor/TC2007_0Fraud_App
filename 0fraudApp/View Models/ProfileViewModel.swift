//
//  ProfileViewModel.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published var firstName: String = ""
    @Published var lastName: String  = ""
    @Published var email: String     = ""
    @Published var password: String  = ""
    @Published var confirmPassword: String = ""
    
    @Published var approvedCount: Int = 0
    @Published var pendingCount: Int  = 0
    @Published var rejectedCount: Int = 0
    
    @AppStorage("authToken") private var token: String = ""
    @AppStorage("refreshToken") private var refreshToken: String = ""
    
    init() {
        Task {
            do {
                try await fetchUserProfile(accessToken: token)
                await refreshCounts()
            } catch {
                print("❌ Error al cargar perfil o reportes:", error.localizedDescription)
            }
        }
    }
    
    // MARK: - Espacios
    @Published var isLoading = false
    @Published var errors: [String] = []
    @Published var successMessage: String? = nil
    @Published var showDeleteConfirm = false

    private let editProfileController = EditProfileController(httpClient: HTTPClient())
    var accessToken: String = ""

    var isFormValid: Bool {
        !firstName.isEmptyOrWhitespace &&
        !lastName.isEmptyOrWhitespace &&
        email.isValidEmail &&
        (password.isEmpty || (password.isValidPassword && password == confirmPassword))
    }

    // MARK: - Guardar cambios
    func saveChanges() async {
        errors.removeAll()
        successMessage = nil

        // Validación local
        if firstName.isEmptyOrWhitespace { errors.append("El nombre es requerido.") }
        if lastName.isEmptyOrWhitespace  { errors.append("El apellido es requerido.") }
        if email.isEmptyOrWhitespace     { errors.append("El correo es requerido.") }
        if !email.isValidEmail           { errors.append("Formato de correo inválido.") }
        if !password.isEmpty {
            if !password.isValidPassword {
                errors.append("La contraseña debe tener al menos 8 caracteres.")
            }
            if password != confirmPassword {
                errors.append("Las contraseñas no coinciden.")
            }
        }
        guard errors.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await editProfileController.updateProfile(
                correo: email,
                nombre: firstName,
                apellidos: lastName,
                contrasena: password.isEmpty ? nil : password,
                token: token,
                refreshToken: refreshToken
            )

            token = result.newToken

            self.firstName = result.response.nombre
            self.lastName = result.response.apellidos
            self.email = result.response.correo

            successMessage = "Perfil actualizado correctamente."
            password = ""
            confirmPassword = ""

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.successMessage = nil
            }
        } catch let error as APIError {
            if case .sessionExpired = error {
                token = ""
                refreshToken = ""
                errors = [error.localizedDescription]
            } else {
                errors = [error.localizedDescription]
            }
        } catch {
            errors = ["No se pudo actualizar el perfil. Intenta de nuevo."]
        }
    }
    
    // MARK: - Perfil
    struct ProfileResponse: Decodable {
        let profile: Profile
    }

    struct Profile: Decodable {
        let id: String
        let correo: String
        let nombre: String
        let apellidos: String?
        let idRol: Int
    }

    func fetchUserProfile(accessToken: String) async throws {
        guard let url = URL(string: "http://localhost:4000/auth/profile") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try JSONDecoder().decode(ProfileResponse.self, from: data)
        self.firstName = decodedResponse.profile.nombre
        self.lastName  = decodedResponse.profile.apellidos ?? ""
        self.email     = decodedResponse.profile.correo

        print("Perfil cargado:", self.firstName, self.lastName, self.email)
    }
    
    func refreshCounts() async {
        do {
            let summaries = try await fetchReportSummaries()
            
            let approved = summaries.filter { $0.status == .aprobado }.count
            let pending  = summaries.filter { $0.status == .enRevision }.count
            let rejected = summaries.filter { $0.status == .rechazado }.count
            
            await MainActor.run {
                self.approvedCount = approved
                self.pendingCount  = pending
                self.rejectedCount = rejected
            }
        } catch {
            print("Error al actualizar contadores:", error.localizedDescription)
        }
    }
    
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
                let title = dict["titulo"] as? String,
                let description = dict["descripcion"] as? String,
                let estadoStr = dict["estado"] as? String
            else { return nil }
            
            let status: ReportStatus
            switch estadoStr.lowercased() {
            case "aprobado":   status = .aprobado
            case "pendiente":  status = .enRevision
            case "rechazado":  status = .rechazado
            default:           status = .desconocido
            }
            
            let createdAt: Date?
            if let dateStr = dict["fechaCreacion"] as? String {
                let formatter = ISO8601DateFormatter()
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

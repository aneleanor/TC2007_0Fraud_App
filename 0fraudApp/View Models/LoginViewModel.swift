//
//  LoginViewModel.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errors: [String] = []
    @Published var success = false

    @AppStorage("authToken") var token: String = ""  

    var isFormValid: Bool { email.isValidEmail && password.count >= 8 }

    func submit(loginAction: (String, String) async throws -> String) async {
        errors.removeAll()
        if email.isEmptyOrWhitespace { errors.append("El correo es requerido.") }
        if password.isEmptyOrWhitespace { errors.append("La contraseña es requerida.") }
        if !email.isValidEmail { errors.append("Formato de correo inválido.") }
        if password.count < 8 { errors.append("La contraseña debe tener al menos 8 caracteres.") }
        guard errors.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let jwt = try await loginAction(email, password)
            token = jwt
            success = true
        } catch {
            if let apiErr = error as? APIError { errors = [apiErr.localizedDescription] }
            else { errors = [error.localizedDescription] }
        }
    }
}

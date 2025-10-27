//
//  RegisterViewModel.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import SwiftUI

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName  = ""
    @Published var email     = ""
    @Published var password  = ""
    @Published var confirmPassword = ""

    @Published var isLoading = false
    @Published var errors: [String] = []
    @Published var success = false
    @Published var successMessage: String? = nil

    private let httpClient = HTTPClient()

    var isFormValid: Bool {
        !firstName.isEmptyOrWhitespace &&
        !lastName.isEmptyOrWhitespace  &&
        email.isValidEmail             &&
        password.isValidPassword       &&
        password == confirmPassword
    }

    func submit() async {
        errors.removeAll()

        if firstName.isEmptyOrWhitespace { errors.append("El nombre es requerido.") }
        if lastName.isEmptyOrWhitespace  { errors.append("El apellido es requerido.") }
        if email.isEmptyOrWhitespace     { errors.append("El correo es requerido.") }
        if password.isEmptyOrWhitespace  { errors.append("La contraseña es requerida.") }
        if !email.isValidEmail           { errors.append("Formato de correo inválido.") }
        if !password.isValidPassword     { errors.append("La contraseña debe tener al menos 8 caracteres.") }
        if password != confirmPassword   { errors.append("Las contraseñas no coinciden.") }

        guard errors.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        print("Intentando registrar usuario: \(email)")

        do {
            try await httpClient.register(
                correo: email,
                nombre: firstName,
                apellidos: lastName,
                contrasena: password
            )
            print("Registro exitoso para: \(email)")
            success = true
            successMessage = "¡Cuenta creada exitosamente! Redirigiendo al login..."
        } catch let error as APIError {
            print("Error de API: \(error.localizedDescription)")
            errors = [error.localizedDescription]
        } catch {
            print("Error general: \(error.localizedDescription)")
            errors = ["Error al registrar: \(error.localizedDescription)"]
        }
    }
}

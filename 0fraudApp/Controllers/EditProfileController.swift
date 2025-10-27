//
//  EditProfileController.swift
//  0fraudApp
//
//  Created by Emma Sofia on 17/10/25.
//

import Foundation

struct EditProfileController {
    let httpClient: HTTPClient

    func updateProfile(
        correo: String?,
        nombre: String?,
        apellidos: String?,
        contrasena: String?,
        token: String,
        refreshToken: String
    ) async throws -> (response: UpdateProfileResponse, newToken: String) {
        return try await httpClient.updateProfile(
            correo: correo,
            nombre: nombre,
            apellidos: apellidos,
            contrasena: contrasena,
            token: token,
            refreshToken: refreshToken
        )
    }
}

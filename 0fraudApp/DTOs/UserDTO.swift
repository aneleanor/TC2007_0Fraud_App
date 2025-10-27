//
//  UserDTO.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 15/10/25.
//

import Foundation

// MARK: - User DTOs
struct RegisterRequest: Encodable {
    let correo: String
    let nombre: String
    let apellidos: String
    let contrasena: String
}

struct UpdateProfileRequest: Encodable {
    let correo: String?
    let nombre: String?
    let apellidos: String?
    let contrasena: String?
}

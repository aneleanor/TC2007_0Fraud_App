//
//  AuthDTO.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import Foundation

// MARK: - Auth DTOs
struct LoginRequest: Encodable {
    let correo: String
    let contrasena: String
}

struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct UserProfile: Decodable {
    let id: String
    let correo: String
    let nombre: String
    let apellidos: String?
    let idRol: Int
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct RefreshTokenResponse: Decodable {
    let accessToken: String
}

struct UpdateProfileResponse: Decodable {
    let correo: String
    let nombre: String
    let apellidos: String
}

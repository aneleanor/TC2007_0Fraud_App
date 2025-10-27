//
//  AuthenticationController.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import Foundation

struct AuthenticationController {
    let httpClient: HTTPClient

    func login(correo: String, contrasena: String) async throws -> String {
        let resp = try await httpClient.login(correo: correo, contrasena: contrasena)
        
        KeychainManager.save(resp.accessToken, forKey: "accessToken")
        KeychainManager.save(resp.refreshToken, forKey: "refreshToken")
        
        return resp.accessToken
    }
}

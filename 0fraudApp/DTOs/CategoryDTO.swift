//
//  CategoryDTO.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 15/10/25.
//

import Foundation

// MARK: - Category DTOs
struct CategoryResponse: Decodable {
    let id: Int
    let nombre: String
    let descripcion: String?
    let activa: Int?
}

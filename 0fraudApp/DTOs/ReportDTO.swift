//
//  ReportDTO.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 15/10/25.
//

import Foundation

// MARK: - Report DTOs
struct CreateReportRequest: Encodable {
    let titulo: String
    let descripcion: String
    let urlPagina: String
    let idCategoria: Int
}

struct MyReportResponse: Decodable {
    let id: Int
    let titulo: String
    let descripcion: String
    let urlPagina: String?
    let estado: String
    let fechaCreacion: String?
    let idCategoria: Int?
    let imagenes: [String]?
}

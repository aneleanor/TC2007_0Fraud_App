//
//  ReporteBackend.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//
import Foundation

struct ReporteBackend: Codable, Identifiable {
    let id: Int
    let titulo: String
    let descripcion: String
    let url: String
    let fechaCreacion: String
    let autorNombre: String?
    let categoria: String?
    let imagenes: [String]
    let idUsuario: Int?
    let idCategoria: Int?

    var autorCompleto: String {
        autorNombre ?? "Anónimo"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case titulo
        case descripcion
        case url = "url"
        case fechaCreacion
        case autorNombre
        case categoria = "categoriaNombre"
        case imagenes
        case idUsuario
        case idCategoria
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        titulo = try container.decode(String.self, forKey: .titulo)
        descripcion = try container.decode(String.self, forKey: .descripcion)
        url = try container.decode(String.self, forKey: .url)
        fechaCreacion = try container.decode(String.self, forKey: .fechaCreacion)
        autorNombre = try? container.decode(String.self, forKey: .autorNombre)
        categoria = try? container.decode(String.self, forKey: .categoria)
        imagenes = try container.decodeIfPresent([String].self, forKey: .imagenes) ?? []
        idUsuario = try? container.decode(Int.self, forKey: .idUsuario)
        idCategoria = try? container.decode(Int.self, forKey: .idCategoria)
    }
}

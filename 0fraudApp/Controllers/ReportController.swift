//
//  ReportController.swift
//  0fraudApp
//
//  Created by Eleanor  on 13/10/25.
//

import SwiftUI
import PhotosUI

@MainActor
final class ReportController: ObservableObject {
    @AppStorage("authToken") private var authToken = ""
    @AppStorage("refreshToken") private var refreshToken = ""
    
    @Published var title: String = ""
    @Published var websiteURL: String = ""
    @Published var description: String = ""
    @Published var selectedCategory: Category? = nil
    @Published var amount: String = ""

    
    @Published var categories: [Category] = []

    
    @Published var photoItem: PhotosPickerItem? = nil
    @Published var screenshotImage: Image? = nil
    private var screenshotData: Data? = nil

    @Published var isLoading = false
    @Published var errors: [String] = []
    @Published var successMessage: String? = nil

    private let httpClient = HTTPClient()

    var isFormValid: Bool {
        !title.isEmptyOrWhitespace &&
        !description.isEmptyOrWhitespace &&
        selectedCategory != nil &&
        (websiteURL.isEmpty || websiteURL.isValidURL)
    }

    // MARK: - cargar categorias
    
    func loadCategories() async {
        errors.removeAll()
        isLoading = true
        defer { isLoading = false }

        do {
            let categoryResponses = try await httpClient.fetchCategories(token: authToken)
            self.categories = categoryResponses.map {
                Category(id: $0.id, name: $0.nombre)
            }
            print("Categorías cargadas:", self.categories.map(\.name))
        } catch let error as APIError {
            self.errors = [error.localizedDescription]
            print("APIError:", error.localizedDescription)
        } catch {
            self.errors = ["No se pudieron cargar las categorías."]
            print("Error genérico:", error.localizedDescription)
        }
    }


    // MARK: - foto reporte
    func handlePickedPhoto() async {
        guard let item = photoItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.screenshotData = data
                if let uiimg = UIImage(data: data) {
                    self.screenshotImage = Image(uiImage: uiimg)
                }
            }
        } catch {
            self.errors = ["No se pudo cargar la imagen seleccionada."]
        }
    }

    // MARK: - enviar reporte
    func submit() async {
        errors.removeAll()
        successMessage = nil

        // validaciones antes de enviar
        if title.isEmptyOrWhitespace { errors.append("El título es requerido.") }
        if description.isEmptyOrWhitespace { errors.append("La descripción es requerida.") }
        if selectedCategory == nil { errors.append("Selecciona una categoría.") }
        if !websiteURL.isEmpty && !websiteURL.isValidURL {
            errors.append("La URL no es válida (usa http/https).")
        }
        guard errors.isEmpty else { return }

        isLoading = true
        defer { isLoading = false }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = websiteURL.isEmpty ? nil : websiteURL.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            try await httpClient.createReport(
                titulo: trimmedTitle,
                descripcion: trimmedDescription,
                urlPagina: trimmedURL,
                idCategoria: selectedCategory!.id,
                token: authToken
            )

            if let imageData = screenshotData {
                let (myReports, newToken) = try await httpClient.fetchMyReports(token: authToken, refreshToken: refreshToken)
                authToken = newToken

                guard let newReport = myReports.first(where: {
                    $0.titulo == trimmedTitle && $0.descripcion == trimmedDescription
                }) else {
                    throw APIError.invalidResponse
                }

                let (_, finalToken) = try await httpClient.uploadReportImage(
                    reportId: newReport.id,
                    imageData: imageData,
                    token: authToken,
                    refreshToken: refreshToken
                )
                authToken = finalToken
            }

            self.successMessage = "Reporte creado exitosamente."

            self.title = ""
            self.websiteURL = ""
            self.description = ""
            self.selectedCategory = nil
            self.photoItem = nil
            self.screenshotImage = nil
            self.screenshotData = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.successMessage = nil
            }
        } catch let error as APIError {
            self.errors = [error.localizedDescription]
        } catch {
            self.errors = ["No se pudo crear el reporte. Intenta de nuevo."]
        }
    }
}

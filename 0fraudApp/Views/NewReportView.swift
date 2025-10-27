//
//  NewReportView.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import SwiftUI
import PhotosUI

struct NewReportView: View {
    @StateObject private var controller = ReportController()
    @FocusState private var focused: Field?
    @State private var navigateToMyReports = false
    @State private var hasInteracted = false
    enum Field { case title, url, description }

    @State private var showLogin = false
    @AppStorage("authToken") private var authToken = ""
    @AppStorage("refreshToken") private var refreshToken = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                VStack(alignment: .leading, spacing: 14) {
                    Text("Título").font(.subheadline).bold()
                    TextField("Título", text: $controller.title)
                        .textInputAutocapitalization(.sentences)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .focused($focused, equals: .title)
                        .submitLabel(.next)
                        .onSubmit { focused = .url }

                    Text("URL de la oferta fraudulenta").font(.subheadline).bold()
                    TextField("Website URL", text: $controller.websiteURL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .focused($focused, equals: .url)
                        .submitLabel(.next)
                        .onSubmit { focused = .description }

                    Text("Descripción").font(.subheadline).bold()
                    TextEditor(text: $controller.description)
                        .frame(minHeight: 140)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .focused($focused, equals: .description)

                    Text("Categoría").font(.subheadline).bold()
                    Picker("Selecciona una categoría", selection: Binding(
                        get: { controller.selectedCategory ?? Category(id: -1, name: "Selecciona…") },
                        set: { newValue in
                            controller.selectedCategory = (newValue.id == -1) ? nil : newValue
                        }
                    )) {
                        Text("Selecciona…").tag(Category(id: -1, name: "Selecciona…"))
                        ForEach(controller.categories) { cat in
                            Text(cat.name).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)

                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text("Captura de pantalla").font(.subheadline).bold()
                    HStack(spacing: 12) {
                        PhotosPicker(selection: $controller.photoItem, matching: .images) {
                            Label("Seleccionar imagen", systemImage: "photo.on.rectangle")
                        }
                        .onChange(of: controller.photoItem) {
                            Task { await controller.handlePickedPhoto() }
                        }
                        if let img = controller.screenshotImage {
                            img
                              .resizable()
                              .scaledToFill()
                              .frame(width: 60, height: 60)
                              .clipShape(RoundedRectangle(cornerRadius: 8))
                              .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.systemGray4))
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)

                if !controller.errors.isEmpty {
                    ComponentErrorSummary(errors: controller.errors)
                        .padding(.horizontal, 16)
                }

                if let msg = controller.successMessage {
                    ComponentSuccessSummary(messages: [msg])
                        .padding(.top, 4)
                }

                if hasInteracted {
                    VStack(alignment: .leading, spacing: 8) {
                        if controller.title.isEmpty {
                            Label("El título es obligatorio", systemImage: "xmark.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Label("Título completado", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }

                        if controller.websiteURL.isEmpty {
                            Label("La URL es obligatoria", systemImage: "xmark.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if !controller.websiteURL.isValidURL {
                            Label("La URL no es válida, necesita incluir http: o https:", systemImage: "xmark.circle")
                                .font(.caption)
                                .foregroundColor(.red)
                        } else {
                            Label("URL completada", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }

                        if controller.description.isEmpty {
                            Label("La descripción es obligatoria", systemImage: "xmark.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Label("Descripción completada", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }

                        if controller.selectedCategory == nil {
                            Label("Selecciona una categoría", systemImage: "xmark.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Label("Categoría seleccionada", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }

                Button {
                    Task { await controller.submit() }
                } label: {
                    Group {
                        if controller.isLoading { ProgressView().tint(.white) }
                        else { Text("Enviar reporte").bold() }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(controller.isFormValid ? Color.orange : Color.orange.opacity(0.3))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!controller.isFormValid || controller.isLoading)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Reportar")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await controller.loadCategories()
        }
        .onChange(of: controller.title) { _, _ in hasInteracted = true }
        .onChange(of: controller.websiteURL) { _, _ in hasInteracted = true }
        .onChange(of: controller.description) { _, _ in hasInteracted = true }
        .onChange(of: controller.selectedCategory) { _, _ in hasInteracted = true }
        .onChange(of: controller.successMessage) { _, newValue in
            if newValue != nil {
                Task {
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    navigateToMyReports = true
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToMyReports) {
            MainTabView()
                .environment(\.initialTab, 3)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cerrar sesión") {
                    logout()
                }
                .font(.callout.weight(.semibold))
                .foregroundColor(.red)
            }
        }
        .fullScreenCover(isPresented: $showLogin) {
            NavigationStack {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    // MARK: - logout
    private func logout() {
        authToken = ""
        refreshToken = ""
        showLogin = true
    }
}

#Preview {
    NavigationStack { NewReportView() }
}

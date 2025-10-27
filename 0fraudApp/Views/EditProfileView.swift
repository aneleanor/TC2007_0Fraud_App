//
//  EditProfileView.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//


import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ProfileViewModel
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @FocusState private var focused: Field?
    enum Field { case firstName, lastName, email, password, confirmPassword }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let successMsg = vm.successMessage {
                        ComponentSuccessSummary(messages: [successMsg])
                            .padding(.horizontal)
                    }

                    ComponentErrorSummary(errors: vm.errors)
                        .padding(.horizontal)
                        .padding(.bottom, vm.errors.isEmpty ? 0 : 8)

                    VStack(spacing: 12) {
                        TextField("Nombre", text: $vm.firstName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(false)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($focused, equals: .firstName)
                            .submitLabel(.next)
                            .onSubmit { focused = .lastName }

                        TextField("Apellido", text: $vm.lastName)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(false)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($focused, equals: .lastName)
                            .submitLabel(.next)
                            .onSubmit { focused = .email }

                        TextField("Correo Electrónico", text: $vm.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textContentType(.emailAddress)
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .focused($focused, equals: .email)
                            .submitLabel(.next)
                            .onSubmit { focused = .password }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Contraseña (opcional)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)

                            HStack(spacing: 10) {
                                Group {
                                    if showPassword {
                                        TextField("Nueva contraseña", text: $vm.password)
                                    } else {
                                        SecureField("Nueva contraseña", text: $vm.password)
                                    }
                                }
                                .textContentType(.newPassword)
                                .focused($focused, equals: .password)
                                .submitLabel(.next)
                                .onSubmit { focused = .confirmPassword }

                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityLabel(showPassword ? "Ocultar contraseña" : "Mostrar contraseña")
                            }
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if !vm.password.isEmpty {
                            HStack(spacing: 10) {
                                Group {
                                    if showConfirmPassword {
                                        TextField("Confirmar contraseña", text: $vm.confirmPassword)
                                    } else {
                                        SecureField("Confirmar contraseña", text: $vm.confirmPassword)
                                    }
                                }
                                .textContentType(.newPassword)
                                .focused($focused, equals: .confirmPassword)
                                .submitLabel(.done)
                                .onSubmit { Task { await vm.saveChanges() } }

                                Button {
                                    showConfirmPassword.toggle()
                                } label: {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundStyle(.secondary)
                                }
                                .accessibilityLabel(showConfirmPassword ? "Ocultar contraseña" : "Mostrar contraseña")
                            }
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 24)

                    Button {
                        Task {
                            await vm.saveChanges()
                            if vm.successMessage != nil {
                                try? await Task.sleep(nanoseconds: 1_500_000_000)
                                dismiss()
                            }
                        }
                    } label: {
                        Group {
                            if vm.isLoading { ProgressView().tint(.white) }
                            else { Text("Guardar cambios").bold() }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(vm.isFormValid ? Color.orange : Color.orange.opacity(0.3))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .disabled(!vm.isFormValid || vm.isLoading)
                }
                .padding(.top, 20)
                .padding(.bottom, 24)
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview { EditProfileView(vm: ProfileViewModel()) }

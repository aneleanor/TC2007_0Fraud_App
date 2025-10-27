//
//  RegisterView.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = RegisterViewModel()
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showTerms = false
    @FocusState private var focused: Field?
    enum Field { case firstName, lastName, email, password, confirmPassword }

    var onFinish: () -> Void = {}

    var body: some View {
        VStack {
            Spacer(minLength: 36)

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .padding(.bottom, 24)
                .accessibilityLabel("0-Fraud")

            VStack(spacing: 6) {
                Text("Registro de Usuario")
                    .font(.title3).bold()
                Text("Ingresa tu correo para registrarte en la app")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 16)

            if let successMsg = vm.successMessage {
                ComponentSuccessSummary(messages: [successMsg])
                    .padding(.horizontal)
                    .padding(.bottom, 8)
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
                    .textContentType(.username)
                    .padding(14)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .focused($focused, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focused = .password }

                HStack(spacing: 10) {
                    Group {
                        if showPassword {
                            TextField("Contraseña", text: $vm.password)
                        } else {
                            SecureField("Contraseña", text: $vm.password)
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

                HStack(spacing: 10) {
                    Group {
                        if showConfirmPassword {
                            TextField("Confirmar Contraseña", text: $vm.confirmPassword)
                        } else {
                            SecureField("Confirmar Contraseña", text: $vm.confirmPassword)
                        }
                    }
                    .textContentType(.newPassword)
                    .focused($focused, equals: .confirmPassword)
                    .submitLabel(.go)
                    .onSubmit { Task { await vm.submit() } }

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
            .padding(.horizontal, 24)
            .padding(.top, 4)

            VStack(alignment: .leading, spacing: 8) {
                if !vm.password.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: vm.password.hasMinimumLength ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(vm.password.hasMinimumLength ? .green : .gray)
                            .font(.caption)
                        Text(vm.password.hasMinimumLength ? "Longitud mínima cumplida (10 caracteres)" : "Debe tener al menos 10 caracteres")
                            .font(.caption)
                            .foregroundColor(vm.password.hasMinimumLength ? .green : .secondary)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: vm.password.hasLowercase ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(vm.password.hasLowercase ? .green : .gray)
                            .font(.caption)
                        Text(vm.password.hasLowercase ? "Tiene al menos una minúscula" : "Debe tener al menos una minúscula")
                            .font(.caption)
                            .foregroundColor(vm.password.hasLowercase ? .green : .secondary)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: vm.password.hasUppercase ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(vm.password.hasUppercase ? .green : .gray)
                            .font(.caption)
                        Text(vm.password.hasUppercase ? "Tiene al menos una mayúscula" : "Debe tener al menos una mayúscula")
                            .font(.caption)
                            .foregroundColor(vm.password.hasUppercase ? .green : .secondary)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: vm.password.hasNumber ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(vm.password.hasNumber ? .green : .gray)
                            .font(.caption)
                        Text(vm.password.hasNumber ? "Tiene al menos un número" : "Debe tener al menos un número")
                            .font(.caption)
                            .foregroundColor(vm.password.hasNumber ? .green : .secondary)
                    }

                    HStack(spacing: 6) {
                        Image(systemName: vm.password.hasSpecialCharacter ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(vm.password.hasSpecialCharacter ? .green : .gray)
                            .font(.caption)
                        Text(vm.password.hasSpecialCharacter ? "Tiene al menos un carácter especial" : "Debe tener al menos un carácter especial (!@#$%^&*...)")
                            .font(.caption)
                            .foregroundColor(vm.password.hasSpecialCharacter ? .green : .secondary)
                    }
                }

                if !vm.confirmPassword.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: vm.password == vm.confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(vm.password == vm.confirmPassword ? .green : .red)
                            .font(.caption)
                        Text(vm.password == vm.confirmPassword ? "Las contraseñas coinciden" : "Las contraseñas no coinciden")
                            .font(.caption)
                            .foregroundColor(vm.password == vm.confirmPassword ? .green : .secondary)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Button {
                Task {
                    await vm.submit()
                    if vm.success {
                        onFinish()
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                        dismiss()
                    }
                }
            } label: {
                Group {
                    if vm.isLoading { ProgressView().tint(.white) }
                    else { Text("Continuar").bold() }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(vm.isFormValid ? Color.orange : Color.orange.opacity(0.3))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .disabled(!vm.isFormValid || vm.isLoading)

            VStack(spacing: 4) {
                Text("Si presionas continuar, estarás aceptando nuestros")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Términos y Condiciones") {
                    showTerms = true
                }
                .font(.footnote.weight(.semibold))
            }
            .padding(.top, 10)

            Spacer(minLength: 24)
        }
        .sheet(isPresented: $showTerms) {
            NavigationStack { TermsView() }
        }
        .onAppear { focused = .firstName }
    }
}

#Preview { RegisterView() }


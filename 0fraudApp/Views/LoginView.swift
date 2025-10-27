//
//  LoginView.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.authenticationController) private var auth
    @StateObject private var vm = LoginViewModel()
    @State private var showPassword = false
    @FocusState private var focused: Field?
    enum Field { case email, password }
    
    @State private var goToDevMenu = false

    var onRegisterTap: () -> Void = {}

    var body: some View {
        VStack {
            Spacer(minLength: 40)

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250)
                .padding(.bottom, 45)
                .accessibilityLabel("0-Fraud")

            VStack(spacing: 6) {
                Text("Inicio de Sesión").font(.title3).bold()
                Text("¡Bienvenido de nuevo!").font(.subheadline).foregroundStyle(.secondary)
            }
            .padding(.bottom, 16)

            ComponentErrorSummary(errors: vm.errors)
                .padding(.horizontal)
                .padding(.bottom, vm.errors.isEmpty ? 0 : 8)

            VStack(spacing: 12) {
                TextField("Correo Electrónico", text: $vm.email)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
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
                    .textContentType(.password)
                    .focused($focused, equals: .password)
                    .submitLabel(.go)
                    .onSubmit {
                        Task {
                            await vm.submit(loginAction: { email, pass in
                                try await auth.login(correo: email, contrasena: pass)
                            })
                        }
                    }

                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(14)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.top, 4)

            Button {
                Task {
                    await vm.submit(loginAction: { email, pass in
                        try await auth.login(correo: email, contrasena: pass)
                    })
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
                Text("¿No tienes cuenta?").font(.footnote).foregroundStyle(.secondary)
                NavigationLink {
                    RegisterView()
                } label: {
                    Text("Regístrate").font(.footnote.bold())
                }
            }
            .padding(.top, 14)

            Spacer()
        }
        .onAppear { focused = .email }
        
        .onChange(of: vm.success) { _, isSuccess in
            if isSuccess { goToDevMenu = true }
        }

        .navigationDestination(isPresented: $goToDevMenu) {
            MainTabView()
        }
    }
}

#Preview {
    return NavigationStack { LoginView() }
}

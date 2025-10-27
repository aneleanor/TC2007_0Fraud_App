//
//  ProfileView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.

import SwiftUI

struct ProfileView: View {

    @StateObject private var vm = ProfileViewModel()
    @State private var showEditProfile = false

    
    @State private var showLogin = false
    @AppStorage("authToken") private var authToken = ""
    @AppStorage("refreshToken") private var refreshToken = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    HStack(alignment: .center, spacing: 16) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(16)
                                    .foregroundColor(.gray)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text("\(vm.firstName) \(vm.lastName)")
                                    .font(.title3)
                                    .fontWeight(.semibold)

                                Button {
                                    showEditProfile = true
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                                .accessibilityLabel("Editar perfil")
                            }

                            Text(vm.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Button("Cerrar sesión") {
                            logout()
                        }
                        .font(.callout.weight(.semibold))
                        .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    Divider().padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mis Reportes")
                            .font(.headline)
                            .padding(.horizontal)

                        HStack(spacing: 12) {
                            NavigationLink {
                                MyReportsView(stateFilter: .aprobado)
                            } label: {
                                EstadoCard(title: "Aprobado", color: .green, count: vm.approvedCount)
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                MyReportsView(stateFilter: .enRevision)
                            } label: {
                                EstadoCard(title: "Pendiente", color: .orange, count: vm.pendingCount)
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                MyReportsView(stateFilter: .rechazado)
                            } label: {
                                EstadoCard(title: "Rechazado", color: .red, count: vm.rejectedCount)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Red por la Ciberseguridad")
                            .font(.headline)
                        Text("Organización dedicada a promover la seguridad digital y la lucha contra el fraude en línea. Para más información, visita su sitio oficial.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button {
                            if let url = URL(string: "https://redporlaciberseguridad.org") {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Ir a página oficial")
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
            }
            .task {
                await vm.refreshCounts()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(vm: vm)
            }
            .fullScreenCover(isPresented: $showLogin) {
                NavigationStack {
                    LoginView()
                        .navigationBarBackButtonHidden(true)
                }
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
    ProfileView()
}

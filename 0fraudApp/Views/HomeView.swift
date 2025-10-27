//
//  HomeView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var newsClient = NewsAPIClient()

    @State private var showLogin = false
    @AppStorage("authToken") private var authToken = ""
    @AppStorage("refreshToken") private var refreshToken = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        HStack {
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 130)
                                .padding(.leading)

                            Spacer()

                            Button("Cerrar sesión") {
                                logout()
                            }
                            .font(.callout.weight(.semibold))
                            .foregroundColor(.red)
                            .padding(.trailing)
                        }
                        .padding(.top)

                        searchBar

                    Group {
                        if let tip = viewModel.dailyTip {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tip del día: \(tip.titulo)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text(tip.contenido)
                                        .font(.footnote)
                                        .foregroundColor(.black.opacity(0.8))
                                }
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.orange.opacity(0.15))
                            )
                            .padding(.horizontal)
                        } else {
                            ProgressView("Cargando tip del día...")
                                .padding(.horizontal)
                        }
                    }


                    CoursesView(courses: courses)
                    
                    NewsView(newsClient: newsClient)

                        Spacer(minLength: 30)
                    }
                }
                .navigationBarHidden(true)
                .onSubmit {
                    if !viewModel.searchText.isEmpty {
                        viewModel.buscarReportes(navigateToResults: true)
                    }
                }

                if viewModel.searchText.count >= 3 && !viewModel.reportes.isEmpty {
                    VStack(spacing: 0) {
                        Color.clear
                            .frame(height: 140)

                        ZStack(alignment: .top) {
                            Color.black.opacity(0.3)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    viewModel.searchText = ""
                                }

                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.reportes) { reporte in
                                        NavigationLink {
                                            DetalleReporteView(reporte: reporte)
                                        } label: {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(reporte.titulo)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.primary)

                                                if let categoria = reporte.categoria {
                                                    Text(categoria)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }

                                                Text(reporte.url)
                                                    .font(.caption2)
                                                    .foregroundColor(.blue)
                                                    .lineLimit(1)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                        }
                                        .buttonStyle(.plain)

                                        if reporte.id != viewModel.reportes.last?.id {
                                            Divider()
                                                .padding(.leading, 16)
                                        }
                                    }
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                            }
                        }
                    }
                }


                NavigationLink(
                    destination: ResultadosView(reportes: viewModel.reportes),
                    isActive: $viewModel.showResultados
                ) {
                    EmptyView()
                }
            }
            .task {
                await newsClient.fetchNews()
                await viewModel.fetchDailyTip()
            }
            .onChange(of: viewModel.searchText) { _, newValue in
                if newValue.count >= 3 {
                    viewModel.buscarReportes()
                } else {
                    viewModel.reportes = []
                }
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

    // MARK: - Barra de búsqueda
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField("Buscar título, categoría o URL", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }

    // MARK: - Cursos
    private var courses: [Course] = [
        Course(
            id: 1,
            title: "Ciberseguridad en el trabajo",
            description: "Aprende buenas prácticas para proteger la información en tu entorno laboral.",
            imageName: "ciber",
            url: "https://academia.redporlaciberseguridad.org/enrol/index.php?id=5"
        ),
        Course(
            id: 2,
            title: "Protección de datos personales",
            description: "Conoce cómo mantener tu privacidad y cumplir con la ley de datos personales.",
            imageName: "pdd",
            url: "https://academia.redporlaciberseguridad.org/enrol/index.php?id=3"
        ),
        Course(
            id: 3,
            title: "IA para la vida y el trabajo",
            description: "Descubre cómo la inteligencia artificial puede ayudarte de forma segura.",
            imageName: "ia",
            url: "https://academia.redporlaciberseguridad.org/enrol/index.php?id=44"
        )
    ]
}

// MARK: - Modelo de curso
struct Course: Identifiable {
    let id: Int
    let title: String
    let description: String
    let imageName: String
    let url: String
}

#Preview {
    HomeView()
}

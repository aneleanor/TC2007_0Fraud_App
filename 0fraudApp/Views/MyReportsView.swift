//
//  MyReportsView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón  on 13/10/25.
//


import SwiftUI

struct MyReportsView: View {
    @StateObject private var vm = ReportsListViewModel()
    var stateFilter: ReportStatus? = nil
    private let service = ReportsController()

    @State private var showLogin = false
    @AppStorage("authToken") private var authToken = ""
    @AppStorage("refreshToken") private var refreshToken = "" 

    private var filteredReports: [ReportSummary] {
        if let status = stateFilter {
            return vm.reports.filter { $0.status == status }
        } else {
            return vm.reports
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Mis Reportes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                if vm.isLoading {
                    ProgressView("Cargando…").padding()
                }

                if !vm.errors.isEmpty {
                    ComponentErrorSummary(errors: vm.errors)
                        .padding(.horizontal, 16)
                }

                VStack(spacing: 16) {
                    ForEach(filteredReports) { report in
                        let reportCopy = report
                        NavigationLink {
                            ReportDetailView(report: reportCopy)
                        } label: {
                            ReportRowCard(report: reportCopy)
                                .contentShape(Rectangle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                        .tint(.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                if !vm.isLoading && filteredReports.isEmpty && vm.errors.isEmpty {
                    Text("Aún no tienes reportes.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                }

                Spacer(minLength: 24)
            }
        }
        .task {
            await vm.load()
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
    NavigationStack {
        MyReportsView(stateFilter: .aprobado)
    }
}

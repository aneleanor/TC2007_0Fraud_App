//
//  StatsDashboardView.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import SwiftUI
import Charts

struct StatsDashboardView: View {
    @StateObject private var c = StatsController()

    @State private var showLogin = false
    @AppStorage("authToken") private var authToken = ""
    @AppStorage("refreshToken") private var refreshToken = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                if !c.errors.isEmpty {
                    ComponentErrorSummary(errors: c.errors)
                }

                Card("Reportes por Categorías") {
                    if #available(iOS 17.0, *) {
                        Chart(c.categoryStats) { item in
                            SectorMark(
                                angle: .value("Reportes", item.count),
                                innerRadius: .ratio(0.45), // donut
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Categoría", item.name))
                            .annotation(position: .overlay) {
                                // etiqueta pequeña opcional
                                Text(item.count.formatted())
                                    .font(.caption2).bold()
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(height: 240)
                    } else {
                        Chart(c.categoryStats) { item in
                            BarMark(
                                x: .value("Reportes", item.count),
                                y: .value("Categoría", item.name)
                            )
                            .cornerRadius(6)
                        }
                        .frame(height: 240)
                    }
                }

                Card("Reportes por mes") {
                    Chart(c.monthlyStats) { p in
                        BarMark(
                            x: .value("Mes", p.date, unit: .month),
                            y: .value("Reportes", p.count)
                        )
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .month)) { _ in
                            AxisGridLine()
                            AxisValueLabel(format: .dateTime.month(.abbreviated))
                        }
                    }
                    .frame(height: 220)
                }

                Card("Sitios más reportados") {
                    Chart(c.topSites) { s in
                        BarMark(
                            x: .value("Reportes", s.count),
                            y: .value("Sitio", s.site)
                        )
                        .cornerRadius(6)
                        .annotation(position: .trailing, alignment: .trailing) {
                            Text(s.count.formatted())
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: CGFloat(max(160, c.topSites.count * 44)))
                }

                
            }
            .padding(16)
        }
        .navigationTitle("Panel de Estadísticas")
        .navigationBarTitleDisplayMode(.inline)
        .task { await c.loadAll() }
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
    NavigationStack { StatsDashboardView() }
}

// MARK: - Estilo
private struct Card<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.top, 12)
            content
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.systemGray4))
        )
    }
}

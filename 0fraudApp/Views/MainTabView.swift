//
//  MainTabView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @Environment(\.initialTab) private var initialTab

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                StatsDashboardView()
            }
            .tabItem {
                Label("Estadísticas", systemImage: "chart.bar.fill")
            }
            .tag(1)

            NavigationStack {
                NewReportView()
            }
            .tabItem {
                Label("Crear Reporte", systemImage: "plus.circle.fill")
            }
            .tag(2)

            NavigationStack {
                MyReportsView()
            }
            .tabItem {
                Label("Mis Reportes", systemImage: "doc.text.fill")
            }
            .tag(3)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Perfil", systemImage: "person.fill")
            }
            .tag(4)
        }
        .accentColor(.black) 
        .onAppear {
            selectedTab = initialTab
        }
    }
}

#Preview {
    MainTabView()
}


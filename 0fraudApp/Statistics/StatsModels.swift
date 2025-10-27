//
//  StatsModels.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import Foundation

struct CategoryStat: Identifiable, Codable {
    let id: Int
    let name: String
    let count: Int
}

struct TimeSeriesPoint: Identifiable, Codable {
    let date: Date
    let count: Int
    var id: Date { date }
}

struct SiteStat: Identifiable, Codable {
    let site: String
    let count: Int
    var id: String { site }
}

struct StatusStat: Identifiable, Codable {
    let status: String   
    let count: Int
    var id: String { status }
}

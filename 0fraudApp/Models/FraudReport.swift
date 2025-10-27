//
//  FraudReport.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import Foundation

struct FraudReport: Codable {
    let title: String
    let websiteURL: String?
    let description: String
    let categoryId: Int
    let screenshotURL: String? 
}

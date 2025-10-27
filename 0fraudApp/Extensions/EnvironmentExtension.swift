//
//  EnvironmentExtension.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 13/10/25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var authenticationController = AuthenticationController(httpClient: HTTPClient())
    @Entry var initialTab: Int = 0
}

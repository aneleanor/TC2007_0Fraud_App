//
//  ValidationExtension.swift
//  0fraudApp
//
//  Created by Emma Sofia  on 12/10/25.
//

import Foundation

extension String {
    var isEmptyOrWhitespace: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var isValidEmail: Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: emailRegex, options: .regularExpression) != nil
    }

    var isValidPassword: Bool {
        let hasMinimumLength = count >= 10
        let hasLowercase = range(of: ".*[a-z]+.*", options: .regularExpression) != nil
        let hasUppercase = range(of: ".*[A-Z]+.*", options: .regularExpression) != nil
        let hasNumber = range(of: ".*[0-9]+.*", options: .regularExpression) != nil
        let hasSpecialCharacter = range(of: ".*[!@#$%^&*(),.?\":{}|<>]+.*", options: .regularExpression) != nil

        return hasMinimumLength && hasLowercase && hasUppercase && hasNumber && hasSpecialCharacter
    }

    var hasMinimumLength: Bool {
        count >= 10
    }

    var hasLowercase: Bool {
        range(of: ".*[a-z]+.*", options: .regularExpression) != nil
    }

    var hasUppercase: Bool {
        range(of: ".*[A-Z]+.*", options: .regularExpression) != nil
    }

    var hasNumber: Bool {
        range(of: ".*[0-9]+.*", options: .regularExpression) != nil
    }

    var hasSpecialCharacter: Bool {
        range(of: ".*[!@#$%^&*(),.?\":{}|<>]+.*", options: .regularExpression) != nil
    }
    
    var isValidURL: Bool {
        guard let url = URL(string: self) else { return false }
        return ["http", "https"].contains(url.scheme?.lowercased() ?? "")
    }

}


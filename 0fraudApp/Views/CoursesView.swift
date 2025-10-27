//
//  CoursesView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 23/10/25.
//

import SwiftUI

// MARK: - CoursesView
struct CoursesView: View {
    let courses: [Course]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎓 ¿Sabías que Red por la Ciberseguridad ofrece cursos gratuitos?")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)

            VStack(spacing: 16) {
                ForEach(courses) { course in
                    Link(destination: URL(string: course.url)!) {
                        HStack(spacing: 12) {
                            Image(course.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 65, height: 65)
                                .cornerRadius(10)
                                .clipped()

                            VStack(alignment: .leading, spacing: 4) {
                                Text(course.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Text(course.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .layoutPriority(1)

                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                    }
                }

                Link(destination: URL(string: "https://academia.redporlaciberseguridad.org/course/index.php?categoryid=39")!) {
                    Text("Ver todos los cursos")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)
        }
    }
}

//
//  NewsView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 23/10/25.
//

import SwiftUI

// MARK: - NewsView
struct NewsView: View {
    @ObservedObject var newsClient: NewsAPIClient

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Últimas noticias")
                .font(.title3)
                .fontWeight(.semibold)
                .padding()

            if newsClient.isLoading {
                ProgressView("Cargando noticias...")
                    .padding()
            } else if let error = newsClient.errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ForEach(newsClient.articles.prefix(4)) { article in
                    Link(destination: URL(string: article.url)!) {
                        HStack(alignment: .top, spacing: 10) {
                            if let imageUrl = article.urlToImage,
                               let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 55, height: 55)
                                        .cornerRadius(6)
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 55, height: 55)
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(article.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            }

                            Spacer()

                            Image(systemName: "arrow.up.right.square")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                    }
                    if article.id != newsClient.articles.prefix(4).last?.id {
                        Divider()
                            .padding(.leading, 65)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
}

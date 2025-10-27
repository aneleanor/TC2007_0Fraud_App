//
//  ImagenesCarrouselView.swift
//  0fraudApp
//
//  Created by Eleanor Alarcón on 14/10/25.
//

import SwiftUI

struct ImagenesCarouselView: View {
    let imagenes: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Imágenes")
                .font(.subheadline)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(imagenes, id: \.self) { imgUrl in
                        AsyncImage(url: URL(string: imgUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 140)
                                .clipped()
                                .cornerRadius(10)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray5))
                                .frame(width: 200, height: 140)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                }
            }
        }
    }
}

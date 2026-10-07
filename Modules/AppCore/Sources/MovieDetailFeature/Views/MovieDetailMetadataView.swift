//
//  MovieDetailMetadataView.swift
//  NeuGelbTest
//
//  Created by Marco Maddalena on 24.03.26.
//

import DesignSystem
import SwiftUI

struct MovieDetailMetadataView: View {
    let releaseDate: String
    let runtime: String
    
    var body: some View {
        VStack(spacing: 8) {
            MetadataRowView(label: LocalizedStringResource("movieDetail.releaseDate", bundle: #bundle), value: releaseDate)
            MetadataRowView(label: LocalizedStringResource("movieDetail.runtime", bundle: #bundle), value: runtime)
        }
    }
}

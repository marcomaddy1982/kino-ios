//
//  MovieDetailHeaderView.swift
//  Kino
//
//  Created by Marco Maddalena on 24.03.26.
//

import DesignSystem
import SwiftUI

struct MovieDetailHeaderView: View {
    let title: String
    let voteAverage: String
    let tagline: String?
    let hasTagline: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .titleStyle()
                .foregroundColor(AppColors.primary)
                .lineLimit(3)
            
            HStack(spacing: 8) {
                Label(voteAverage, systemImage: "star.fill")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.accent)
                
                Spacer()
            }
        }
        
        if hasTagline, let tagline {
            Text(tagline)
                .bodyStyle()
                .italic()
                .foregroundColor(.secondary)
        }
    }
}

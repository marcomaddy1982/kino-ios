//
//  MovieDetailFinancialView.swift
//  NeuGelbTest
//
//  Created by Marco Maddalena on 24.03.26.
//

import DesignSystem
import SwiftUI

struct MovieDetailFinancialView: View {
    let budget: String
    let revenue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("movieDetail.financial", bundle: .module)
                .headlineStyle()
            
            VStack(spacing: 8) {
                MetadataRowView(label: LocalizedStringResource("movieDetail.budget", bundle: #bundle), value: budget)
                MetadataRowView(label: LocalizedStringResource("movieDetail.revenue", bundle: #bundle), value: revenue)
            }
        }
    }
}

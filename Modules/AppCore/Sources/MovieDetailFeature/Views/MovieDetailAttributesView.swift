//
//  MovieDetailAttributesView.swift
//  NeuGelbTest
//
//  Created by Marco Maddalena on 24.03.26.
//

import DesignSystem
import Models
import SwiftUI

struct MovieDetailAttributesView: View {
    let hasGenres: Bool
    let genres: [Genre]
    let hasProductionCompanies: Bool
    let productionCompanies: [ProductionCompany]
    let hasProductionCountries: Bool
    let productionCountries: [ProductionCountry]
    let hasSpokenLanguages: Bool
    let spokenLanguages: [SpokenLanguage]
    
    var body: some View {
        // Genres
        if hasGenres {
            VStack(alignment: .leading, spacing: 8) {
                Text("movieDetail.genres", bundle: .module)
                    .headlineStyle()
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(genres, id: \.id) { genre in
                        HStack {
                            TagBadge(text: genre.name)
                            Spacer()
                        }
                    }
                }
            }
        }
        
        // Production Companies
        if hasProductionCompanies {
            VStack(alignment: .leading, spacing: 8) {
                Text("movieDetail.productionCompanies", bundle: .module)
                    .headlineStyle()
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(productionCompanies, id: \.id) { company in
                        Text(company.name)
                            .font(AppFonts.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        
        // Production Countries
        if hasProductionCountries {
            VStack(alignment: .leading, spacing: 8) {
                Text("movieDetail.countries", bundle: .module)
                    .headlineStyle()
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(productionCountries, id: \.id) { country in
                        HStack {
                            TagBadge(text: country.name)
                            Spacer()
                        }
                    }
                }
            }
        }
        
        // Spoken Languages
        if hasSpokenLanguages {
            VStack(alignment: .leading, spacing: 8) {
                Text("movieDetail.languages", bundle: .module)
                    .headlineStyle()
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(spokenLanguages, id: \.id) { language in
                        HStack {
                            TagBadge(text: language.englishName ?? language.name)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

//
//  AuthButtonView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 5/21/25.
//

import SwiftUI

struct LoginButtonView: View {
    
    let title: LocalizedStringKey
    let iconName: String
    let isSystemImage: Bool
    let action: () -> Void
    
    
    var body: some View {
        Button {
            action()
        } label : {
            HStack {
                Group {
                    if isSystemImage {
                        Image(systemName: iconName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.headline)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 10))
            
        }
    }
}

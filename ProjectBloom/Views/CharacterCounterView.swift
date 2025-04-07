//
//  CharacterCounterView.swift
//  ProjectBloom
//
//  Created by Carlos Valentin on 2/3/25.
//

import SwiftUI

struct CharacterCounterView: View {
    let currentCount: Int
    let maxLimit: Int
    
    
    var body: some View {
        VStack{
            Text("\(currentCount)/\(maxLimit)")
                .font(.caption)
                .foregroundStyle(currentCount == maxLimit ? .red : .gray)
                .animation(.easeInOut(duration: 0.2), value: currentCount)
                .padding(.top, -8)
            
            if currentCount == maxLimit {
                Text(Constants.characterLimitReachedString)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .transition(.opacity)
                    .padding(.bottom, 5)
            }
        }
    }
}

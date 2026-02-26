//
//  MomentDetailView.swift
//  GratefulMoments
//
//  Created by Siyanie on 26.02.2026.
//
import SwiftUI


struct MomentDetailView: View {
    var moment: Moment


    var body: some View {
        Text("Hello, World!")
    }
}


#Preview {
    MomentDetailView(moment: .imageSample)
        .sampleDataContainer()
}

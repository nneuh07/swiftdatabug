//
//  InvestigationControls.swift
//  swiftdatabug
//
//  Created by Nils Neuhaus on 09.03.26.
//



struct InvestigationControls: View {
    @Binding var sortBy: InvestigationSortBy

    var body: some View {
        Picker("Sort By", selection: $sortBy) {
            ForEach(InvestigationSortBy.allCases) { sort in
                Text(sort.rawValue).tag(sort)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }
}

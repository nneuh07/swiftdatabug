import SwiftData
import SwiftUI

struct SortCrashInvestigationRootView: View {
    var body: some View {
        InvestigationContainerView(
            container: SortCrashInvestigationDataStack.container()
        ) {
            SortCrashInvestigationView()
        }
    }
}

private struct InvestigationContainerView<Content: View>: View {
    let container: ModelContainer
    let content: Content

    init(
        container: ModelContainer,
        @ViewBuilder content: () -> Content
    ) {
        self.container = container
        self.content = content()
    }

    var body: some View {
        content.modelContainer(container)
    }
}

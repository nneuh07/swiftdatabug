# SwiftData Nested Sort Repro

This project is a minimal repro for a SwiftData runtime crash in `Release` when sorting on a nested optional key path:

`\.imageAnalysis?.overallAestheticsScore`

## Current Structure

Active app entry:

- [swiftdatabugApp.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/swiftdatabugApp.swift)

Active repro shell:

- [SortCrashInvestigationRoot.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/SortCrashInvestigation/SortCrashInvestigationRoot.swift)
- [SortCrashInvestigationDataStack.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/SortCrashInvestigation/SortCrashInvestigationDataStack.swift)
- [SortCrashInvestigationFixture.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/SortCrashInvestigation/SortCrashInvestigationFixture.swift)
- [SortCrashInvestigationView.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/SortCrashInvestigation/SortCrashInvestigationView.swift)
- [InvestigationControls.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/SortCrashInvestigation/InvestigationControls.swift)
- [InvestigationAssetListView.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/SortCrashInvestigation/InvestigationAssetListView.swift)
- [InvestigationAssetRow.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/SortCrashInvestigation/InvestigationAssetRow.swift)

Release-sensitive file:

- [NeedToStayInOneFile.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/NeedToStayInOneFile.swift)

## Important Rule

`NeedToStayInOneFile.swift` must stay in one file for `Release` builds.

That file contains the active SwiftData models and the active `InvestigationSortBy` definition used by the repro. Based on the investigation so far:

- when the active model/sort definitions stay together in one file, the repro behaves differently
- when those definitions are split across multiple files, the `Release` build crashes again on the nested sort path

So for the bug report and for any stable reproduction:

- keep the active `InvestigationPhotoAsset` model in `NeedToStayInOneFile.swift`
- keep the active `InvestigationImageAnalysis` model in `NeedToStayInOneFile.swift`
- keep the active `InvestigationSortBy` definition in `NeedToStayInOneFile.swift`

## Debug vs Release

In `Debug`, you can split the code into several files as you wish.

Examples:

- move the sort enum out
- move model helpers out
- move rendering helpers out
- move seed helpers out

But for `Release`, treat `NeedToStayInOneFile.swift` as the controlled variable and keep the active models plus active sort definition together in that file.

## Practical Guidance

Safe to split:

- app/root wiring
- store/container setup
- sample fixture data
- seed function
- controls
- row view
- list view

Do not split for the release-sensitive repro:

- `InvestigationPhotoAsset`
- `InvestigationImageAnalysis`
- active `InvestigationSortBy`

## Notes

[NeedToStayInOneFile.swift](/Users/nilsneuhaus/Projects/XCodeBug/swiftdatabug/swiftdatabug/NeedToStayInOneFile.swift) is the file that demonstrates the file-locality behavior we want to preserve for the repro.

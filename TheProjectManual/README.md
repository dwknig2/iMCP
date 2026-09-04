# The Project Manual — Phase 1 Source

Native iOS SwiftUI + SwiftData source for **The Project Manual** ("One Manual to Rule Them All").

This folder contains **Swift source only**. Create the Xcode project on macOS and add these files — do not use a hand-generated `.xcodeproj` from this repo.

## Xcode Setup (macOS required)

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Product name: `TheProjectManual`
4. Interface: **SwiftUI**, Storage: **SwiftData**
5. Save alongside or into this `TheProjectManual/` directory
6. Delete Xcode's placeholder `ContentView.swift` and default model file if present
7. Add existing groups/files from this tree:
   - `TheProjectManual/App/`
   - `TheProjectManual/Models/`
   - `TheProjectManual/Domain/`
   - `TheProjectManual/Views/`
   - `TheProjectManual/PreviewSupport/`
8. Add a **Unit Test** target and include `TheProjectManualTests/`
9. Set **iOS Deployment Target** to **17.0** or later (SwiftData)
10. Build (`⌘B`) and run tests (`⌘U`)

## Source Layout

```
TheProjectManual/
├── App/
│   ├── TheProjectManualApp.swift      # App entry, seeds sample data on first launch
│   └── ModelContainerFactory.swift    # SwiftData schema registration
├── Models/
│   ├── Enums.swift
│   ├── Project.swift
│   ├── BuildStep.swift
│   ├── VerificationCheck.swift
│   ├── DesignAssumption.swift
│   ├── Material.swift
│   ├── MaterialAllocation.swift
│   ├── Measurement.swift
│   ├── Note.swift
│   ├── Attachment.swift
│   ├── ProjectPhoto.swift
│   ├── ProjectChange.swift
│   └── ProjectType.swift
├── Domain/
│   ├── StepCompletionPolicy.swift     # Verification-gated step completion
│   ├── ProjectProgress.swift
│   ├── MeasurementEffectiveValue.swift
│   └── ProjectLifecycle.swift
├── Views/
│   ├── ProjectListView.swift
│   ├── CreateProjectView.swift
│   ├── ProjectDetailView.swift
│   ├── NextStepView.swift
│   └── Components/
├── PreviewSupport/
│   ├── SampleData.swift               # 49¼" workbench validation fixture
│   └── PreviewModelContainer.swift
└── TheProjectManualTests/
    ├── StepCompletionPolicyTests.swift
    ├── ProjectProgressTests.swift
    ├── MeasurementEffectiveValueTests.swift
    └── SampleDataTests.swift
```

## Vertical Slice Implemented

- Project list (active + completed sections)
- Create project
- Project overview with assumptions, steps, deviations
- Ordered build steps
- **Next Step** mode (current-step-first UX)
- Verification checklists with required gates
- Planned vs actual measurements with phase history
- Material stock + cut allocations on steps
- Gated **Complete Step** (disabled until prerequisites, verifications, and input measurements are satisfied)
- Mark project complete
- Sample workbench project seeded on first launch

## Requires Xcode / macOS Validation

The following **cannot** be verified in the Linux cloud agent environment:

- Xcode project compilation (`xcodebuild`)
- SwiftUI previews rendering
- Unit test execution (`xcodebuild test`)
- Simulator/device runtime behavior
- Code signing and provisioning
- Photo/file picker integration (attachments store metadata only in this slice)
- SwiftData migration behavior across app versions

## Sample Fixture

On first launch, the app seeds the **49¼" Sellers Workbench** project at step 8 (dry-fit left end frame), including:

- Design assumptions (dimensions, vise, joinery)
- Top thickness: planned 2.500 in → 2.469 in (glue-up) → 2.406 in (flattened)
- Derived end frame clear width: outside width − front leg − rear leg (25.000 − 3.000 − 3.000 = 19.000 in nominal; effective value uses physically measured leg thickness when recorded)
- Leg halves from measured 1.50 × 3.50 in 2×4 stock; laminated section 3.00 × 3.50 in
- Leg half rough cut 34.625 in; finished laminated leg target 34.375 in
- Front/rear leg thickness across bench (planned 3.000 in, no invented actuals)
- Rail blank 26.25 in and end-frame outside-width target 25.00 in
- Material stock (2×3 top laminations, 2×4 legs, 2×6 rails) with cut allocations
- Recorded deviation for thinner-than-planned top
- Four required verification gates before completing dry-fit

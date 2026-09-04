import Foundation
import SwiftData

enum SampleData {
    static func workbenchProject() -> [Project] {
        [makeWorkbenchProject()]
    }

    static func makeWorkbenchProject() -> Project {
        let assumptions = makeAssumptions()
        let materials = makeMaterials()
        let measurements = makeMeasurements()
        let steps = makeSteps(
            measurements: measurements,
            materials: materials
        )

        wireMeasurementDependencies(measurements)

        let topDeviation = ProjectChange(
            title: "Top thinner than planned after flattening",
            changeDescription: "Glue-up and flattening removed more material than expected. Downstream references should use 2.406 in actual thickness.",
            plannedValue: "2.500 in",
            actualValue: "2.406 in",
            discoveredAtStep: steps.first { $0.orderIndex == 4 },
            relatedMeasurement: measurements.topThickness
        )

        let project = Project(
            title: #"49¼" Sellers Workbench"#,
            projectDescription: """
            Shortened Paul Sellers-style workbench for shop use. \
            Laminated softwood top, wide aprons, wedged end-frame joinery, Yost M9WW vise.
            """,
            status: .active,
            steps: steps,
            assumptions: assumptions,
            materials: materials,
            measurements: measurements.all,
            notes: [
                Note(
                    title: "Vise placement",
                    body: "Yost M9WW mounted front-left. Leave extra meat for dog-hole row behind vise."
                ),
                Note(
                    title: "Left end frame only (fixture scope)",
                    body: "This fixture tracks the left end frame through dry-fit. Right end frame and long aprons are not yet in the step list."
                )
            ],
            changes: [topDeviation]
        )

        return project
    }

    // MARK: - Assumptions

    private static func makeAssumptions() -> [DesignAssumption] {
        [
            DesignAssumption(
                title: "Bench length",
                statement: "Overall bench length target",
                value: "49.25",
                unit: "in",
                sortOrder: 0
            ),
            DesignAssumption(
                title: "Bench depth",
                statement: "Overall bench depth target",
                value: "27",
                unit: "in",
                sortOrder: 1
            ),
            DesignAssumption(
                title: "Bench height",
                statement: "Floor to top surface",
                value: "38",
                unit: "in",
                sortOrder: 2
            ),
            DesignAssumption(
                title: "Top construction",
                statement: "Laminated construction lumber top, planned finished thickness",
                value: "2.500",
                unit: "in",
                sortOrder: 3
            ),
            DesignAssumption(
                title: "End frame outside width",
                statement: "Outside width of each end frame (leg outer face to leg outer face)",
                value: "25.000",
                unit: "in",
                sortOrder: 4
            ),
            DesignAssumption(
                title: "Leg section (laminated)",
                statement: "Two 1.50 × 3.50 in pieces face-to-face; target section 3.00 × 3.50 in",
                value: "3.00 × 3.50",
                unit: "in",
                sortOrder: 5
            ),
            DesignAssumption(
                title: "Vise",
                statement: "Yost M9WW front-left; jaw flush with front apron",
                value: "M9WW",
                unit: "",
                sortOrder: 6
            ),
            DesignAssumption(
                title: "Joinery",
                statement: "Wedged mortise-and-tenon end frames, wide aprons",
                value: "",
                unit: "",
                sortOrder: 7
            )
        ]
    }

    // MARK: - Materials

    private static func makeMaterials() -> [Material] {
        let lumber2x3 = Material(
            name: "2×3 construction lumber",
            stockDescription: """
            Measured 1.50 × 2.50 × 96 in; 8 pieces for top laminations on edge \
            (2.50 in faces glued) → nominal rough top section ~12.00 × 2.50 in
            """,
            materialRole: .stock,
            nominalThickness: 1.5,
            nominalWidth: 2.5,
            nominalLength: 96,
            quantityOnHand: "8 pieces",
            unit: "piece",
            sortOrder: 0
        )

        let lumber2x4 = Material(
            name: "2×4 construction lumber",
            stockDescription: "Measured 1.50 × 3.50 in; leg halves laminated face-to-face",
            materialRole: .stock,
            nominalThickness: 1.5,
            nominalWidth: 3.5,
            nominalLength: 96,
            quantityOnHand: "4 boards",
            unit: "board",
            sortOrder: 1
        )

        let lumber2x6 = Material(
            name: "2×6 construction lumber",
            stockDescription: "End-frame rails",
            materialRole: .stock,
            nominalThickness: 1.5,
            nominalWidth: 5.5,
            nominalLength: 96,
            quantityOnHand: "3 boards",
            unit: "board",
            sortOrder: 2
        )

        let vise = Material(
            name: "Yost M9WW vise",
            stockDescription: "9 in woodworking vise",
            materialRole: .hardware,
            quantityOnHand: "1",
            unit: "each",
            sortOrder: 3
        )

        lumber2x3.allocations = [
            MaterialAllocation(
                partLabel: "Top lamination (each)",
                plannedCutDescription: "49.5 in rough length from 2×3 (trim to 49.25 in finished bench length)",
                sortOrder: 0
            )
        ]

        lumber2x4.allocations = [
            MaterialAllocation(
                partLabel: "Leg half (each)",
                plannedCutDescription: "34.625 in rough cut (34 5/8) per half before face-to-face lamination",
                sortOrder: 0
            )
        ]

        lumber2x6.allocations = [
            MaterialAllocation(
                partLabel: "Rail blank",
                plannedCutDescription: "26.25 in rough blank for end-frame rail (includes shoulder/tenon allowance beyond 25 in outside width)",
                actualCutDescription: "26.25 in cut, ends squared",
                notes: "Trim to final length after dry-fit confirms clear span and shoulders",
                sortOrder: 0,
                isCut: true
            )
        ]

        return [lumber2x3, lumber2x4, lumber2x6, vise]
    }

    // MARK: - Measurements

    struct MeasurementSet {
        let benchLength: Measurement
        let benchDepth: Measurement
        let benchHeight: Measurement
        let topThickness: Measurement
        let endFrameOutsideWidth: Measurement
        let endFrameClearWidth: Measurement
        let railBlankLength: Measurement
        let legHalfRoughCut: Measurement
        let finishedLegLength: Measurement
        let frontLegThicknessAcrossBench: Measurement
        let rearLegThicknessAcrossBench: Measurement

        var all: [Measurement] {
            [
                benchLength,
                benchDepth,
                benchHeight,
                topThickness,
                endFrameOutsideWidth,
                endFrameClearWidth,
                railBlankLength,
                legHalfRoughCut,
                finishedLegLength,
                frontLegThicknessAcrossBench,
                rearLegThicknessAcrossBench
            ]
        }
    }

    private static func makeMeasurements() -> MeasurementSet {
        let topThickness = Measurement(
            label: "Top thickness",
            role: .tracked,
            plannedValue: 2.500,
            unit: "in",
            tolerance: 0.0625,
            sortOrder: 3,
            readings: [
                MeasurementReading(
                    value: 2.469,
                    phase: .afterGlueUp,
                    note: "Before flattening",
                    recordedAt: daysAgo(12),
                    isPhysicallyVerified: true
                ),
                MeasurementReading(
                    value: 2.406,
                    phase: .afterFlattening,
                    note: "Final flattened top — use for downstream references",
                    recordedAt: daysAgo(10),
                    isPhysicallyVerified: true
                )
            ]
        )

        let endFrameOutsideWidth = Measurement(
            label: "Left end frame outside width",
            role: .tracked,
            plannedValue: 25.0,
            unit: "in",
            tolerance: 0.03125,
            sortOrder: 4
        )

        let frontLegThicknessAcrossBench = Measurement(
            label: "Front leg thickness across bench",
            role: .tracked,
            plannedValue: 3.0,
            unit: "in",
            tolerance: 0.0625,
            sortOrder: 7
        )

        let rearLegThicknessAcrossBench = Measurement(
            label: "Rear leg thickness across bench",
            role: .tracked,
            plannedValue: 3.0,
            unit: "in",
            tolerance: 0.0625,
            sortOrder: 8
        )

        let endFrameClearWidth = Measurement(
            label: "End frame clear width (derived)",
            role: .derived,
            plannedValue: 19.0,
            unit: "in",
            derivationDescription: """
            End frame outside width minus front and rear leg thickness across bench \
            (25.000 − 3.000 − 3.000 = 19.000 in nominal). \
            Uses effective (physically measured or planned) values from source measurements.
            """,
            sortOrder: 9
        )

        let railBlankLength = Measurement(
            label: "Rail blank length",
            role: .tracked,
            plannedValue: 26.25,
            unit: "in",
            sortOrder: 5,
            readings: [
                MeasurementReading(
                    value: 26.25,
                    phase: .afterCut,
                    note: "Rough blank cut; final length set after dry-fit",
                    recordedAt: daysAgo(3),
                    isPhysicallyVerified: true
                )
            ]
        )

        let legHalfRoughCut = Measurement(
            label: "Leg half rough cut",
            role: .tracked,
            plannedValue: 34.625,
            unit: "in",
            sortOrder: 6,
            readings: [
                MeasurementReading(
                    value: 34.625,
                    phase: .afterCut,
                    note: "34 5/8 rough cut per half before face-to-face lamination",
                    recordedAt: daysAgo(4),
                    isPhysicallyVerified: true
                )
            ]
        )

        let finishedLegLength = Measurement(
            label: "Finished laminated leg length",
            role: .tracked,
            plannedValue: 34.375,
            unit: "in",
            sortOrder: 10
        )

        return MeasurementSet(
            benchLength: Measurement(
                label: "Bench length",
                role: .designTarget,
                plannedValue: 49.25,
                unit: "in",
                sortOrder: 0
            ),
            benchDepth: Measurement(
                label: "Bench depth",
                role: .designTarget,
                plannedValue: 27.0,
                unit: "in",
                sortOrder: 1
            ),
            benchHeight: Measurement(
                label: "Bench height",
                role: .designTarget,
                plannedValue: 38.0,
                unit: "in",
                sortOrder: 2
            ),
            topThickness: topThickness,
            endFrameOutsideWidth: endFrameOutsideWidth,
            endFrameClearWidth: endFrameClearWidth,
            railBlankLength: railBlankLength,
            legHalfRoughCut: legHalfRoughCut,
            finishedLegLength: finishedLegLength,
            frontLegThicknessAcrossBench: frontLegThicknessAcrossBench,
            rearLegThicknessAcrossBench: rearLegThicknessAcrossBench
        )
    }

    private static func wireMeasurementDependencies(_ measurements: MeasurementSet) {
        measurements.endFrameClearWidth.sourceMeasurements = [
            measurements.endFrameOutsideWidth,
            measurements.frontLegThicknessAcrossBench,
            measurements.rearLegThicknessAcrossBench
        ]
    }

    // MARK: - Steps

    private static func makeSteps(
        measurements: MeasurementSet,
        materials: [Material]
    ) -> [BuildStep] {
        let railAllocation = materials
            .first { $0.name.contains("2×6") }?
            .allocations
            .first { $0.partLabel == "Rail blank" }

        let legHalfAllocation = materials
            .first { $0.name.contains("2×4") }?
            .allocations
            .first { $0.partLabel == "Leg half (each)" }

        let step1 = completedStep(
            title: "Lay out bench top stock",
            orderIndex: 1,
            instructions: "Select straight 2×3 pieces for laminations. Mark 49.5 in rough length."
        )

        let step2 = completedStep(
            title: "Mill top laminations to rough thickness",
            orderIndex: 2,
            instructions: "Joint one face and edge per board. Target rough thickness about 1.625 in."
        )

        let step3 = completedStep(
            title: "Glue up bench top",
            orderIndex: 3,
            instructions: "Glue laminations into single slab. Record thickness after glue-up.",
            measurements: [measurements.topThickness]
        )

        let step4 = completedStep(
            title: "Flatten bench top",
            orderIndex: 4,
            instructions: "Hand-plane or scrape top flat. Record final thickness for downstream use.",
            measurements: [measurements.topThickness]
        )

        let step5 = completedStep(
            title: "Lay out leg halves",
            orderIndex: 5,
            instructions: """
            Lay out leg halves from measured 1.50 × 3.50 in 2×4 stock. \
            Target laminated section 3.00 × 3.50 in (two halves face-to-face).
            """
        )

        let step6 = completedStep(
            title: "Cut leg halves to rough length",
            orderIndex: 6,
            instructions: "Crosscut each leg half to 34.625 in (34 5/8) before lamination.",
            measurements: [measurements.legHalfRoughCut],
            materialAllocations: legHalfAllocation.map { [$0] } ?? []
        )

        let step7 = completedStep(
            title: "Laminate and clean up leg halves",
            orderIndex: 7,
            instructions: """
            Glue leg halves face-to-face for front and rear legs at the left end frame. \
            Clean up faces as needed — not heavy S4S surfacing. \
            Record across-bench leg thickness only if physically measured.
            """,
            measurements: [
                measurements.frontLegThicknessAcrossBench,
                measurements.rearLegThicknessAcrossBench,
                measurements.finishedLegLength
            ]
        )

        let dryFitVerifications = [
            VerificationCheck(
                title: "Shoulders seated",
                kind: .physical,
                orderIndex: 0
            ),
            VerificationCheck(
                title: "Frame square",
                kind: .physical,
                orderIndex: 1
            ),
            VerificationCheck(
                title: "No wind",
                kind: .physical,
                orderIndex: 2
            ),
            VerificationCheck(
                title: #"Width = 25""#,
                kind: .dimensional,
                orderIndex: 3,
                expectedValueDescription: #"Outside width 25.000 in ± 1/32"#,
                linkedMeasurement: measurements.endFrameOutsideWidth
            )
        ]

        let step8 = BuildStep(
            title: "Dry-fit left end frame",
            instructions: """
            Assemble front and rear legs with rail at the left end frame without glue. \
            Confirm shoulders seat fully, frame is square, and outside width matches target before cutting mortises.
            """,
            orderIndex: 8,
            status: .inProgress,
            targetDescription: #"25" outside width"#,
            verifications: dryFitVerifications,
            prerequisiteSteps: [step7],
            inputMeasurements: [measurements.railBlankLength],
            measurements: [
                measurements.endFrameOutsideWidth,
                measurements.endFrameClearWidth,
                measurements.railBlankLength,
                measurements.finishedLegLength,
                measurements.frontLegThicknessAcrossBench,
                measurements.rearLegThicknessAcrossBench
            ],
            materialAllocations: railAllocation.map { [$0] } ?? [],
            notes: [
                Note(body: "Check diagonals before marking mortise locations.")
            ],
            photos: [
                ProjectPhoto(caption: "Dry-fit — clamped, not glued")
            ]
        )

        let step9 = BuildStep(
            title: "Cut rail mortises",
            instructions: "Lay out and chop mortises using dry-fit frame as reference.",
            orderIndex: 9,
            status: .pending,
            targetDescription: "Mortises aligned to dry-fit shoulders",
            prerequisiteSteps: [step8],
            inputMeasurements: [measurements.endFrameOutsideWidth]
        )

        let step10 = BuildStep(
            title: "Cut wedge tenons",
            instructions: "Fit tenons to mortises. Wedges driven from outside face.",
            orderIndex: 10,
            status: .pending,
            prerequisiteSteps: [step9]
        )

        return [step1, step2, step3, step4, step5, step6, step7, step8, step9, step10]
    }

    private static func completedStep(
        title: String,
        orderIndex: Int,
        instructions: String = "",
        measurements: [Measurement] = [],
        materialAllocations: [MaterialAllocation] = []
    ) -> BuildStep {
        BuildStep(
            title: title,
            instructions: instructions,
            orderIndex: orderIndex,
            status: .completed,
            completedAt: daysAgo(max(1, 15 - orderIndex)),
            measurements: measurements,
            materialAllocations: materialAllocations
        )
    }

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
    }
}

//
// This source file is part of the SpeziConsent open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable line_length

import SpeziConsent
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct ScreenshotView1: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    @State private var document: ConsentDocument?
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        OnboardingConsentView(
            consentDocument: document,
            title: "Consent",
            currentDateInSignature: true,
            viewState: $viewState
        ) {
            path.nextStep()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ConsentShareButton(consentDocument: document, viewState: $viewState)
            }
        }
        .viewStateAlert(state: $viewState)
        .task {
            document = try? ConsentDocument(
                markdown: """
                    Spezi can render *markdown-based* **consent** documents.
                    
                    ---
                    
                    Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.
                    At vero eos et accusam et justo duo dolores et ea rebum.
                    Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.
                    <signature id=sig1 />
                    """,
                initialName: .init(givenName: "Leland", familyName: "Stanford")
            )
        }
    }
}

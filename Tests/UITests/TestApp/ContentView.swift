//
// This source file is part of the SpeziConsent open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziConsent
import SpeziViews
import SwiftUI


struct ContentView: View {
    private struct PresentedConsentDocument: Hashable, Identifiable {
        enum Mode {
            case standalone, rendered
        }
        let mode: Mode
        let docId: ConsentDocumentIdentifier
        var id: Self { self }
    }
    
    @Environment(TestAppConsentStorage.self) private var consentStorage
    
    @State private var presentedConsentDoc: PresentedConsentDocument?
    @State private var isPresentingOnboardingFlow = false
    @State private var isPresentingScreenshotView = false
    
    var body: some View {
        Form {
            Section {
                ForEach(ConsentDocumentIdentifier.allCases) { docId in
                    Button(docId.title) {
                        presentedConsentDoc = .init(mode: .standalone, docId: docId)
                    }
                    Button("\(docId.title) (Rendered)") {
                        presentedConsentDoc = .init(mode: .rendered, docId: docId)
                    }
                    .disabled(consentStorage.exportResults[docId] == nil)
                }
            }
            .accessibilityElement()
            .accessibilityIdentifier("Section:Standalone")
            Section {
                Button("Start Onboarding Flow") {
                    isPresentingOnboardingFlow = true
                }
            }
            Section {
                Button("Screenshots") {
                    isPresentingScreenshotView = true
                }
            }
        }
        .navigationTitle("SpeziConsent")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $presentedConsentDoc) { item in
            switch item.mode {
            case .standalone:
                NavigationStack {
                    StandaloneConsent(docId: item.docId)
                }
                .interactiveDismissDisabled()
            case .rendered:
                NavigationStack {
                    RenderedConsentDocumentView(docId: item.docId)
                }
                .interactiveDismissDisabled()
            }
        }
        .sheet(isPresented: $isPresentingOnboardingFlow) {
            ManagedNavigationStack {
                OnboardingConsent(docId: .first)
                OnboardingConsent(docId: .second)
                OnboardingConsent(docId: .interactive)
                RenderedConsentDocumentView(docId: .first)
                RenderedConsentDocumentView(docId: .second)
                RenderedConsentDocumentView(docId: .interactive)
            }
        }
        .sheet(isPresented: $isPresentingScreenshotView) {
            ManagedNavigationStack {
                ScreenshotView1()
            }
        }
    }
}

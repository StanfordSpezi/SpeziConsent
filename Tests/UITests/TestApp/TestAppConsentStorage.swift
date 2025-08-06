//
// This source file is part of the SpeziConsent open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import Spezi
import SpeziConsent


@Observable
@MainActor
final class TestAppConsentStorage: Module, EnvironmentAccessible, Sendable {
    var exportResults: [ConsentDocumentIdentifier: ConsentDocument.ExportResult] = [:]
}

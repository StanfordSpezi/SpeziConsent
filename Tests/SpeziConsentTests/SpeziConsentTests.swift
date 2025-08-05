//
// This source file is part of the Stanford Spezi open source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziConsent
import XCTest


final class SpeziConsentTests: XCTestCase {
    func testSpeziConsent() throws {
        let SpeziConsent = SpeziConsent()
        XCTAssertEqual(SpeziConsent.stanford, "Stanford University")
    }
}

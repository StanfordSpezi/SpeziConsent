//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation

extension ConsentDocument.Section {
    enum ConstructSectionError: Error {
        case missingAttribute(String)
        case missingField(String)
        case unexpectedElement(String)
        case other(String)
    }
    
    static func toggle(_ element: MarkdownDocument.CustomElement) throws(ConstructSectionError) -> Self {
        guard let id = element[attribute: "id"], !id.isEmpty else {
            throw .missingAttribute("id")
        }
        guard !element.content.isEmpty else {
            throw .missingField("prompt")
        }
        let textContent = try ConsentDocument.InteractiveSectionTextContent(blocks: element.content.map { content throws(ConstructSectionError) in
            switch content {
            case .text(let text):
                return .regular(text)
            case .element(let customElement):
                switch customElement.name {
                case "footnote":
                    return .footnote(customElement.content.textContent)
                default:
                    throw .unexpectedElement(customElement.name)
                }
            }
        })
        let defaultValue = element[attribute: "initial-value"].flatMap { Bool($0) } ?? false
        let expectedValue = element[attribute: "expected-value"].flatMap { Bool($0) }
        return .toggle(.init(id: id, textContent: textContent, initialValue: defaultValue, expectedValue: expectedValue))
    }
    
    // swiftlint:disable:next function_body_length cyclomatic_complexity
    static func select(_ element: MarkdownDocument.CustomElement) throws(ConstructSectionError) -> Self {
        guard let id = element[attribute: "id"], !id.isEmpty else {
            throw .missingAttribute("id")
        }
        var textContent = ConsentDocument.InteractiveSectionTextContent()
        var options: [ConsentDocument.SelectionOption] = []
        for thing in element.content {
            switch thing {
            case .text(let text):
                textContent.blocks.append(.regular(text))
            case .element(let element):
                switch element.name {
                case "footnote":
                    textContent.blocks.append(.footnote(element.content.textContent))
                case "option":
                    guard let optionId = element[attribute: "id"], !id.isEmpty else {
                        throw .missingAttribute("option.id")
                    }
                    guard case .text(let prompt) = element.content.first else {
                        throw .missingField("option.content")
                    }
                    options.append(.init(id: optionId, title: prompt))
                default:
                    throw .unexpectedElement(element.name)
                }
            }
        }
        let initialValue = element[attribute: "initial-value"] ?? ConsentDocument.SelectConfig.emptySelection
        guard initialValue.isEmpty || options.contains(where: { $0.id == initialValue }) else {
            throw .other("initial value references nonexisting option id '\(initialValue)'")
        }
        let expectedSelection = try { () throws (ConstructSectionError) -> ConsentDocument.SelectConfig.ExpectedSelection in
            let rawValue = element[attribute: "expected-value"]
            switch rawValue {
            case nil:
                return .anything(allowEmptySelection: true)
            case .some(""):
                throw .missingAttribute("expected-value")
            case .some("*"):
                return .anything(allowEmptySelection: false)
            case .some(let id):
                guard options.contains(where: { $0.id == id }) else {
                    throw .other("expected value references notexisting option id '\(id)'")
                }
                return .option(id: id)
            }
        }()
        return .select(.init(
            id: id,
            textContent: textContent,
            options: options,
            initialValue: initialValue,
            expectedSelection: expectedSelection
        ))
    }
    
    static func signature(_ element: MarkdownDocument.CustomElement) throws(ConstructSectionError) -> Self {
        guard let id = element[attribute: "id"], !id.isEmpty else {
            throw .missingField("id")
        }
        return .signature(.init(id: id))
    }
}


extension Sequence where Element == MarkdownDocument.CustomElement.Content {
    fileprivate var textContent: String {
        reduce(into: "") { result, element in
            switch element {
            case .text(let string):
                if result.isEmpty {
                    result = string
                } else {
                    result.append("\n\n\(string)")
                }
            case .element(let customElement):
                if result.isEmpty {
                    result = customElement.content.textContent
                } else {
                    result.append("\n\n\(customElement.content.textContent)")
                }
            }
        }
    }
}

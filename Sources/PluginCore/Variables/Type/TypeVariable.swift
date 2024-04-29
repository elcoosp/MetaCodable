import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A `Variable` representing a specific type.
///
/// This type can be used to implement `Codable` conformances for different
/// type declarations, i.e. `struct`, `class`, `enum` etc.
protocol TypeVariable: Variable
where CodingLocation == TypeCodingLocation, Generated == TypeGenerated? {
    /// Provides the syntax for `CodingKeys` declarations.
    ///
    /// Individual implementation can customize `CodingKeys`
    /// that are used for `Codable` conformance implementation.
    ///
    /// - Parameters:
    ///   - protocols: The protocols for which conformance generated.
    ///   - context: The context in which to perform the macro expansion.
    ///
    /// - Returns: The `CodingKeys` declarations.
    func codingKeys(
        confirmingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) -> MemberBlockItemListSyntax
}

extension TypeVariable {
    /// Get protocol with provided name.
    ///
    /// Use the provided protocols types to search protocol.
    ///
    /// - Parameters:
    ///   - name: The name of the protocol.
    ///   - types: The protocols types to search from.
    ///
    /// - Returns: The protocol type with name if exists.
    func `protocol`(named name: String, in types: [TypeSyntax]) -> TypeSyntax? {
        return
            if let conf = types.first(
                where: { $0.trimmed.description == name }
            )
        {
            conf
        } else if types.contains(
            where: { $0.description.contains(name) }
        ) {
            TypeSyntax(stringLiteral: name)
        } else {
            nil
        }
    }

    /// Get protocols with provided names.
    ///
    /// Use the provided protocols types to search protocols.
    ///
    /// - Parameters:
    ///   - names: The names of the protocols.
    ///   - protocols: The protocols types to search from.
    ///
    /// - Returns: The protocols types with names if exist.
    func protocols(
        named names: String...,
        in protocols: [TypeSyntax]
    ) -> [TypeSyntax] {
        return names.compactMap { self.protocol(named: $0, in: protocols) }
    }
}

/// Represents the syntax generated by `TypeVariable`.
///
/// Represents the `Codable` conformance generated.
package struct TypeGenerated {
    /// The decoding/encoding logic generated.
    ///
    /// Used as `Codable` conformance methods
    /// implementations.
    package let code: CodeBlockItemListSyntax
    /// Additional modifiers required.
    ///
    /// Used in `Codable` conformance methods.
    let modifiers: DeclModifierListSyntax
    /// The where clause for generic type.
    ///
    /// Can be used for constrained conformance.
    let whereClause: GenericWhereClauseSyntax?
    /// The inheritance clause syntax.
    ///
    /// Can be either conformance to `Decodable`/`Encodable`.
    let inheritanceClause: InheritanceClauseSyntax?
}

/// Represents the location for decoding/encoding for `TypeVariable`.
///
/// Represents the decoder/encoder and protocol to be confirmed by
/// `TypeVariable`.
package struct TypeCodingLocation {
    /// The method definition data type.
    ///
    /// Represents decoding/encoding
    /// method definition data.
    package struct Method {
        /// The name of the method.
        ///
        /// The decoding/encoding method name.
        package let name: TokenSyntax
        /// The decoding/encoding protocol name.
        ///
        /// Can be either `Decodable`/`Encodable`.
        package let `protocol`: String
        /// The argument label of method.
        ///
        /// The decoding/encoding method argument label.
        package let argLabel: TokenSyntax
        /// The decoder/encoder syntax to use.
        ///
        /// Represents the decoder/encoder argument syntax for
        /// the `Codable` conformance implementation methods.
        package let arg: TokenSyntax
        /// The argument type of method.
        ///
        /// The decoding/encoding method argument type.
        package let argType: TypeSyntax

        /// The default decoding method data with provided method name.
        ///
        /// By default `"init"` used as method name value.
        ///
        /// - Parameter methodName: The method name to use
        /// - Returns: The decode method data.
        package static func decode(methodName: String = "init") -> Self {
            return Method(
                name: .identifier(methodName), protocol: "Decodable",
                argLabel: "from", arg: "decoder", argType: "any Decoder"
            )
        }

        /// The default encoding method data.
        package static let encode = Method(
            name: "encode", protocol: "Encodable",
            argLabel: "to", arg: "encoder", argType: "any Encoder"
        )
    }

    /// The method definition data.
    ///
    /// Represents `Decodable`/`Encodable`
    /// implementation method definition data.
    let method: Method
    /// The conformance to be generated.
    ///
    /// Can be `Decodable`/`Encodable` type
    /// or `null` if type already has conformance.
    let conformance: TypeSyntax?

    /// Creates type decoding/encoding data from provided data.
    ///
    /// - Parameters:
    ///   - method: The method data.
    ///   - conformance: The conformed type.
    package init(method: Method, conformance: TypeSyntax?) {
        self.method = method
        self.conformance = conformance
    }
}

import SwiftSyntax

/// Attribute type for `MemberInit` macro-attribute.
///
/// Describes a macro that validates `MemberInit` macro usage
/// and generates memberwise initializer(s) declaration(s).
///
/// By default the memberwise initializer(s) generated are the same as
/// generated by Swift standard library. Additionally, `Default` attribute
/// can be added on fields to provide default value in function parameters
/// of memberwise initializer(s).
package struct MemberInit: Attribute {
    /// The node syntax provided
    /// during initialization.
    let node: AttributeSyntax

    /// Creates a new instance with the provided node
    ///
    /// The initializer fails to create new instance if the name
    /// of the provided node is different than this attribute.
    ///
    /// - Parameter node: The attribute syntax to create with.
    /// - Returns: Newly created attribute instance.
    init?(from node: AttributeSyntax) {
        guard
            node.attributeName.as(IdentifierTypeSyntax.self)!
                .name.text == Self.name
        else { return nil }
        self.node = node
    }

    /// Builds diagnoser that can validate this macro
    /// attached declaration.
    ///
    /// Builds diagnoser that validates attached declaration
    /// is `struct` declaration and macro usage is not
    /// duplicated for the same declaration.
    ///
    /// - Returns: The built diagnoser instance.
    func diagnoser() -> DiagnosticProducer {
        return AggregatedDiagnosticProducer {
            expect(syntaxes: StructDeclSyntax.self, ActorDeclSyntax.self)
            cantDuplicate()
        }
    }
}

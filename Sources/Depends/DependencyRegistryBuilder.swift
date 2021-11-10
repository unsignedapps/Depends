//
//  DependencyRegistryBuilder.swift
//  Pandora
//
//  Created by Rob Amos on 10/7/21.
//

@resultBuilder
public enum DependencyRegistryBuilder {

    /// The component type to compose expressions into. This is also the `FinalResult`.
    ///
    public typealias Component = [AnyKeyedDependency]

    // MARK: - Building Expressions

    /// Basic support for turning a `KeyedDependency` into an `AnyKeyedDependency`
    public static func buildExpression<Dependency>(_ expression: Dependency) -> Component where Dependency: KeyedDependency {
        [ AnyKeyedDependency(expression) ]
    }

    /// Support for optional `KeyedDependency`s in the result.
    public static func buildExpression<Dependency>(_ expression: Dependency?) -> Component where Dependency: KeyedDependency {
        if let expression = expression {
            return [ AnyKeyedDependency(expression) ]
        }
        return []
    }

    /// Support for consuming a sequence of dependencies.
    public static func buildExpression<Expression>(_ expression: Expression) -> Component where Expression: Sequence, Expression.Element: KeyedDependency {
        Array(expression)
            .map { AnyKeyedDependency($0) }
    }

    /// Support for consuming an optional sequence of elements.
    public static func buildExpression<Expression>(_ expression: Expression?) -> Component where Expression: Sequence, Expression.Element: KeyedDependency {
        if let expression = expression {
            return Array(expression)
                .map { AnyKeyedDependency($0) }
        }
        return []
    }

    // MARK: - Building Blocks & Components

    /// Support for result builders that return no children or void
    public static func buildBlock() -> Component {
        []
    }

    /// Support for multiple lines of `Component`s. This also constructs the `FinalResult`.
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }

    // MARK: - Building Conditionals

    /// Support for single-branch conditional statements (eg an `if` statement without an `else` branch)
    public static func buildOptional(_ components: Component?) -> Component {
        components ?? []
    }

    /// Support for multi-branch conditional statements (eg an `if` statement with an `else` branch)
    public static func buildEither(first: Component) -> Component {
        first
    }

    /// Support for multi-branch conditional statements (eg an `if` statement with an `else` branch)
    public static func buildEither(second: Component) -> Component {
        second
    }

    /// Support for `if #available` statements, we don't really need this as we're not trying
    /// to type-erase whats inside the availability statement, but @bok is a completionist so ¯\_(ツ)_/¯
    public static func buildLimitedAvailability(_ components: Component) -> Component {
        components
    }

}


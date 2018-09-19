import Fluent
import FluentMySQL
import MySQL
import Sugar
import Vapor

internal final class Work: Codable {
    internal enum Kind: String, Codable {
        case fullTime
        case partTime
        case contract
    }

    internal enum Framework: String, Codable {
        case vapor
        case perfect
        case kitura
        case other
    }

    var id: Int?

    internal var company: String
    internal var companyLogoUrl: String
    internal var location: String
    internal var kind: Kind
    internal var framework: Framework
    internal var remoteAllowed: Bool
    internal var title: String
    internal var description: String
    internal var externalUrl: String
    internal var contactEmail: String
    internal var approvedAt: Date?

    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?

    internal init(
        company: String,
        companyLogoUrl: String,
        location: String,
        kind: Kind,
        framework: Framework,
        remoteAllowed: Bool,
        title: String,
        description: String,
        externalUrl: String,
        contactEmail: String
    ) {
        self.company = company
        self.companyLogoUrl = companyLogoUrl
        self.location = location
        self.kind = kind
        self.framework = framework
        self.remoteAllowed = remoteAllowed
        self.title = title
        self.description = description
        self.externalUrl = externalUrl
        self.contactEmail = contactEmail
    }
}

// MARK: ReflectionDecodable

extension Work.Framework: ReflectionDecodable {
    public static func reflectDecoded() throws -> (Work.Framework, Work.Framework) {
        return (.vapor, .perfect)
    }
}

extension Work.Kind: ReflectionDecodable {
    public static func reflectDecoded() throws -> (Work.Kind, Work.Kind) {
        return (.fullTime, .partTime)
    }
}

// MARK: MySQLModel

extension Work: MySQLModel {
    static let createdAtKey: TimestampKey? = \.createdAt
    static let updatedAtKey: TimestampKey? = \.updatedAt
    static let deletedAtKey: TimestampKey? = \.deletedAt
}

extension Work: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return MySQLDatabase.create(self, on: connection) { builder in
            try addProperties(to: builder, excluding: [
                Work.reflectProperty(forKey: \.description),
                Work.reflectProperty(forKey: \.kind),
                Work.reflectProperty(forKey: \.framework),
            ])

            builder.field(for: \.description, type: .text)
            builder.field(
                for: \.kind,
                type: .enum([
                    Work.Kind.fullTime.rawValue,
                    Work.Kind.partTime.rawValue,
                    Work.Kind.contract.rawValue
                ]))
            builder.field(
                for: \.framework,
                type: .enum([
                    Work.Framework.vapor.rawValue,
                    Work.Framework.perfect.rawValue,
                    Work.Framework.kitura.rawValue,
                    Work.Framework.other.rawValue
                ]))
        }
    }
}

extension Work: Content {}
extension Work: Parameter {}

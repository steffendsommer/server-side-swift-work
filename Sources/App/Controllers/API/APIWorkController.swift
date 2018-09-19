import Fluent
import FluentMySQL
import ServerSideSwiftWorkShared
import Vapor

internal final class APIWorkController {
    // MARK: List

    func workList(_ req: Request) throws -> Future<[Work]> {
        return Work
            .query(on: req)
            .filter(\.approvedAt != nil)
            .sort(\.approvedAt, .descending)
            .all()
            .thenThrowing { items in
                guard items.count > 0 else {
                    throw APIError.noWorkAvailable
                }
                return items
            }
    }

    // MARK: Single item

    func work(_ req: Request) throws -> Future<Work> {
        return try req.parameters.next(Work.self)
    }
}

extension APIError: AbortError {
    public var identifier: String {
        return "noWork"
    }

    public var status: HTTPResponseStatus {
        return .custom(code: self.httpCode, reasonPhrase: "No work available")
    }

    public var reason: String {
        return "Unfortunately, no work available at this moment."
    }
}

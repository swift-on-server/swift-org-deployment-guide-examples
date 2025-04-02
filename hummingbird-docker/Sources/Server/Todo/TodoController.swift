import Foundation
import Hummingbird

struct TodoController<Repository: TodoRepository>: Sendable {

    let repository: Repository
    
    // MARK: -
    
    struct CreateRequest: Decodable {
        let title: String
        let order: Int?
    }

    struct UpdateRequest: Decodable {
        let title: String?
        let order: Int?
        let completed: Bool?
    }

    // MARK: -

    // add Todos API to router group
    func addRoutes(to group: RouterGroup<some RequestContext>) {
        group
            .get(use: self.list)
            .post(use: self.create)
            .get(":id", use: self.get)
            .patch(":id", use: self.update)
            .delete(":id", use: self.delete)
            .delete(use: self.deleteAll)
    }
    
    // MARK: -
    
    /// Get list of todos entrypoint
    func list(
        request: Request,
        context: some RequestContext
    ) async throws -> [Todo] {
        return try await self.repository.list()
    }
    
    /// Create todo entrypoint
    func create(
        request: Request,
        context: some RequestContext
    ) async throws -> EditedResponse<Todo> {
        let request = try await request.decode(
            as: CreateRequest.self,
            context: context
        )
        let todo = try await self.repository.create(
            title: request.title,
            order: request.order,
            urlPrefix: "http://localhost:8080/todos/"
        )
        return EditedResponse(status: .created, response: todo)
    }

    /// Get todo entrypoint
    func get(
        request: Request,
        context: some RequestContext
    ) async throws -> Todo? {
        let id = try context.parameters.require("id", as: UUID.self)
        return try await self.repository.get(id: id)
    }

    /// Update todo entrypoint
    func update(
        request: Request,
        context: some RequestContext
    ) async throws -> Todo? {
        let id = try context.parameters.require("id", as: UUID.self)
        let request = try await request.decode(
            as: UpdateRequest.self,
            context: context
        )
        guard let todo = try await self.repository.update(
            id: id,
            title: request.title,
            order: request.order,
            completed: request.completed
        ) else {
            throw HTTPError(.badRequest)
        }
        return todo
    }
    

    /// Delete todo entrypoint
    func delete(
        request: Request,
        context: some RequestContext
    ) async throws -> HTTPResponse.Status {
        let id = try context.parameters.require("id", as: UUID.self)
        if try await self.repository.delete(id: id) {
            return .ok
        } else {
            return .badRequest
        }
    }
    /// Delete all todos entrypoint
    func deleteAll(
        request: Request,
        context: some RequestContext
    ) async throws -> HTTPResponse.Status {
        try await self.repository.deleteAll()
        return .ok
    }

}

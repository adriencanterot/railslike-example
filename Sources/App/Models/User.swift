import Vapor
import Fluent
import Turnstile

final class User: Model {
    var id: Node?
    var name: String
    var email: Valid<Email>
    var password: String
    
    init(name:String, email:Valid<Email>, password:String) {
        self.name = name
        self.email = email
        self.password = password
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email").validated()
        password = try node.extract("password")
    }

    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email.value,
            "password:": password
        ])
    }
    
    func makeLeafNode() throws -> Node {
        return try Node(node: [
            "id":id,
            "name": name,
            "email": email.value,
            "posts": try posts().all().makeNode()
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.string("name")
            builder.string("email")
            builder.string("password")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}

extension User {
    static func tree() throws -> Node {
        let users = try User.all().map { try $0.makeLeafNode() }
        return .array(users)
    }
    
    func posts() throws -> Children<Post> {
        return children()
    }
}


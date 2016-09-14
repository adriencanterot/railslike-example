import Vapor
import Fluent

final class User: Model {
    var id: Node?
    var name: String
    var email: Valid<Email>
    
    init(name:String, email:Valid<Email>) {
        self.name = name
        self.email = email
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email").validated()
    }

    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email.value
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
            
        }
        
        try database.modify(entity) { modifier in
            modifier.string("password")
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


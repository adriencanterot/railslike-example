import Vapor
import Fluent

final class Post: Model {
    var id: Node?
    var userId: Node?
    
    var title: String
    var content: String

    init(title:String, content:String, userId:Node?) {
        self.title = title
        self.content = content
        self.userId = userId
    }
    
    public convenience init(title:String, content:String, user:User?) {
        self.init(title:title, content:content, userId: user?.id)
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        userId = try node.extract("user_id")
        title = try node.extract("title")
        content = try node.extract("content")

    }

    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "user_id": userId,
            "title": title,
            "content": content
        ])
    }
    
    func makeLeafNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "user": user().get()?.makeNode(),
            "title": title,
            "content": content
            
            ])
    }

    static func prepare(_ database: Database) throws {
        try database.create(entity) { builder in
            builder.id()
            builder.parent(User.self)
            builder.string("title")
            builder.string("content")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
    
}

extension Post {
    static func allNodes() throws -> [Node] {
        return try self.all().map { try $0.makeLeafNode() }
    }
}

extension Post {
    func user() throws -> Parent<User> {
        return try parent(userId)
    }
}

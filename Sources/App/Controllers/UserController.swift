import Vapor
import HTTP
import Turnstile

final class UserController: ResourceRepresentable {
    typealias Item = User

    let sessionManager:SessionManager
    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
        sessionManager = MemorySessionManager()
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let tree = try User.tree()
        return try drop.view.make("users/users.leaf", ["users":tree])
        
    }

    func store(request: Request) throws -> ResponseRepresentable {
        
        var user = try User(with: request)
        let credentials = UsernamePassword(username: user.email.value, password: user.password)
        let account = try user.register(credentials: credentials)
        
        //TODO handle persisting the session manager
        _ =sessionManager.createSession(account: account)
        try user.save()
        
        let tree = try User.tree()
        return try drop.view.make("Users/users.leaf", ["users": tree,
                                              "newUser": user.makeNode()])
    }

    /**
    	Since item is of type User,
    	only instances of user will be received
    */
    func show(request: Request, item user: User) throws -> ResponseRepresentable {
        //User can be used like JSON with JsonRepresentable
        return try drop.view.make("Users/user.leaf", ["user":user.makeLeafNode()])
    }

    func update(request: Request, item user: User) throws -> ResponseRepresentable {
        //User is JsonRepresentable
        var updatedUser = try User(with:request, to:user)
        try updatedUser.save()
        let tree = try User.tree()
        return try drop.view.make("Users/users.leaf", ["users": tree,
                                                  "updatedUser": user.makeNode()])
    }

    func destroy(request: Request, item user: User) throws -> ResponseRepresentable {
        //User is ResponseRepresentable by proxy of JsonRepresentable
        try user.delete()
        let users = try User.tree()
        return try drop.view.make("Users/users.leaf", ["users": users,
                                                  "deletedUser": user.makeNode()])
    }

    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
    
}

extension User {
    public convenience init(with request:Request, to user:User? = nil) throws {
        guard let name = request.data["name"]?.string,
              let email = request.data["email"],
              let password = request.data["password"]?.string
        else {
            throw Abort.custom(status: .notAcceptable, message: "input not conform")
        }
        
        try self.init(name:name, email:email.validated(), password:password)
        self.id = user?.id
    }
}

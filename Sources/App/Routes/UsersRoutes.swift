import Vapor
import HTTP
import Routing

class UserCollection:RouteCollection, EmptyInitializable {
    
  typealias Wrapped = HTTP.Responder
    func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let users = UserController(droplet: builder as! Droplet)
        builder.resource("users", users)
        
        drop.group("users") { userResource in
            userResource.get("destroy", User.self) { request, user in
                try users.destroy(request: request, item: user)
            }
            
            userResource.post("update", User.self) { request, user in
                try users.update(request: request, item: user)
            }
        }
    }
    
    required init() { }
}

class PostCollection:RouteCollection, EmptyInitializable {
    
    typealias Wrapped = HTTP.Responder
    func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let posts = PostController(droplet: builder as! Droplet)
        builder.resource("posts", posts)
        
        drop.group("posts") { userResource in
            userResource.get("destroy", Post.self) { request, user in
                try posts.destroy(request: request, item: user)
            }
            
            userResource.post("update", Post.self) { request, user in
                try posts.update(request: request, item: user)
            }
        }
    }
    
    required init() { }
}

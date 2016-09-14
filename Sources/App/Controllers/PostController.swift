import Vapor
import HTTP

final class PostController: ResourceRepresentable {
    typealias Item = Post
    
    let drop: Droplet
    init(droplet: Droplet) {
        drop = droplet
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        let posts = try Post.allNodes()
        return try drop.view.make("posts/posts.leaf", ["posts": posts.makeNode(),
                                                       "userList": User.tree()])
    }
    
    func store(request: Request) throws -> ResponseRepresentable {
        guard let title = request.data["posttitle"]?.string,
            let content = request.data["postcontent"]?.string,
            let userId = request.data["postuser"]?.string else {
                throw Abort.custom(status: .badRequest, message: "could not init from parameters")
        }
        
        guard let user = try User(from: userId) else {
            throw Abort.custom(status: .badRequest, message: "User not found")
        }
        
        var post = Post(title: title, content: content, user:user)
        try post.save()
        
        return try drop.view.make("/posts/posts.leaf", ["posts": try Post.allNodes().makeNode(),
                                                        "userList":User.tree(),
                                                        "newPost":post.makeNode()])
    }
    
    /**
    	Since item is of type User,
    	only instances of user will be received
     */
    func show(request: Request, item post: Post) throws -> ResponseRepresentable {
        //User can be used like JSON with JsonRepresentable
        return "PostController.show"
    }
    
    func update(request: Request, item post: Post) throws -> ResponseRepresentable {
        //User is JsonRepresentable
        return "PostController.update"
    }
    
    func destroy(request: Request, item post: Post) throws -> ResponseRepresentable {
        //User is ResponseRepresentable by proxy of JsonRepresentable
        return "PostController.destroy"

    }
    
    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            store: store,
            show: show,
            replace: update,
            destroy: destroy
        )
    }
    
}

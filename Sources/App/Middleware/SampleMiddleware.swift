import Vapor
import HTTP

class SampleMiddleware: Middleware {

	func respond(to request: Request, chainingTo chain: Responder) throws -> Response {
        // You can manipulate the request before calling the handler
        // and abort early if necessary, a good injection point for
        // handling auth.

        //return try Response(status: .badGateway, json: JSON(["error": "not there"]))
        if request.uri.path == "/users/" && request.session != nil {
            print("Contains session !")
        }
        let response = try chain.respond(to: request)

        // You can also manipulate the response to add headers
        // cookies, etc.

        return response

        // Vapor Middleware is based on S4 Middleware.
        // This means you can share it with any other project
        // that uses S4 Middleware. 
	}

}

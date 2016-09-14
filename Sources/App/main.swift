import Vapor
import HTTP
import VaporSQLite

/**
    Droplets are service containers that make accessing
    all of Vapor's features easy. Just call
    `drop.serve()` to serve your application
    or `drop.client()` to create a client for
    request data from other servers.
*/
let drop = Droplet(preparations:[User.self, Post.self], providers:[VaporSQLite.Provider.self])

/**
    Vapor configuration files are located
    in the root directory of the project
    under `/Config`.

    `.json` files in subfolders of Config
    override other JSON files based on the
    current server environment.

    Read the docs to learn more
*/
let _ = drop.config["app", "key"]?.string ?? ""

/**
    This first route will return the welcome.html
    view to any request to the root directory of the website.

    Views referenced with `app.view` are by default assumed
    to live in <workDir>/Resources/Views/

    You can override the working directory by passing
    --workDir to the application upon execution.
*/
drop.get("/") { request in
    return Response(redirect: "/users/")
}



/**
    This will set up the appropriate GET, PUT, and POST
    routes for basic CRUD operations. Check out the
    UserController in App/Controllers to see more.

    Controllers are also type-safe, with their types being
    defined by which StringInitializable class they choose
    to receive as parameters to their functions.
*/
drop.collection(UserCollection.self)
drop.collection(PostCollection.self)


drop.get("leaf") { request in
    return try drop.view.make("template", [
        "greeting": "Hello, world!"
    ])
}

/**
    A custom validator definining what
    constitutes a valid name. Here it is
    defined as an alphanumeric string that
    is between 5 and 20 characters.
*/
class Name: ValidationSuite {
    static func validate(input value: String) throws {
        let evaluation = OnlyAlphanumeric.self
            && Count.min(5)
            && Count.max(20)

        try evaluation.validate(input: value)
    }
}

/**
    By using `Valid<>` properties, the
    employee class ensures only valid
    data will be stored.
*/
class Employee {
    var email: Valid<Email>
    var name: Valid<Name>

    init(request: Request) throws {
        email = try request.data["email"].validated()
        name = try request.data["name"].validated()
    }
}

/**
    Allows any instance of employee
    to be returned as Json
*/
extension Employee: JSONRepresentable {
    func makeJSON() throws -> JSON {
        return try JSON(node: [
            "email": email.value,
            "name": name.value
        ])
    }
}

// Temporarily unavailable
//drop.any("validation") { request in
//    return try Employee(request: request)
//}

/**
    This simple plaintext response is useful
    when benchmarking Vapor.
*/
drop.get("plaintext") { request in
    return "Hello, World!"
}

/**
    Vapor automatically handles setting
    and retreiving sessions. Simply add data to
    the session variable and–if the user has cookies
    enabled–the data will persist with each request.
*/
drop.get("session") { request in
    let json = try JSON(node: [
        "session.data": "\(request.session)",
        "request.cookies": "\(request.cookies)",
        "instructions": "Refresh to see cookie and session get set."
    ])
    var response = try Response(status: .ok, json: json)

    request.session?["name"] = "Vapor"
    response.cookies["test"] = "123"

    return response
}

/**
    Add Localization to your app by creating
    a `Localization` folder in the root of your
    project.

    /Localization
       |- en.json
       |- es.json
       |_ default.json

    The first parameter to `app.localization` is
    the language code.
*/
drop.get("localization", String.self) { request, lang in
    return try JSON(node: [
        "title": drop.localization[lang, "welcome", "title"],
        "body": drop.localization[lang, "welcome", "body"]
    ])
}

/**
    Middleware is a great place to filter
    and modifying incoming requests and outgoing responses.

    Check out the middleware in App/Middleware.

    You can also add middleware to a single route by
    calling the routes inside of `app.middleware(MiddlewareType) {
        app.get() { ... }
    }`
*/
drop.middleware.append(SampleMiddleware())

let port = drop.config["app", "port"]?.int ?? 80

// Print what link to visit for default port
drop.serve()

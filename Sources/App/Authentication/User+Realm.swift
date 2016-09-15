import Turnstile

public struct UserAccount:Account {
    public var uniqueID:String
}

extension User:Realm {
    
    public func authenticate(credentials: Credentials) throws -> Account {
        
        guard let userNamePasswordPair = credentials as? UsernamePassword else {
            throw UnsupportedCredentialsError()
        }
        
        guard let user = try User.query().filter("email", userNamePasswordPair.username).first(),
            user.password == userNamePasswordPair.password else {
                throw IncorrectCredentialsError()
        }
        
        return UserAccount(uniqueID:"oaisjdaosidj\(self.name)")
    }
    
    public func register(credentials: Credentials) throws -> Account {
        
        guard let _ = credentials as? UsernamePassword else {
            throw UnsupportedCredentialsError()
        }
        
        return UserAccount(uniqueID:"oaisjdaosidj\(self.name)")
    }
}

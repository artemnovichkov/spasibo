//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

final class Dependency: CustomStringConvertible {

    let owner: String
    let name: String
    var fundings: [Funding]

    var description: String {
        owner + "/" + name
    }

    init(owner: String, name: String, fundings: [Funding] = []) {
        self.owner = owner
        self.name = name
        self.fundings = fundings
    }
}

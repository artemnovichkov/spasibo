//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

struct Dependency: CustomStringConvertible {

    let owner: String
    let name: String
    let fundings: [Funding]

    var description: String {
        owner + "/" + name
    }
}

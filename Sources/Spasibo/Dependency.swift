//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation

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

    convenience init?(url: URL) {
        var pathComponents = url.deletingPathExtension().pathComponents
        pathComponents.removeFirst()
        guard pathComponents.count == 2 else {
            return nil
        }
        self.init(owner: pathComponents[0], name: pathComponents[1])
    }
}

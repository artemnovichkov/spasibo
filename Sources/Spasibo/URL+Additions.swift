//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation

extension URL {

    static func funding(owner: String, name: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "raw.githubusercontent.com"
        components.path = "/\(owner)/\(name)/master/.github/FUNDING.yml"
        return components.url
    }
}

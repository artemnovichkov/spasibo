//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation

struct Podspec: Decodable {

    struct Source: Decodable {

        let git: URL?
    }

    let source: Source
}

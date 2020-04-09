//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation

struct Funding: CustomStringConvertible {

    let platform: Platform
    let values: [String]

    var urls: [URL] {
        let url = platform.url
        return values.compactMap { value in
            if let url = url {
                return url.appendingPathComponent(value)
            }
            return URL(string: value)
        }
    }

    var description: String {
        platform.rawValue
    }

    init(platform: Platform, values: [String]) {
        self.platform = platform
        self.values = values
    }

    init?(key: String, value: Any) {
        guard let platform = Platform(rawValue: key) else {
            return nil
        }
        let values: [String]
        if let test = value as? [String] {
            values = test
        }
        else if let test = value as? String {
            values = [test]
        }
        else {
            return nil
        }
        self.init(platform: platform, values: values)
    }
}

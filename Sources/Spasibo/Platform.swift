//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation

enum Platform: String {

    case communityBridge = "community_bridge"
    case github = "github"
    case issuehunt = "issuehunt"
    case kofi = "ko_fi"
    case liberapay = "liberapay"
    case openCollective = "open_collective"
    case otechie = "otechie"
    case patreon = "patreon"
    case tidelift = "tidelift"
    case custom = "custom"

    var url: URL? {
        switch self {
            case .communityBridge:
                return URL(string: "https://communitybridge.org")
            case .github:
                return URL(string: "https://github.com/sponsors")
            case .issuehunt:
                return URL(string: "https://issuehunt.io")
            case .kofi:
                return URL(string: "https://ko-fi.com")
            case .liberapay:
                return URL(string: "https://liberapay.com")
            case .openCollective:
                return URL(string: "https://opencollective.com")
            case .otechie:
                return URL(string: "https://otechie.com")
            case .patreon:
                return URL(string: "https://www.patreon.com")
            case .tidelift:
                return URL(string: "https://tidelift.com")
            case .custom:
                return nil
        }
    }
}

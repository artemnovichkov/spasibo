//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//


func execute(verbose: Bool, status: String? = nil, handler: () throws -> Void) {
    do {
        if verbose, let status = status {
            print(status)
        }
        try handler()
    }
    catch {
        if verbose {
            print(error)
        }
    }
}

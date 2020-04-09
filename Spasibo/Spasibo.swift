//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

import Foundation
import ArgumentParser
import CarthageKit
import class AppKit.NSWorkspace
import Yams

struct Spasibo: ParsableCommand {

    enum Error: Swift.Error {
        case noDependencies
        case noDependenciesWithFundings
        case noFundings
        case noSources
    }

    @Option(name: [.short, .long], default: FileManager.default.currentDirectoryPath, help: "The path to project directory.")
    var path: String

    func run() throws {
        let dependencies = try cartfileDependencies()

        if dependencies.isEmpty {
            throw Error.noDependencies
        }

        if dependencies.allSatisfy({ $0.fundings.isEmpty }) {
            throw Error.noDependenciesWithFundings
        }

        guard let dependencyIndex = choose(prompt: "Select a dependency:",
                                           options: dependencies.map(\.description)) else {
            throw Error.noDependenciesWithFundings
        }
        let dependency = dependencies[dependencyIndex]

        guard let fundingIndex = choose(prompt: "Select a platform:",
                                        options: dependency.fundings.map(\.description),
                                        selectFirst: true) else {
            throw Error.noFundings
        }
        let funding = dependency.fundings[fundingIndex]

        guard let sourceIndex = choose(prompt: "Select a source:",
                                       options: funding.urls.map(\.description),
                                       selectFirst: true) else {
            throw Error.noSources
        }
        let source = funding.urls[sourceIndex]
        print(source)
        if ask(prompt: "Want to open this donate page in your web browser? 🦄 (Y/n)") {
            NSWorkspace.shared.open(source)
        }
    }

    // MARK: - Private

    private func cartfileDependencies() throws -> [Dependency] {
        let projectDirectoryURL = URL(fileURLWithPath: path)
        let carthfileURL = Cartfile.url(in: projectDirectoryURL)
        let cartfile = try Cartfile.from(file: carthfileURL).get()
        return try cartfile.dependencies.keys.compactMap { dependency -> Dependency? in
            switch dependency {
                case let .gitHub(_, repo):
                    guard let fundingURL = URL.funding(owner: repo.owner, name: repo.name) else {
                        return nil
                    }
                    let content = try String(contentsOf: fundingURL)
                    let rawFundings = try Yams.load(yaml: content) as! [String: Any]
                    let fundings = rawFundings.compactMap { key, value in
                        Funding(key: key, value: value)
                    }
                    return Dependency(owner: repo.owner, name: repo.name, fundings: fundings)
                case .git, .binary:
                    return nil
            }
        }
    }
}

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
        case noFundings(Dependency)
        case noSources(Funding)
    }

    @Option(name: [.short, .long], default: FileManager.default.currentDirectoryPath, help: "The path to project directory.")
    var path: String

    func run() throws {
        var dependencies = [Dependency]()
        if let cartfileDependencies = try? makeCartfileDependencies() {
            dependencies.append(contentsOf: cartfileDependencies)
        }
        if let packageDependencies = try? makePackageDependencies() {
            dependencies.append(contentsOf: packageDependencies)
        }

        if dependencies.isEmpty {
            throw Error.noDependencies
        }

        try addFundings(to: dependencies)

        let fundingDependencies = dependencies.filter { dependency in
            dependency.fundings.isEmpty == false
        }

        if fundingDependencies.isEmpty {
            throw Error.noDependenciesWithFundings
        }

        guard let dependencyIndex = choose(prompt: "Select a dependency:",
                                           options: fundingDependencies.map(\.description)) else {
            throw Error.noDependenciesWithFundings
        }
        let dependency = dependencies[dependencyIndex]

        guard let fundingIndex = choose(prompt: "Select a platform:",
                                        options: dependency.fundings.map(\.description),
                                        selectFirst: true) else {
            throw Error.noFundings(dependency)
        }
        let funding = dependency.fundings[fundingIndex]

        guard let sourceIndex = choose(prompt: "Select a source:",
                                       options: funding.urls.map(\.description),
                                       selectFirst: true) else {
            throw Error.noSources(funding)
        }
        let source = funding.urls[sourceIndex]
        print(source)
        if ask(prompt: "Want to open this donate page in your web browser? (Y/n)") {
            NSWorkspace.shared.open(source)
        }
    }

    // MARK: - Private

    private func makeCartfileDependencies() throws -> [Dependency] {
        let projectDirectoryURL = URL(fileURLWithPath: path)
        let cartfileURL = Cartfile.url(in: projectDirectoryURL)
        let cartfile = try Cartfile.from(file: cartfileURL).get()
        return cartfile.dependencies.keys.compactMap { dependency -> Dependency? in
            switch dependency {
                case let .gitHub(_, repo):
                    return Dependency(owner: repo.owner, name: repo.name)
                case .git, .binary:
                    return nil
            }
        }
    }

    private func makePackageDependencies() throws -> [Dependency] {
        let packageURL = URL(fileURLWithPath: path).appendingPathComponent("Package.swift")
        let content = try String(contentsOf: packageURL)
        let dataDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = dataDetector.matches(in: content, options: [], range: NSRange(location: 0, length: content.utf16.count))
        let urls = matches.compactMap { match -> URL? in
            guard let range = Range(match.range, in: content) else {
                return nil
            }
            return URL(string: String(content[range]))
        }
        let dependencies = urls.compactMap { url -> Dependency? in
            var pathComponents = url.deletingPathExtension().pathComponents
            pathComponents.removeFirst()
            guard pathComponents.count == 2 else {
                return nil
            }
            return Dependency(owner: pathComponents[0], name: pathComponents[1])
        }
        return dependencies
    }

    private func addFundings(to dependencies: [Dependency]) throws {
        for dependency in dependencies {
            try addFunding(to: dependency)
        }
    }

    private func addFunding(to dependency: Dependency) throws {
        try addDirectFunding(to: dependency)
        if dependency.fundings.isEmpty {
            try addHealthFunding(to: dependency)
        }
    }

    private func addDirectFunding(to dependency: Dependency) throws {
        guard let fundingURL = URL.funding(owner: dependency.owner, name: dependency.name) else {
            return
        }
        dependency.fundings = try fetchFundings(from: fundingURL)
    }

    private func addHealthFunding(to dependency: Dependency) throws {
        guard let fundingURL = URL.healthFunding(owner: dependency.owner) else {
            return
        }
        dependency.fundings = try fetchFundings(from: fundingURL)
    }

    private func fetchFundings(from url: URL) throws -> [Funding] {
        let content = try String(contentsOf: url)
        guard let rawFundings = try Yams.load(yaml: content) as? [String: Any] else {
            return []
        }
        return rawFundings.compactMap { key, value in
            Funding(key: key, value: value)
        }
    }
}

extension Spasibo.Error: CustomStringConvertible {

    var description: String {
        switch self {
            case .noDependencies:
                return "There are no dependencies."
            case .noDependenciesWithFundings:
                return "There are no dependencies with funding."
            case .noFundings(let dependency):
                return "There are no fundings for \(dependency)."
            case .noSources(let funding):
                return "There are no sources for \(funding)."
        }
    }
}

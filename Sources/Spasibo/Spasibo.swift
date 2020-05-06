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
        case podspecCat(status: Int32, output: String, error: String)
        case noGitURL
        case podspecDecode(output: String)
    }

    @Option(name: .shortAndLong, default: FileManager.default.currentDirectoryPath, help: "The path to project directory.")
    var path: String

    @Flag(name: .shortAndLong, help: "Print status updates while running.")
    var verbose: Bool

    static let configuration: CommandConfiguration = .init(abstract: "🙏 Support your favourite open source projects",
                                                           version: "0.3.1")

    func run() throws {
        print("Check dependencies...")
        var dependencies = [Dependency]()
        execute(verbose: verbose, status: "⚙️ Find Cartfile dependencies") {
            let cartfileDependencies = try makeCartfileDependencies()
            dependencies.append(contentsOf: cartfileDependencies)
        }
        execute(verbose: verbose, status: "⚙️ Find Package.swift dependencies") {
            let packageDependencies = try makePackageDependencies()
            dependencies.append(contentsOf: packageDependencies)
        }
        execute(verbose: verbose, status: "⚙️ Find Podfile dependencies") {
            do {
                let podfileDependencies = try makePodfileDependencies()
                dependencies.append(contentsOf: podfileDependencies)
            }
            catch let Error.podspecCat(status: status, output: output, error: error) {
                print("""
                      Fail to run pod spec cat:
                      Status: \(status)
                      Output: \(output)
                      Error: \(error)
                      """)
                return
            }
            catch {
                throw error
            }
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
        let dependency = fundingDependencies[dependencyIndex]

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
        let dependencies = urls.compactMap(Dependency.init)
        return dependencies
    }

    private func makePodfileDependencies() throws -> [Dependency] {
        let podfileLockURL = URL(fileURLWithPath: path).appendingPathComponent("Podfile.lock")
        let content = try String(contentsOf: podfileLockURL)
        guard let podfile = try Yams.load(yaml: content) as? [String: Any] else {
            return []
        }
        guard let dependencies = podfile["DEPENDENCIES"] as? [String] else {
            return []
        }
        let dependencyNames = dependencies.compactMap { dependency -> String? in
            guard let name = dependency.split(separator: " ").first else {
                return nil
            }
            return String(name)
        }
        return dependencyNames.compactMap { name in
            do {
                let dependency = try fetchPodspecDependency(withName: name)
                return dependency
            }
            catch {
                if verbose {
                    print(error)
                }
                return nil
            }
        }
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
        guard let rawFundings = try? Yams.load(yaml: content) as? [String: Any] else {
            return []
        }
        return rawFundings.compactMap { key, value in
            Funding(key: key, value: value)
        }
    }

    func fetchPodspecDependency(withName name: String) throws -> Dependency? {
        let process = Process()
        process.launchPath = "/bin/sh"
        process.currentDirectoryPath = NSHomeDirectory()
        process.arguments = ["pod", "spec", "cat", name]
        var environment = ["HOME": NSHomeDirectory(),
                           "LANG": "en_GB.UTF-8"]
        var path = "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"
        if let envPath = ProcessInfo.processInfo.environment["PATH"] {
            path += ":" + envPath
        }
        environment["PATH"] = path
        process.environment = environment

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        process.standardOutput = outputPipe
        process.standardError = errorPipe

        try process.run()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

        process.waitUntilExit()

        let output = String(decoding: outputData, as: UTF8.self)
        let error = String(decoding: errorData, as: UTF8.self)

        if process.terminationStatus != 0 {
            throw Error.podspecCat(status: process.terminationStatus, output: output, error: error)
        }

        guard let podspec = try? JSONDecoder().decode(Podspec.self, from: outputData) else {
            throw Error.podspecDecode(output: output)
        }

        guard let git = podspec.source.git else {
            throw Error.noGitURL
        }

        return Dependency(url: git)
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
            case let .podspecCat(status: status, output: output, error: error):
                return """
                       Fail to get podspec
                       Status: \(status)
                       Output: "\(output)"
                       Error: "\(error)"
                       """
            case .noGitURL:
                return "Dependency has no git url for sources."
            case .podspecDecode(output: let output):
                return """
                       Fail to decode podspec
                       Output: "\(output)"
                       """
        }
    }
}

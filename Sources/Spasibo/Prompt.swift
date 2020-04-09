//
//  Copyright © 2020 Artem Novichkov. All rights reserved.
//

func choose(prompt: String, options: [String], selectFirst: Bool = false) -> Int? {
    if options.isEmpty {
        return nil
    }
    if selectFirst, options.count == 1 {
        return 0
    }
    print(prompt)
    let choices = options.enumerated()
        .map { offset, element in
            "\(offset + 1). " + element.description
        }
        .joined(separator: "\n")
    print(choices)

    let indexString = readLine() ?? ""
    var index = Int(indexString)
    while index == nil {
        index = choose(prompt: prompt, options: options, selectFirst: selectFirst)
    }
    guard 1...options.count ~= index! else {
        return choose(prompt: prompt, options: options, selectFirst: selectFirst)
    }
    return index! - 1
}

func ask(prompt: String) -> Bool {
    print(prompt)
    let rawAnswer = readLine() ?? ""
    var answer = rawAnswer.bool
    while answer == nil {
        answer = ask(prompt: prompt)
    }
    return answer!
}

private extension String {

    var bool: Bool? {
        switch lowercased() {
            case "true", "yes", "y", "1":
                return true
            case "false", "no", "n", "0":
                return false
            default:
                return nil
        }
    }
}

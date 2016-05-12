//
//  NoteImporter.swift
//  Sinewave
//
//  Created by Dan Appel on 5/11/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Foundation

struct NoteImporter {

    enum Error: ErrorType {
        case MissingOrExtraTokens
    }

    enum Mode {
        case CSV
        case Basic

        func splitLine(line: String) -> [String] {

            let separator: Character

            switch self {
            case .Basic: separator = " "
            case .CSV: separator = ","
            }

            return line.characters.split(separator).map(String.init)
        }
    }

    let input: String

    func parse(mode mode: Mode) throws -> [Note] {
        let lines = input.characters.split("\r\n").map(String.init).dropFirst()
        return try lines.map { try parseLine($0, mode: mode) }
    }

    func parseLine(line: String, mode: Mode) throws -> Note {

        let split = mode.splitLine(line)
        let values = split.flatMap(Double.init)

        guard values.count == 4 else { throw Error.MissingOrExtraTokens }

        return Note(
            frequency: values[0],
            amplitude: values[1],
            from: values[2],
            to: values[3]
        )
    }
}

//
//  SongViewController.swift
//  Sinewave
//
//  Created by Dan Appel on 5/5/16.
//  Copyright © 2016 dvappel. All rights reserved.
//

import Cocoa

class SongViewController: NSViewController {

    @IBOutlet weak var notesTableView: NSTableView!

    var notes: [Note] = [
        Note(frequency: 440, from: 0, to: 1.5),
        Note(frequency: 770, from: 1, to: 3)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        notesTableView.setDataSource(self)
        notesTableView.setDelegate(self)
        notesTableView.reloadData()

        playSong()
    }
}

extension SongViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return notes.count
    }
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {

        let note = notes[row]

        let column = [
            "frequency": note.frequency.description,
            "from": note.from.description,
            "to": note.to.description
        ]

        return tableColumn.flatMap { column[$0.identifier] }
    }
}

extension SongViewController: NSTableViewDelegate {
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let
            column = tableColumn,
            cell = tableView.makeViewWithIdentifier(column.identifier, owner: nil) as? NSTableCellView
            else { return nil }

        let note = notes[row]

        switch column.title.lowercaseString {

        case "frequency":
            cell.textField?.stringValue = note.frequency.description

        case "from":
            cell.textField?.stringValue = note.from.description

        case "to":
            cell.textField?.stringValue = note.to.description

        default: break
        }

        return cell
    }
}

//MARK: Sound
extension SongViewController {
    func playSong() {

        guard !notes.isEmpty else { return }

        for note in notes {
            let player = FunctionPlayer()
            player.amplitude = note.amplitude
            player.frequency = note.frequency

            NSTimer.after(note.from) {
                player.start()
            }
            NSTimer.after(note.to) {
                player.stop()
            }
        }
    }
}

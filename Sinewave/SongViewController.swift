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

    var notes = [Note]() {
        didSet {
            self.notesTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // listen for editing notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.editingDidEnd(_:)), name: NSControlTextDidEndEditingNotification, object: nil)

        notesTableView.setDataSource(self)
        notesTableView.setDelegate(self)
        notesTableView.reloadData()
    }

    @IBAction func playButtonPressed(sender: NSButton) {
        self.playNotes()
    }
    @IBAction func plusButtonPressed(sender: NSButton) {
        self.notes.append(Note(frequency: 440, amplitude: 1, from: 0, to: 1))
    }
    @IBAction func minusButtonPressed(sender: NSButton) {
        self.notes.removeAtIndex(self.notesTableView.selectedRow)
    }
    @IBAction func importButtonPressed(sender: NSButton) {
        guard let
            contents = importFileContents(),
            notes = try? NoteImporter(input: contents).parse(mode: .CSV) else {
            return
        }
        self.notes = notes
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
            "volume": note.amplitude.description,
            "from": note.from.description,
            "to": note.to.description
        ]

        return tableColumn.flatMap { column[$0.identifier] }
    }
    @objc func editingDidEnd(notification: NSNotification) {
        guard let
            textView = notification.userInfo?["NSFieldEditor"] as? NSTextView,
            cell = textView.superview?.superview?.superview as? NSTableCellView,
            row = (cell.superview as? NSTableRowView).flatMap(self.notesTableView.rowForView(_:)),
            colIndex = cell.identifier?.characters.last.flatMap(String.init(_:)).flatMap ({ Int($0) })
            else {
                print("could not get necessary information")
                return
        }

        let col = self.notesTableView.tableColumns[colIndex]
        let note = self.notes[row]

        defer { self.notesTableView.reloadData() }

        // if its not a valid double, it returns and triggers ^ which resets the tableview state
        guard let doubleValue = textView.string.flatMap(Double.init) else { return }

        switch col.title.lowercaseString {

        case "frequency":
            self.notes[row] = note.modify(frequency: doubleValue)

        case "volume":
            self.notes[row] = note.modify(amplitude: doubleValue)

        case "from":
            self.notes[row] = note.modify(from: doubleValue)

        case "to":
            self.notes[row] = note.modify(to: doubleValue)

        default:
            break
        }
    }
}

//MARK: View
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

        case "volume":
            cell.textField?.stringValue = note.amplitude.description

        case "from":
            cell.textField?.stringValue = note.from.description

        case "to":
            cell.textField?.stringValue = note.to.description

        default: break
        }

        return cell
    }
    func tableView(tableView: NSTableView, shouldEditTableColumn tableColumn: NSTableColumn?, row: Int) -> Bool {
        return true
    }
}

//MARK: Sound
extension SongViewController {
    func playNotes() {

        guard !notes.isEmpty else { return }

        for note in notes {
            let player = FunctionPlayer()
            player.amplitude = note.amplitude
            player.frequency = note.frequency

            NSTimer.after(note.from - 0.05) {
                player.start()
            }
            NSTimer.after(note.to) {
                player.stop()
            }
        }
    }
}

//MARK: Importer
extension SongViewController {
    func importFileContents() -> String? {

        let panel = NSOpenPanel()

        switch panel.runModal() {

        case NSModalResponseOK: return panel.URLs.first.flatMap { try? String(contentsOfURL: $0) }

        default: return nil

        }
    }
}

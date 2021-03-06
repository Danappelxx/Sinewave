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
    @IBOutlet weak var modificationsPopup: NSPopUpButton!

    var notes = [Note]() {
        didSet {
            self.notesTableView.reloadData()
        }
    }
    var modification: NoteModifications { return NoteModifications(rawValue: modificationsPopup.selectedItem!.title)! }

    override func viewDidLoad() {
        super.viewDidLoad()

        // listen for editing notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.editingDidEnd(_:)), name: NSControlTextDidEndEditingNotification, object: nil)

        notesTableView.setDataSource(self)
        notesTableView.setDelegate(self)
        notesTableView.reloadData()
    }

    @IBAction func plusButtonPressed(sender: NSButton) {
        self.notes.append(Note(frequency: 440, amplitude: 1, from: 0, to: 1))
    }
    @IBAction func minusButtonPressed(sender: NSButton) {
        guard notes.indices ~= notesTableView.selectedRow else { return }
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
    @IBAction func saveButtonPressed(sender: NSButton) {
        let panel = NSSavePanel()

        switch panel.runModal() {

        case NSModalResponseOK:
            guard let path = panel.URL?.path else { return }
            let content = notes.serialize().dataUsingEncoding(NSUTF8StringEncoding)
            NSFileManager.defaultManager()
                .createFileAtPath(path + ".csv", contents: content, attributes: nil)

        default: break
        }
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
            where self.notes.indices.contains(row)
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

//MARK: Song
extension SongViewController {
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {

        switch (segue.identifier ?? "") {

        case "songPlayerWindow":
            let songPlayerVC = segue.destinationController as! SongPlayerViewController
            songPlayerVC.notes = self.notes
            songPlayerVC.modification = self.modification

        default: return

        }
    }
}

//
//  ViewControllerEdit.swift
//  RsyncOSXver30
//
//  Created by Thomas Evensen on 05/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerEdit: NSViewController, SetConfigurations, SetDismisser, Index, Delay {
    @IBOutlet var localCatalog: NSTextField!
    @IBOutlet var offsiteCatalog: NSTextField!
    @IBOutlet var offsiteUsername: NSTextField!
    @IBOutlet var offsiteServer: NSTextField!
    @IBOutlet var backupID: NSTextField!
    @IBOutlet var sshport: NSTextField!
    @IBOutlet var snapshotnum: NSTextField!
    @IBOutlet var stringlocalcatalog: NSTextField!
    @IBOutlet var stringremotecatalog: NSTextField!

    var index: Int?
    var singleFile: Bool = false

    @IBAction func enabledisableresetsnapshotnum(_: NSButton) {
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        guard config.task == "snapshot" else { return }
        let info: String = NSLocalizedString("Dont change the snapshot num if you don´t know what you are doing...", comment: "Snapshots")
        Alerts.showInfo(info: info)
        if self.snapshotnum.isEnabled {
            self.snapshotnum.isEnabled = false
        } else {
            self.snapshotnum.isEnabled = true
        }
    }

    // Close and dismiss view
    @IBAction func close(_: NSButton) {
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    // Update configuration, save and dismiss view
    @IBAction func update(_: NSButton) {
        var config: [Configuration] = self.configurations!.getConfigurations()
        if self.localCatalog.stringValue.hasSuffix("/") == false, self.singleFile == false {
            self.localCatalog.stringValue += "/"
        }
        config[self.index!].localCatalog = self.localCatalog.stringValue
        if self.offsiteCatalog.stringValue.hasSuffix("/") == false {
            self.offsiteCatalog.stringValue += "/"
        }
        config[self.index!].offsiteCatalog = self.offsiteCatalog.stringValue
        config[self.index!].offsiteServer = self.offsiteServer.stringValue
        config[self.index!].offsiteUsername = self.offsiteUsername.stringValue
        config[self.index!].backupID = self.backupID.stringValue
        let port = self.sshport.stringValue
        if port.isEmpty == false {
            if let port = Int(port) {
                config[self.index!].sshport = port
            }
        } else {
            config[self.index!].sshport = nil
        }
        if self.snapshotnum.stringValue.count > 0 {
            config[self.index!].snapshotnum = Int(self.snapshotnum.stringValue)
        }
        self.configurations!.updateConfigurations(config[self.index!], index: self.index!)
        self.dismissview(viewcontroller: self, vcontroller: .vctabmain)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapshotnum.delegate = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.localCatalog.stringValue = ""
        self.offsiteCatalog.stringValue = ""
        self.offsiteUsername.stringValue = ""
        self.offsiteServer.stringValue = ""
        self.backupID.stringValue = ""
        self.sshport.stringValue = ""
        self.index = self.index()
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        self.localCatalog.stringValue = config.localCatalog
        if self.localCatalog.stringValue.hasSuffix("/") == false {
            self.singleFile = true
        } else {
            self.singleFile = false
        }
        self.offsiteCatalog.stringValue = config.offsiteCatalog
        self.offsiteUsername.stringValue = config.offsiteUsername
        self.offsiteServer.stringValue = config.offsiteServer
        self.backupID.stringValue = config.backupID
        if let port = config.sshport {
            self.sshport.stringValue = String(port)
        }
        if let snapshotnum = config.snapshotnum {
            self.snapshotnum.stringValue = String(snapshotnum)
        }
        self.changelabels()
    }

    private func changelabels() {
        let config: Configuration = self.configurations!.getConfigurations()[self.index!]
        switch config.task {
        case ViewControllerReference.shared.syncremote:
            self.stringlocalcatalog.stringValue = NSLocalizedString("Source catalog:", comment: "Tooltip")
            self.stringremotecatalog.stringValue = NSLocalizedString("Destination catalog:", comment: "Tooltip")
        default:
            self.stringlocalcatalog.stringValue = NSLocalizedString("Local catalog:", comment: "Tooltip")
            self.stringremotecatalog.stringValue = NSLocalizedString("Remote catalog:", comment: "Tooltip")
        }
    }
}

extension ViewControllerEdit: NSTextFieldDelegate {
    func controlTextDidChange(_: Notification) {
        delayWithSeconds(0.5) {
            if let num = Int(self.snapshotnum.stringValue) {
                let config: Configuration = self.configurations!.getConfigurations()[self.index!]
                guard num < config.snapshotnum ?? 0, num > 0 else {
                    self.snapshotnum.stringValue = String(config.snapshotnum ?? 1)
                    return
                }
            } else {
                let config: Configuration = self.configurations!.getConfigurations()[self.index!]
                self.snapshotnum.stringValue = String(config.snapshotnum ?? 1)
            }
        }
    }
}

//
//  ScheduleLoggData.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 23/09/2016.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
//  Object for sorting and holding logg data about all tasks.
//  Detailed logging must be set on if logging data.
//
//  swiftlint:disable syntactic_sugar line_length

import Foundation

protocol Readfiltereddata: class {
    func readfiltereddata(data: Filtereddata)
}

enum Filterlogs {
    case localCatalog
    case remoteServer
    case executeDate
}

class Filtereddata {
    var filtereddata: [NSDictionary]?
}

final class ScheduleLoggData {

    // configurationsNoS
    weak var configurationsDelegate: GetConfigurationsObject?
    var configurationsNoS: Configurations?
    // configurationsNoS

    // Loggdata is only sorted and read once
    private var loggdata: Array<NSDictionary>?
    weak var readfiltereddataDelegate: Readfiltereddata?

    func getallloggdata() -> [NSDictionary]? {
        return self.loggdata
    }

    // Function for filter loggdata
    func filter(search: String?, what: Filterlogs?) {
        guard search != nil else {
            return
        }
        guard self.loggdata != nil else {
            return
        }
        self.readfiltereddataDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vcloggdata)
            as? ViewControllerLoggData
        globalDefaultQueue.async(execute: {() -> Void in
            let filtereddata = Filtereddata()
            switch what! {
            case .executeDate:
                filtereddata.filtereddata =  self.loggdata?.filter({
                    ($0.value(forKey: "dateExecuted") as? String)!.contains(search!)
                })
            case .localCatalog:
                filtereddata.filtereddata = self.loggdata?.filter({
                    ($0.value(forKey: "localCatalog") as? String)!.contains(search!)
                })
            case .remoteServer:
                filtereddata.filtereddata = self.loggdata?.filter({
                    ($0.value(forKey: "offsiteServer") as? String)!.contains(search!)
                })
            }
            self.readfiltereddataDelegate?.readfiltereddata(data: filtereddata)
        })
    }

    // Loggdata is only read and sorted once
    private func readAndSortAllLoggdata() {
        var data = Array<NSDictionary>()
        let input: [ConfigurationSchedule] = Schedules.shared.getSchedule()
        for i in 0 ..< input.count {
            let hiddenID = Schedules.shared.getSchedule()[i].hiddenID
            if input[i].logrecords.count > 0 {
                for j in 0 ..< input[i].logrecords.count {
                    let dict = input[i].logrecords[j]
                    let logdetail: NSDictionary = [
                        "localCatalog": self.configurationsNoS!.getResourceConfiguration(hiddenID, resource: .localCatalog),
                        "offsiteServer": self.configurationsNoS!.getResourceConfiguration(hiddenID, resource: .offsiteServer),
                        "dateExecuted": (dict.value(forKey: "dateExecuted") as? String)!,
                        "resultExecuted": (dict.value(forKey: "resultExecuted") as? String)!,
                        "parent": (dict.value(forKey: "parent") as? String)!,
                        "hiddenID": hiddenID]
                    data.append(logdetail)
                }
            }
        }
        let dateformatter = Tools().setDateformat()
        self.loggdata = data.sorted { (dict1, dict2) -> Bool in
            guard dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String)!) != nil && (dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String)!) != nil) else {
                return true
            }
            if (dateformatter.date(from: (dict1.value(forKey: "dateExecuted") as? String)!))!.timeIntervalSince(dateformatter.date(from: (dict2.value(forKey: "dateExecuted") as? String)!)!) > 0 {
                return true
            } else {
                return false
            }
        }
    }

    init () {
        // configurationsNoS
        self.configurationsDelegate = ViewControllerReference.shared.getvcref(viewcontroller: .vctabmain)
            as? ViewControllertabMain
        self.configurationsNoS = self.configurationsDelegate?.getconfigurationsobject()
        // configurationsNoS
        // Read and sort loggdata only once
        if self.loggdata == nil {
            self.readAndSortAllLoggdata()
        }
    }
}

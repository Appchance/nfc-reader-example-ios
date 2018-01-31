//
//  ViewController.swift
//  NFCReaderApp
//
//  Created by Michal Banaszynski on 26/01/2018.
//  Copyright © 2018 Michal Banaszynski. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UITableViewController {

    /// NFC session refference.
    private var nfcSession: NFCNDEFReaderSession!
    
    /// Array of NFC Messages
    fileprivate var nfcMessages: [[NFCNDEFMessage]] = []
    
    fileprivate var usingSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    /// Action invoked when user click "Scan" bar button.
    ///
    /// - Parameter sender:
    @IBAction func scanButtonAction(_ sender: UIBarButtonItem) {
        guard usingSimulator == false else { return showSimulatorAlertViewController() }
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)        
        nfcSession.begin()
    }
}

// MARK: - NFCReaderSessionDelegate
extension ViewController: NFCNDEFReaderSessionDelegate {
    
    // Called when for some reason session will terminate because of an error occur
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Do whatever you want when dealing with error
        // ex. Present UIAlertController with error's description.
        print("Did fail to read NFC: \(error.localizedDescription)")
    }
    
    // Called with every successful NFC readout
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print("NFC Tag detected:")
        
        for message in messages {
            for record in message.records {
                print("""
                    TypeNameFormat - \(record.typeNameFormat)
                    Identifier - \(record.identifier)
                    Type - \(record.type)
                    Payload - \(record.payload)
                    """)
            }
        }
        
        nfcMessages.append(messages)
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return nfcMessages.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nfcMessages[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as? TableViewCell ?? UITableViewCell()
        
        let tagMessage = nfcMessages[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = tagMessage.records.map({ (record) -> String in
            return """
            TypeNameFormat - \(record.typeNameFormat)
            Identifier - \(record.identifier)
            Type - \(record.type)
            Payload - \(record.payload)
            """
        }).reduce("", { (records, nextRecord) -> String in
            return records.isEmpty ? "\(nextRecord)" : records + "\n\(nextRecord)"
        })
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "NFC tag messages"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - Handling running in sumulator
extension ViewController {
    
    fileprivate func showSimulatorAlertViewController() {
        let alert = UIAlertController(title: "Warning", message: "App is running in a simulator. CoreNFC is not supported there. Please run on a real device instead.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

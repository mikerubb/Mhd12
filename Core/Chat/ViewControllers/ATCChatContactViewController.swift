//
//  ATCChatContactViewController.swift
//  ChatApp
//
//  Created by Osama Naeem on 28/05/2019.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import UIKit

class ATCChatContactViewController: QuickTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableContents = [
            Section(title: "Contact", rows: [
                NavigationRow(text: "Our address", detailText: .subtitle("1412 Steiner Street, San Fracisco, CA, 94115"), icon: .named("globe")),
                NavigationRow(text: "E-mail us", detailText: .value1("office@iosapptemplates.com"), icon: .named("time"), action: { (row) in
                    guard let email = URL(string: "mailto:office@iosapptemplates.com") else { return }
                    UIApplication.shared.open(email)
                })
                ], footer: "Our business hours are Mon - Fri, 10am - 5pm, PST."),
            Section(title: "", rows: [
                TapActionRow(text: "Call Us", action: { (row) in
                    guard let number = URL(string: "tel://6504859694") else { return }
                    UIApplication.shared.open(number)
                })
                ]),
        ]
        
        self.title = "Contact Us"
    }
    
    // MARK: - Actions
    private func showAlert(_ sender: Row) {
        // ...
    }
    
    private func didToggleSelection() -> (Row) -> Void {
        return { row in
            // ...
        }
    }
}

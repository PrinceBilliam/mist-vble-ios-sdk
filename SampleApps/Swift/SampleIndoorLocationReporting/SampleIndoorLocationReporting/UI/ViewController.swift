//
//  ViewController.swift
//  SampleIndoorLocationReporting
//
//  Created by Rajesh Vishwakarma on 27/01/23.
//

import UIKit

class ViewController: UIViewController {

    var viewModel: ViewModel?
    private let consoleView = ConsoleView()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.viewModel = ViewModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        viewModel?.start()
        setupConsole()
    }

    private func setupConsole() {
        consoleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(consoleView)
        NSLayoutConstraint.activate([
            consoleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            consoleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            consoleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            consoleView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])
    }

}


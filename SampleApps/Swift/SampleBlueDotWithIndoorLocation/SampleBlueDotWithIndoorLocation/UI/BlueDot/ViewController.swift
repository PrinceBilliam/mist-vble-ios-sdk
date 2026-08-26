//
//  ViewController.swift
//  SampleBlueDotWithIndoorLocation
//
//  Created by Rajesh Vishwakarma on 27/01/23.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var wakeUpSwitch: UISwitch!
    @IBOutlet private var mistSdkSwitch: UISwitch!
    @IBOutlet private var mapContainer: UIView!
    @IBOutlet private var statusLabel: UILabel!

    private let blueDot: UIView = {
        let dotView = UIView(frame: .init(x: 0, y: 0, width: 10, height: 10))
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.layer.cornerRadius = 5
        dotView.backgroundColor = UIColor(red: 0.072, green: 0.593, blue: 0.997, alpha: 1.0)
        return dotView
    }()

    private let logTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        tv.textColor = UIColor(red: 0.0, green: 0.9, blue: 0.4, alpha: 1.0)
        tv.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return tv
    }()

    var viewModel: ViewModelDelegate?

    private var scale: Scale?
    private var isMapLoaded = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configurator()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        statusLabel.isHidden = true

        wakeUpSwitch.isOn = viewModel?.isMistServiceRuning ?? false
        mistSdkSwitch.isOn = viewModel?.isMistServiceRuning ?? false

        setupLogConsole()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func enableMistSDKService(_ sender: UISwitch) {

        if sender.isOn {
            HUDProgress.shared.start()
            viewModel?.startMistService()
        } else {
            viewModel?.stopMistService()
        }
    }

    @IBAction func enableAppWakeUpService(_ sender: UISwitch) {

        if sender.isOn {
            viewModel?.startWakeUp()
        } else {
            viewModel?.stopWakeUp()
        }
    }

    func updateStatus(_ loc: CGPoint) {
        let ppm = viewModel?.mapPPMValue ?? 1
        let clientLocation = CGPoint(x: loc.x / ppm, y: loc.y / ppm)
        statusLabel.text = String(format: "BlueDot Location on Map X= %.1f, Y= %.1f", clientLocation.x, clientLocation.y)
    }

    private func setupLogConsole() {
        view.addSubview(logTextView)
        NSLayoutConstraint.activate([
            logTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            logTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            logTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            logTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4)
        ])

        // Load any existing logs
        let existing = LogManager.shared.logs.joined(separator: "\n")
        if !existing.isEmpty {
            logTextView.text = existing + "\n"
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleNewLog(_:)), name: .newLogMessage, object: nil)
    }

    @objc private func handleNewLog(_ notification: Notification) {
        guard let entry = notification.object as? String else { return }
        logTextView.text = (logTextView.text ?? "") + entry + "\n"
        let bottom = NSRange(location: logTextView.text.count - 1, length: 1)
        logTextView.scrollRangeToVisible(bottom)
    }
}

extension ViewController {

    private func configurator() {
        let mistService = RealMistService(orgId: MistSDK.SDK.orgId, token: MistSDK.SDK.token)
        let wakeUpService = RealWakeupService()
        let viewModel = ViewModel(mistService: mistService, wakeUpService: wakeUpService)
        mistService.delegate = viewModel
        wakeUpService.delegate = viewModel
        viewModel.delegate = self
        self.viewModel = viewModel
    }

    private func setupMapView(with image: UIImage) {

        let floorMapView = UIView(frame: self.view.bounds)
        floorMapView.translatesAutoresizingMaskIntoConstraints = false
        floorMapView.backgroundColor = .white
        view.addSubview(floorMapView)

        let floorImageView = UIImageView(image: image)
        floorImageView.contentMode = .scaleAspectFit
        floorImageView.translatesAutoresizingMaskIntoConstraints = false
        floorMapView.addSubview(floorImageView)

        floorMapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        floorMapView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -view.bounds.height * 0.2).isActive = true
        floorMapView.layoutIfNeeded()

        let floorViewRatio = view.bounds.size.width / view.bounds.size.height
        let imageRatio = image.size.width/image.size.height

        if imageRatio >= floorViewRatio {
            floorMapView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: 10).isActive = true
            floorMapView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: image.size.height/image.size.width, constant: 0).isActive = true
        } else {
            floorMapView.widthAnchor.constraint(equalToConstant: view.bounds.height * 0.5).isActive = true
            floorMapView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: image.size.width/image.size.height, constant: 0).isActive = true
        }

        floorMapView.layoutIfNeeded()

        floorMapView.addSubview(blueDot)
        floorMapView.bringSubviewToFront(blueDot)

        NSLayoutConstraint.activate([
            floorImageView.topAnchor.constraint(equalTo: floorMapView.topAnchor),
            floorImageView.leadingAnchor.constraint(equalTo: floorMapView.leadingAnchor),
            floorImageView.trailingAnchor.constraint(equalTo: floorMapView.trailingAnchor),
            floorImageView.bottomAnchor.constraint(equalTo: floorMapView.bottomAnchor),

            blueDot.widthAnchor.constraint(equalToConstant: 10.0),
            blueDot.heightAnchor.constraint(equalToConstant: 10.0),
        ])


        view.layoutIfNeeded()

        // Calculate the Scale Factor
        let scaleX = floorMapView.bounds.width / image.size.width
        let scaleY = floorMapView.bounds.height / image.size.height

        scale = Scale(x: scaleX, y: scaleY)

        view.bringSubviewToFront(logTextView)
    }
}


// MARK: - ViewDelegate

extension ViewController: ViewDelegate {

    func didMistServiceStarted() {
        HUDProgress.shared.start()
        if let mistSdkSwitch = mistSdkSwitch {
            mistSdkSwitch.isOn = true
        }
    }

    func didLoadMistMap(with image: UIImage) {
        HUDProgress.shared.stop()
        setupMapView(with: image)
        isMapLoaded = true
        statusLabel.isHidden = false
    }

    func didUpdateMistLocation(with point: CGPoint) {
        guard isMapLoaded, let scale = scale else { return }
        let relativeLocation = point.scaleUpPoint(scale: scale)
        self.blueDot.center = relativeLocation
        updateStatus(point)
    }

    func failed(with error: String?) {
        guard let error = error else { return }
        appLog("Failed with error: \(error)")
    }
}

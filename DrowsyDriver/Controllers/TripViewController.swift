//
//  TripViewController.swift
//  DrowsyDriver
//
//  Created by Ritam Sarmah on 9/16/18.
//  Copyright © 2018 Ritam Sarmah. All rights reserved.
//

import UIKit
import AVKit
import MapKit
import CoreLocation
import Vision

class TripViewController: GradientViewController, AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate {
    
    // MARK: - Properties
    private var pauseButton: RoundedButton!
    private var endButton: RoundedButton!
    private var settingsButton: UIButton!
    private var driveTimeLabel: UILabel!
    private var etaLabel: UILabel!
    private var buttonStackView: UIStackView!
    private var restStopButton: RoundedSelectionItem!

    private var tripTimer = TimeTracker(name: "trip")
    private var snoozeTimer: Timer?
    private var isAlarmOn = false
    private var alarmPlayer = AVAudioPlayer()
    
    private var statusText: NSAttributedString {
        let boldAttrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.DisplayBold,
            NSAttributedString.Key.foregroundColor: Colors.DisplayText
        ]
        let normalAttrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.DisplayNormal,
            NSAttributedString.Key.foregroundColor: Colors.DisplayText
        ]
        
        let attributedString = NSMutableAttributedString(string: "You've been driving for \(tripTimer.elapsedTime)", attributes: normalAttrs)
        attributedString.setAttributes(boldAttrs, range: NSMakeRange(24, attributedString.length - 24))
        return attributedString
    }
    
    private let locationManager = CLLocationManager()
    private let locationUpdateFrequency: TimeInterval = 5
    private var locationTimer: Timer?
    private var nearestRestStop: MKMapItem?
    
    // MARK: Eye Tracking
    
    // AVCapture variables to hold sequence data
    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var videoDataOutputQueue: DispatchQueue?
    
    private var captureDevice: AVCaptureDevice?
    private var captureDeviceResolution: CGSize = CGSize()
    
    // Layer UI for drawing Vision results
    private var rootLayer: CALayer?
    private var detectionOverlayLayer: CALayer?
    private var detectedFaceRectangleShapeLayer: CAShapeLayer?
    private var detectedFaceLandmarksShapeLayer: CAShapeLayer?
    
    // Vision requests
    private var detectionRequests: [VNDetectFaceRectanglesRequest]?
    private var trackingRequests: [VNTrackObjectRequest]?
    
    private lazy var sequenceRequestHandler = VNSequenceRequestHandler()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        tripTimer.start()
        NotificationCenter.default.addObserver(self, selector: #selector(updateStatus), name: tripTimer.notification.name, object: nil)
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Facial detection configuration
        session = self.setupAVCaptureSession()
        prepareVisionRequest()
        session?.startRunning()
        
        // Audio configuration
        let audioData = NSDataAsset(name: SettingsManager.shared.alarmSound.rawValue)!.data
        alarmPlayer = try! AVAudioPlayer(data: audioData)
        alarmPlayer.numberOfLoops = -1
        
        // Location configuration
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            self.locationManager.startUpdatingLocation()
            locationTimer = Timer.scheduledTimer(withTimeInterval: locationUpdateFrequency, repeats: true, block: { _ in
                self.locationManager.startUpdatingLocation()
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
        session = nil
        locationTimer?.invalidate()
        locationTimer = nil
        snoozeTimer?.invalidate()
        snoozeTimer = nil
        locationManager.stopUpdatingLocation()
        stopAlarm()
    }
    
    @objc func pauseButtonPressed() {
        if pauseButton.titleLabel?.text == "Pause" {
            tripTimer.pause()
            session?.stopRunning()
            snoozeTimer?.invalidate()
            stopAlarm()
            pauseButton.setTitle("Resume", for: .normal)
        } else {
            tripTimer.resume()
            session?.startRunning()
            pauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    @objc func updateStatus() {
        DispatchQueue.main.async {
            self.driveTimeLabel.attributedText = self.statusText
        }
    }
    
    @objc func startAlarm() {
        if !isAlarmOn {
            isAlarmOn = true
            backgroundGradient = Colors.Background.Warning
            alarmPlayer.currentTime = 0
            alarmPlayer.play()
        }
    }
    
    func stopAlarm() {
        if isAlarmOn {
            isAlarmOn = false
            alarmPlayer.stop()
            DispatchQueue.main.async {
                self.backgroundGradient = Colors.Background.Main
            }
        }
    }
    
    @objc func openSettings() {
        let vc = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavigation") as! UINavigationController
        present(vc, animated: true, completion: nil)
    }
    
    @objc func stopTrip() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Location/Navigation
    
    @objc func navigateToRestStop() {
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        nearestRestStop?.openInMaps(launchOptions: options)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        calculateRestStopETA(from: location)
        manager.stopUpdatingLocation()
    }
    
    private func calculateRestStopETA(from location: CLLocation) {
        
        let userCoordinate = location.coordinate
        
        // Search for rest stops
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = SettingsManager.shared.quickNavigateQuery
        request.region = MKCoordinateRegion(center: userCoordinate, latitudinalMeters: 10, longitudinalMeters: 10)
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let restStops = response?.mapItems else {
                self.restStopButton.textLabel.text = "Location search failed"
                self.restStopButton.detailLabel.text = "No \"\(SettingsManager.shared.quickNavigateQuery.lowercased())\" found"
                return
            }
            
            // Find nearest rest stop
            self.nearestRestStop = restStops.reduce((CLLocationDistanceMax, nil)) { (nearest, stop) in
                let coord = stop.placemark.coordinate
                let restStopLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
                let travelDistance = location.distance(from: restStopLocation)
                return travelDistance < nearest.0 ? (travelDistance, stop) : nearest
            }.1
            
            // Get directions to nearest rest stop
            let directionsRequest = MKDirections.Request()
            directionsRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
            directionsRequest.destination = self.nearestRestStop
            directionsRequest.transportType = .automobile
            
            let directions = MKDirections(request: directionsRequest)
            directions.calculateETA(completionHandler: { [weak self ] (response, error) in
                guard let eta = response?.expectedTravelTime else {
                    self?.restStopButton.textLabel.text = "Location search failed"
                    self?.restStopButton.detailLabel.text = "No \"\(SettingsManager.shared.quickNavigateQuery.lowercased())\" found"
                    return
                }
                
                DispatchQueue.main.async {
                    self?.restStopButton.textLabel.text = eta.hoursMinutesDescription()
                    self?.restStopButton.detailLabel.text = self?.nearestRestStop?.name ?? "from nearest \(SettingsManager.shared.quickNavigateQuery.lowercased())"
                }
            })
        }
    }
    
    
    // MARK: UI
    
    func updateUI() {
        view.backgroundColor = .clear
        backgroundGradient = Colors.Background.Main
        
        // End Button
        endButton = RoundedButton()
        endButton.setTitle("End", for: .normal)
        endButton.addTarget(self, action: #selector(stopTrip), for: .touchUpInside)
        
        // Pause Button
        pauseButton = RoundedButton()
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.addTarget(self, action: #selector(pauseButtonPressed), for: .touchUpInside)
        
        // Button Stack View
        buttonStackView = UIStackView(arrangedSubviews: [pauseButton, endButton])
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 16
        
        view.addSubview(buttonStackView)
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constraints.ButtonStackView.leftConstant).isActive = true
        buttonStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraints.ButtonStackView.rightConstant).isActive = true
        buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constraints.ButtonStackView.bottomConstant).isActive = true
        buttonStackView.heightAnchor.constraint(equalToConstant: Constraints.ButtonStackView.height).isActive = true
        
        // Settings Button
        settingsButton = UIButton(type: .system)
        let image = UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate)
        settingsButton.setImage(image, for: .normal)
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.contentHorizontalAlignment = .fill
        settingsButton.contentVerticalAlignment = .fill
        settingsButton.tintColor = .white
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constraints.SettingsButton.topConstant).isActive = true
        settingsButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraints.SettingsButton.rightConstant).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: Constraints.SettingsButton.width).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: Constraints.SettingsButton.height).isActive = true
        
        // Rest Stop View
        restStopButton = RoundedSelectionItem()
        restStopButton.textLabel.text = "..."
        restStopButton.detailLabel.text = "to nearest rest stop"
        
        view.addSubview(restStopButton)
        restStopButton.translatesAutoresizingMaskIntoConstraints = false
        restStopButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constraints.RestStopView.leftConstant).isActive = true
        restStopButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraints.RestStopView.rightConstant).isActive = true
        restStopButton.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: Constraints.RestStopView.bottomConstant).isActive = true
        restStopButton.heightAnchor.constraint(equalToConstant: Constraints.RestStopView.height).isActive = true
        restStopButton.addTarget(self, action: #selector(navigateToRestStop), for: .touchUpInside)
        
        // Drive Time Label
        driveTimeLabel = UILabel()
        driveTimeLabel.numberOfLines = 0
        updateStatus()
        
        view.addSubview(driveTimeLabel)
        driveTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        driveTimeLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constraints.StatusText.leftConstant).isActive = true
        driveTimeLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraints.StatusText.rightConstant).isActive = true
        driveTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        driveTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constraints.DriveTimeLabel.topConstant).isActive = true
        
        // ETA Label
        etaLabel = UILabel()
        etaLabel.numberOfLines = 0
        updateStatus()
        
        view.addSubview(etaLabel)
        etaLabel.translatesAutoresizingMaskIntoConstraints = false
        etaLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constraints.StatusText.leftConstant).isActive = true
        etaLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: Constraints.StatusText.rightConstant).isActive = true
        etaLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        etaLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private enum Constraints {
        
        enum SettingsButton {
            static let width: CGFloat = 44
            static let height: CGFloat = 44
            static let topConstant: CGFloat = 8
            static let rightConstant: CGFloat = -16
        }
        
        enum RestStopView {
            static let height: CGFloat = 80
            static let bottomConstant: CGFloat = -16
            static let leftConstant: CGFloat = 24
            static let rightConstant: CGFloat = -24
        }
        
        enum ButtonStackView {
            static let height: CGFloat = 55
            static let bottomConstant: CGFloat = -24
            static let leftConstant: CGFloat = 24
            static let rightConstant: CGFloat = -24
        }
        
        enum StatusText {
            static let leftConstant: CGFloat = 24
            static let rightConstant: CGFloat = -24
        }
        
        enum DriveTimeLabel {
            static let topConstant: CGFloat = 80
        }
    }
    
}

extension TripViewController {
    
    // MARK: AVCapture Setup
    
    /// - Tag: CreateCaptureSession
    fileprivate func setupAVCaptureSession() -> AVCaptureSession? {
        let captureSession = AVCaptureSession()
        do {
            let inputDevice = try self.configureFrontCamera(for: captureSession)
            self.configureVideoDataOutput(for: inputDevice.device, resolution: inputDevice.resolution, captureSession: captureSession)
            return captureSession
        } catch let executionError as NSError {
            Alert.presentError(on: self, executionError)
        } catch {
            Alert.presentDefaultError(on: self)
        }
        
        self.teardownAVCapture()
        
        return nil
    }
    
    /// - Tag: ConfigureDeviceResolution
    fileprivate func highestResolution420Format(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
        var highestResolutionFormat: AVCaptureDevice.Format? = nil
        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)
        
        for format in device.formats {
            let deviceFormat = format as AVCaptureDevice.Format
            
            let deviceFormatDescription = deviceFormat.formatDescription
            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
                    highestResolutionFormat = deviceFormat
                    highestResolutionDimensions = candidateDimensions
                }
            }
        }
        
        if highestResolutionFormat != nil {
            let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width), height: CGFloat(highestResolutionDimensions.height))
            return (highestResolutionFormat!, resolution)
        }
        
        return nil
    }
    
    fileprivate func configureFrontCamera(for captureSession: AVCaptureSession) throws -> (device: AVCaptureDevice, resolution: CGSize) {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                }
                
                if let highestResolution = self.highestResolution420Format(for: device) {
                    try device.lockForConfiguration()
                    device.activeFormat = highestResolution.format
                    device.unlockForConfiguration()
                    
                    return (device, highestResolution.resolution)
                }
            }
        }
        
        throw NSError(domain: "ViewController", code: 1, userInfo: nil)
    }
    
    /// - Tag: CreateSerialDispatchQueue
    fileprivate func configureVideoDataOutput(for inputDevice: AVCaptureDevice, resolution: CGSize, captureSession: AVCaptureSession) {
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        // Create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured.
        // A serial dispatch queue must be used to guarantee that video frames will be delivered in order.
        let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VisionFaceTrack")
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        }
        
        videoDataOutput.connection(with: .video)?.isEnabled = true
        
        if let captureConnection = videoDataOutput.connection(with: AVMediaType.video) {
            if captureConnection.isCameraIntrinsicMatrixDeliverySupported {
                captureConnection.isCameraIntrinsicMatrixDeliveryEnabled = true
            }
        }
        
        self.videoDataOutput = videoDataOutput
        self.videoDataOutputQueue = videoDataOutputQueue
        
        self.captureDevice = inputDevice
        self.captureDeviceResolution = resolution
    }
    
    // Removes infrastructure for AVCapture as part of cleanup.
    fileprivate func teardownAVCapture() {
        self.videoDataOutput = nil
        self.videoDataOutputQueue = nil
    }
    
    // MARK: Helper Methods for Handling Device Orientation & EXIF
    
    fileprivate func radiansForDegrees(_ degrees: CGFloat) -> CGFloat {
        return CGFloat(Double(degrees) * Double.pi / 180.0)
    }
    
    func exifOrientationForDeviceOrientation(_ deviceOrientation: UIDeviceOrientation) -> CGImagePropertyOrientation {
        
        switch deviceOrientation {
        case .portraitUpsideDown:
            return .rightMirrored
            
        case .landscapeLeft:
            return .downMirrored
            
        case .landscapeRight:
            return .upMirrored
            
        default:
            return .leftMirrored
        }
    }
    
    func exifOrientationForCurrentDeviceOrientation() -> CGImagePropertyOrientation {
        return exifOrientationForDeviceOrientation(UIDevice.current.orientation)
    }
    
    // MARK: Performing Vision Requests
    
    // - Tag: WriteCompletionHandler
    fileprivate func prepareVisionRequest() {
        
        //self.trackingRequests = []
        var requests = [VNTrackObjectRequest]()
        
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
            
            if error != nil {
                print("FaceDetection error: \(String(describing: error)).")
            }
            
            guard let faceDetectionRequest = request as? VNDetectFaceRectanglesRequest,
                let results = faceDetectionRequest.results as? [VNFaceObservation] else {
                    return
            }
            DispatchQueue.main.async {
                // Add the observations to the tracking list
                for observation in results {
                    let faceTrackingRequest = VNTrackObjectRequest(detectedObjectObservation: observation)
                    requests.append(faceTrackingRequest)
                }
                self.trackingRequests = requests
            }
        })
        
        // Start with detection. Find face, then track it.
        self.detectionRequests = [faceDetectionRequest]
        self.sequenceRequestHandler = VNSequenceRequestHandler()
    }
    
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    /// - Tag: PerformRequests
    // Handle delegate method callback on receiving a sample buffer.
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var requestHandlerOptions: [VNImageOption: AnyObject] = [:]
        
        let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil)
        if cameraIntrinsicData != nil {
            requestHandlerOptions[VNImageOption.cameraIntrinsics] = cameraIntrinsicData
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to obtain a CVPixelBuffer for the current output frame.")
            return
        }
        
        let exifOrientation = self.exifOrientationForCurrentDeviceOrientation()
        
        guard let requests = self.trackingRequests, !requests.isEmpty else {
            // No tracking object detected, so perform initial detection
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: exifOrientation,
                                                            options: requestHandlerOptions)
            
            do {
                guard let detectRequests = self.detectionRequests else {
                    return
                }
                try imageRequestHandler.perform(detectRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceRectangleRequest: %@", error)
            }
            return
        }
        
        do {
            try self.sequenceRequestHandler.perform(requests,
                                                    on: pixelBuffer,
                                                    orientation: exifOrientation)
        } catch let error as NSError {
            NSLog("Failed to perform SequenceRequest: %@", error)
        }
        
        // Setup the next round of tracking.
        var newTrackingRequests = [VNTrackObjectRequest]()
        for trackingRequest in requests {
            
            guard let results = trackingRequest.results else {
                return
            }
            
            guard let observation = results[0] as? VNDetectedObjectObservation else {
                return
            }
            
            if !trackingRequest.isLastFrame {
                if observation.confidence > 0.3 {
                    trackingRequest.inputObservation = observation
                } else {
                    trackingRequest.isLastFrame = true
                }
                newTrackingRequests.append(trackingRequest)
            }
        }
        self.trackingRequests = newTrackingRequests
        
        // No faces detected, so abort
        if newTrackingRequests.isEmpty { return }
        
        // Perform face landmark tracking on detected faces.
        var faceLandmarkRequests = [VNDetectFaceLandmarksRequest]()
        
        // Perform landmark detection on tracked faces.
        for trackingRequest in newTrackingRequests {
            
            let faceLandmarksRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request, error) in
                
                if error != nil {
                    print("FaceLandmarks error: \(String(describing: error)).")
                }
                
                guard let landmarksRequest = request as? VNDetectFaceLandmarksRequest,
                    let results = landmarksRequest.results as? [VNFaceObservation] else {
                        return
                }
                
                if self.areEyesClosed(results) {
                    if self.snoozeTimer == nil {
                        DispatchQueue.main.async {
                            self.snoozeTimer = Timer.scheduledTimer(timeInterval: EyeAspectRatio.TimeInterval,
                                                                    target: self,
                                                                    selector: #selector(self.startAlarm),
                                                                    userInfo: nil,
                                                                    repeats: false)
                        }
                    }
                } else {
                    self.snoozeTimer?.invalidate()
                    self.snoozeTimer = nil
                    if self.isAlarmOn {
                        self.stopAlarm()
                    }
                }
            })
            
            guard let trackingResults = trackingRequest.results else {
                return
            }
            
            guard let observation = trackingResults[0] as? VNDetectedObjectObservation else {
                return
            }
            let faceObservation = VNFaceObservation(boundingBox: observation.boundingBox)
            faceLandmarksRequest.inputFaceObservations = [faceObservation]
            
            // Continue to track detected facial landmarks.
            faceLandmarkRequests.append(faceLandmarksRequest)
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                            orientation: exifOrientation,
                                                            options: requestHandlerOptions)
            
            do {
                try imageRequestHandler.perform(faceLandmarkRequests)
            } catch let error as NSError {
                NSLog("Failed to perform FaceLandmarkRequest: %@", error)
            }
        }
    }
    
    func areEyesClosed(_ faceObservations: [VNFaceObservation], threshold: Float = EyeAspectRatio.Threshold) -> Bool {
        for faceObservation in faceObservations {
            guard let landmarks = faceObservation.landmarks else { return false }
            let leftEAR = calculateEyeAspectRatio(landmarks.leftEye!)
            let rightEAR = calculateEyeAspectRatio(landmarks.rightEye!)
            let averageEAR = (leftEAR + rightEAR) / 2.0
            return averageEAR < threshold
        }
        return false
    }
    
    func calculateEyeAspectRatio(_ landmark: VNFaceLandmarkRegion2D) -> Float {
        let points = landmark.normalizedPoints
        let a = euclideanDistance(points[1], points[7])
        let b = euclideanDistance(points[3], points[5])
        let c = euclideanDistance(points[0], points[4])
        
        return (a + b) / (2.0 * c)
    }
    
    func euclideanDistance(_ a: CGPoint, _ b: CGPoint) -> Float {
        return hypotf((Float(a.x) - Float(b.x)), (Float(a.y) - Float(b.y)))
    }
}

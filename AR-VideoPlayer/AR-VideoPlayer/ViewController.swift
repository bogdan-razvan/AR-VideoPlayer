//
//  ViewController.swift
//  AR-VideoPlayer
//
//  Created by bogdan razvan on 26.01.2021.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!

    override var prefersStatusBarHidden: Bool { return true }

    //Configuring the Play button.
    private lazy var playButton: UIButton = {
        var button = UIButton(type: .system)
        button.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
        button.setTitle("Play Video", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.tintColor = .white
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        // Setting up the play button.
        setupButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(ARImageTrackingConfiguration())
    }

    // Setting up the play button's position and constraints.
    private func setupButton() {
        view.addSubview(playButton)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playButton.heightAnchor.constraint(equalToConstant: 60),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }

    @objc
    private func playButtonPressed() {
        // Hiding the Play button.
        playButton.isHidden = true

        // Here we check if the image that we want to track resides in the ARAssets folder.
        if let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "ARAssets", bundle: Bundle.main) {
            // If so, we create an image tracking config.
            let configuration = ARImageTrackingConfiguration()
            // And set the tracked image (default value for the maximum number of tracked images is 1).
            configuration.trackingImages = trackedImages
            sceneView.session.run(configuration)
        }
    }

}

extension ViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Making sure that the generic type ARAchor is actually an ARImageAnchor, and that the video file is present.
        guard let imageAnchor = anchor as? ARImageAnchor,
            let videoPath = Bundle.main.path(forResource: "video", ofType: "mov")
            else { return }

        // Creating a player item and a player.
        let videoPlayer = AVPlayer(playerItem: AVPlayerItem(url: URL(fileURLWithPath: videoPath)))

        // Initializing the video node with the player.
        let videoNode = SKVideoNode(avPlayer: videoPlayer)
        // Creating the video scene.
        let scene = SKScene(size: CGSize(width: 480, height: 720))
        // Setting the size and position of the video node.
        videoNode.size = scene.size
        videoNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        // Rotating the video.
        videoNode.yScale = -1.0
        videoPlayer.play()
        scene.addChild(videoNode)

        // Creating a plane having the same dimensions as our image.
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        // Setting the video scene to the plane.
        plane.firstMaterial?.diffuse.contents = scene
        // Initializing a node with the plane.
        let planeNode = SCNNode(geometry: plane)
        // Rotating the node to appear straight.
        planeNode.eulerAngles.x = -Float.pi / 2
        // Adding the plane node.
        node.addChildNode(planeNode)
    }

}

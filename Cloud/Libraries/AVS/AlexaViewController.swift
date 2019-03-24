import UIKit
import AVFoundation
import LoginWithAmazon

@objc class AlexaViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var connectedDeviceIndicationLabel: UILabel!

    var connectedDeviceIndication: String? = "No device connected"

    fileprivate var isRecording = false
    
    fileprivate var simplePCMRecorder: SimplePCMRecorder
    
    fileprivate let tempFilename = "\(NSTemporaryDirectory())avsexample.wav"
    
    fileprivate var player: AVAudioPlayer?

    required init?(coder: NSCoder) {
        self.simplePCMRecorder = SimplePCMRecorder(numberBuffers: 1)
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try self.simplePCMRecorder.setupForRecording(tempFilename, sampleRate:16000, channels:1, bitsPerChannel:16, errorHandler: nil)
            try self.simplePCMRecorder.startRecording()
            try self.simplePCMRecorder.stopRecording()
            self.simplePCMRecorder = SimplePCMRecorder(numberBuffers: 1)
        } catch _ {
            print("Something went wrong during microphone initialization")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard

        let dev = defaults.string(forKey: "connectedDeviceIndication")

        if dev != nil && (dev?.isEmpty)! == false  {
            self.connectedDeviceIndication = dev
        }
        else {
            self.connectedDeviceIndication = "No connected device"
        }

        self.connectedDeviceIndicationLabel.text = self.connectedDeviceIndication
    }

    @IBAction func recordAction(_ sender: AnyObject) {
        if !self.isRecording {
            do {
                self.isRecording = true
                
                self.simplePCMRecorder = SimplePCMRecorder(numberBuffers: 1)
                try! self.simplePCMRecorder.setupForRecording(tempFilename, sampleRate:16000, channels:1, bitsPerChannel:16, errorHandler: { (error:NSError) -> Void in
                    print(error)
                    try! self.simplePCMRecorder.stopRecording()
                })
                try self.simplePCMRecorder.startRecording()
                
                self.recordButton.setImage(UIImage(named: "StopIcon"), for: UIControlState())
                self.statusLabel.text = "Speak now..."
            } catch _ {
                self.statusLabel.text = "Something went wrong while starting microphone"
            }
        } else {
            
            do {
                self.isRecording = false
            
                self.recordButton.isEnabled = false
            
                try self.simplePCMRecorder.stopRecording()
            
                self.recordButton.setImage(UIImage(named: "MicIcon"), for: UIControlState())
                self.statusLabel.text = "Wait a moment..."
            
                self.upload()
            } catch _ {
                self.statusLabel.text = "Something went wrong while stopping microphone"
            }
        }
    }
    
    fileprivate func upload() {

        let uploader = AVSUploader()
        
        uploader.authToken = AmazonAccessToken.instance.savedToken
        
        uploader.jsonData = self.createMetadata()
        
        uploader.audioData = try! Data(contentsOf: URL(fileURLWithPath: tempFilename))

        uploader.errorHandler = { (error:Error) in
            if Config.Debug.Errors {
                print("Upload error: \(error)")
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                //self.statusLabel.text = "Upload error: \(error.localizedDescription)"
                self.statusLabel.text = "Upload error. Please try again."
                self.recordButton.isEnabled = true
            })
        }
        
        uploader.progressHandler = { (progress:Double) in
            DispatchQueue.main.async(execute: { () -> Void in
                if progress < 100.0 {
                    self.statusLabel.text = String(format: "Wait a moment...")
                } else {
                    self.statusLabel.text = "Waiting for Alexa to respond..."
                }
            })
        }
        
        uploader.successHandler = { (data:Data, parts:[PartData]) -> Void in

            for part in parts {
                if part.headers["Content-Type"] == "application/json" {
                    if Config.Debug.General {
                        print(NSString(data: part.data, encoding: String.Encoding.utf8.rawValue))
                    }
                } else if part.headers["Content-Type"] == "audio/mpeg" {
                    do {
                        do {
                            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                        } catch _ { }

                        self.player = try AVAudioPlayer(data: part.data)
                        self.player?.delegate = self
                        self.player?.volume = 1
                        self.player?.play()
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.statusLabel.text = "Alexa says..."
                        })
                    } catch let error {
                        DispatchQueue.main.async(execute: { () -> Void in
                            //self.statusLabel.text = "Playing error: \(error)"
                            self.statusLabel.text = "Playback error. Please try again."
                            self.recordButton.isEnabled = true
                        })
                    }
                }
                else {
                    print(part.headers["Content-Type"])
                }
            }


            DispatchQueue.main.async(execute: { () -> Void in
                self.statusLabel.text = "Click on the microphone to start talking to Alexa"
                self.recordButton.isEnabled = true
                })

        }
        
        try! uploader.start()
    }
    
    fileprivate func createMetadata() -> String? {
        var rootElement = [String:AnyObject]()
        
        let deviceContextPayload = ["streamId":"", "offsetInMilliseconds":"0", "playerActivity":"IDLE"]
        let deviceContext = ["name":"playbackState", "namespace":"AudioPlayer", "payload":deviceContextPayload] as [String : Any]
        rootElement["messageHeader"] = ["deviceContext":[deviceContext]] as AnyObject?
        
        let deviceProfile = ["profile":"doppler-scone", "locale":"en-us", "format":"audio/L16; rate=16000; channels=1"]
        rootElement["messageBody"] = deviceProfile as AnyObject?
        
        let data = try! JSONSerialization.data(withJSONObject: rootElement, options: JSONSerialization.WritingOptions(rawValue: 0))
        
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.statusLabel.text = "Click on the microphone to start talking to Alexa"
            self.recordButton.isEnabled = true
        })
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async(execute: { () -> Void in
            //self.statusLabel.text = "Player error: \(error)"
            self.statusLabel.text = "Playback error. Please try again."
            self.recordButton.isEnabled = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutClicked(_ sender: AnyObject) {
        AIMobileLib.clearAuthorizationState(nil)
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

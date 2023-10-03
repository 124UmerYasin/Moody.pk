//
//  NetworkSpeedTest.swift
//  Moody_Posterv2.0
//
//  Created by Syed Muhammad bin Saadat on 28/07/2021.
//

import UIKit
import Foundation

//MARK: Checks Speed check class while network call
class NetworkSpeedTest: UIViewController, URLSessionDelegate, URLSessionDataDelegate  {
    
                                //MARK: Variables
    typealias speedTestCompletionHandler = (_ megabytesPerSecond: Double? , _ error: Error?) -> Void
    typealias speedCompletionHandler = (_ netSpeed: String?) -> Void
    var speedTestCompletionBlock : speedTestCompletionHandler?
    var speedCompletionBlock : speedCompletionHandler?

        var startTime: CFAbsoluteTime!
        var stopTime: CFAbsoluteTime!
        var bytesReceived: Int!

        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
        }
    
    //MARK: Method to check speed
    func checkForSpeedTest(withCompletionBlock: @escaping speedCompletionHandler){
            var netSpeed = ""
            speedCompletionBlock = withCompletionBlock
            testDownloadSpeedWithTimout(timeout: 3.0) { [self] (speed, error) in
                netSpeed = "\(speed ?? 0.0) MB"
                speedCompletionBlock?(netSpeed)
            }
        }

        //MARK: Download test image and calculates time to download
        func testDownloadSpeedWithTimout(timeout: TimeInterval, withCompletionBlock: @escaping speedTestCompletionHandler) {

            guard let url = URL(string: "https://images.apple.com/v/imac-with-retina/a/images/overview/5k_image.jpg") else { return }

            startTime = CFAbsoluteTimeGetCurrent()
            stopTime = startTime
            bytesReceived = 0

            speedTestCompletionBlock = withCompletionBlock

            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForResource = timeout
            let session = URLSession.init(configuration: configuration, delegate: self, delegateQueue: nil)
            session.dataTask(with: url).resume()

        }

        //MARK: Delgate called when download task is complete
        //. get stopTime
        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            bytesReceived! += data.count
            stopTime = CFAbsoluteTimeGetCurrent()
        }

    
        //MARK: called when there is error in test api call
        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

            let elapsed = stopTime - startTime

            if let aTempError = error as NSError?, aTempError.domain != NSURLErrorDomain && aTempError.code != NSURLErrorTimedOut && elapsed == 0  {
                speedTestCompletionBlock?(nil, error)
                return
            }

            let speed = elapsed != 0 ? Double(bytesReceived) / elapsed / 1024.0 / 1024.0 : -1
            speedTestCompletionBlock?(speed, nil)

        }

}

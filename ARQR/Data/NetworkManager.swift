//
//  RestApiManager.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-04.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//



import Foundation
import Alamofire
import Zip

typealias ServiceResponse = (Data, Error?) -> Void

class NetworkManager: NSObject {
    
    static let shared: NetworkManager = {
        let manager = NetworkManager()
//        URLSession.shared.delegate = manager
        return manager
    }()
    
    let baseURL = "https://y6yqghqt69.execute-api.eu-west-1.amazonaws.com/prototype/api/v1"
    let resourcePath = "/resource"
    
    func getObjectInfoWithId(_ id: String, onCompletion: @escaping (VirtualObjectDescription, Error?) -> Void) {
        let route = "\(baseURL)\(resourcePath)/\(id)"
        makeHTTPGetRequest(path: route, onCompletion: { data, error in
            
            do {
                //Decode retrived data with JSONDecoder and assing type of Article object
                print(String(data: data, encoding: .utf8))
                let objectInfo = try JSONDecoder().decode(VirtualObjectDescription.self, from: data)
                onCompletion(objectInfo, error)
                
            } catch let jsonError {
                print(jsonError)
            }
        })
    }
    
    func downloadFileForVirtualObject(_ virtualObjectInfo: VirtualObjectDescription, onCompletion: @escaping (Error?) -> Void) {
        
        let fileUrl = URL(string: virtualObjectInfo.path)!
        let fileName = fileUrl.lastPathComponent
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(fileName)
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        
        print("url: \(fileUrl.absoluteString)")
        
        Alamofire.download(
            fileUrl,
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                
                print(progress.fractionCompleted)
                
            }).response(completionHandler: { (defaultDownloadResponse) in
                
                do {
                    let filePath = defaultDownloadResponse.destinationURL!
                    let unzipDirectory = try Zip.quickUnzipFile(filePath) // Unzip
                    print(unzipDirectory.absoluteString)
                }
                catch {
                    print("Something went wrong")
                }
                
                onCompletion(defaultDownloadResponse.error)
                
            })
        
    }
    
    private func makeHTTPGetRequest(path: String, onCompletion: @escaping ServiceResponse) {
        let request = URLRequest(url: URL(string: path)!)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: {data, response, error -> Void in
            guard let data = data else { return }
            onCompletion(data, error)
        })
        task.resume()
    }
}

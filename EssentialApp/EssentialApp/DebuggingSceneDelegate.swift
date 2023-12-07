//
//  DebuggingSceneDelegate.swift
//  EssentialApp
//
//  Created by Mohamed Ibrahim on 07/12/2023.
//
#if DEBUG
import UIKit
import EssentialFeed

class DebuggingSceneDelegate: SceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: localStoreURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeHTTPClient() -> HTTPClient {
        if let connectivity = UserDefaults.standard.string(forKey: "connectivity"){
            return DebuggingHTTPClient(connectivity: connectivity)
        }
        return super.makeHTTPClient()
    }
}

private class DebuggingHTTPClient: HTTPClient {
    
    private let connectivity: String
    
    init(connectivity: String) {
        self.connectivity = connectivity
    }
    
    func get(from url: URL, completion: @escaping ((HTTPClient.Result) -> Void)) -> HTTPClientTask {
        switch connectivity {
        case "online":
            completion(.success(makeSuccessResponse(for: url)))
            
        default:
            completion(.failure(NSError(domain: "offline", code: 0)))
        }
        
        return Task()
    }
    
    private func makeSuccessResponse(for url: URL) -> (Data,HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url),response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
            
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
    
    private class Task: HTTPClientTask {
        func cancel() {}
    }
}

private extension UIImage {
    
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
#endif

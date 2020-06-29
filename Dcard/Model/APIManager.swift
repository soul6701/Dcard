//
//  APIManager.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/21.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

struct APIResult {
    let json: JSON?
    let error: Error?
    let urlString: String
}
class APIManager {
    public static let shared = APIManager()
}
extension APIManager {
    static func loadAPI(httpMethod: HttpMethod = .GET, urlString: String, body: [String:Any]?) -> Observable<APIResult> {
        return Observable.create { (observer) -> Disposable in
            var _body = (body?.filter { $0.value != nil } ?? [:]) as [String:Any]
            var _urlString = urlString
            let jsonData = try? JSONSerialization.data(withJSONObject: body)
            if httpMethod == .GET {
                for (index, key) in _body.keys.enumerated() {
                    guard let value = _body[key] else {continue}
                    if value is Array<Any> {
                        let array = value as! Array<Any>
                        for data in array {
                            _urlString.append((index == 0 ? "?" : "&") + "\(key)[]=\(data)")
                        }
                    } else {
                        _urlString.append((index == 0 ? "?" : "&") + "\(key)=\(value)")
                    }
                }
            }
            guard let url = URL(string: _urlString) else {
                printError(title: "url錯誤", error: "", content: _urlString)
                return Disposables.create()
            }
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request) {data, responce, error in
                guard let data = data, error == nil else {
                    printApiError(method: "\(httpMethod)", url: urlString, body: _body, Error: error?.localizedDescription ?? "")
                    if let error = error {
                        observer.onError(error)
                    }
                    return
                }
                do {
                    let jsonObj = try JSON(data: data)
                    observer.onNext(APIResult(json: jsonObj, error: error, urlString: _urlString))
                } catch let error {
                    printError(title: "loadAPI解析json失敗", error: error.localizedDescription, content: String(bytes: data, encoding: .utf8))
                    observer.onError(error)
                }
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
extension APIManager {
    func getPost(limit: Int) -> Observable<APIResult> {
        let body = ["limit": limit]
        return APIManager.loadAPI(urlString: APIInfo.URL_Domain + APIInfo.post, body: body)
    }
    func getWhysoserious(limit: Int) -> Observable<APIResult> {
        let body = ["limit": limit]
        return APIManager.loadAPI(urlString: APIInfo.URL_Domain + APIInfo.whysoserious, body: body)
    }
}

func printApiError<T>(method: String, url: String, body: T, Error: String) {
    print("💔============================== API Request ==============================")
    print("Method: \(method) \nURL: \(url) \nbody: \(body) \nError: \(Error)")
    print("💔=========================================================================")
}
func printError<T>(title: String, error: T, content: T?) {
    print("🔥================================ ERROR =================================")
    print("ERROR: \(title) \nContent: \(error) \nContent: \(String(describing: content))")
    print("🔥=========================================================================")
}

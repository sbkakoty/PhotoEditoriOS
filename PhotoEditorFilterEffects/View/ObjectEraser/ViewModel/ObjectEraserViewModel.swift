//
//  ObjectEraserViewModel.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 29/12/22.
//

import Foundation
import Alamofire

class ObjectEraserViewModel: NSObject {
    
    func uploadRequest(imageDataOriginalImage: Data?, imageDataMaskImage: Data?, completion: @escaping (_ data: String?, _ error: String?) -> ()) {
        
        print("\(imageDataOriginalImage!.count/1024) KB")
        
        AF.upload(multipartFormData: { formData in
            formData.append(imageDataOriginalImage!, withName: "image_file", fileName: "org", mimeType: "image/jpg")
            formData.append(imageDataMaskImage!, withName: "mask_file", fileName: "mask", mimeType: "image/jpg")
            formData.append("0".data(using: .utf8)!, withName: "sync")
           },
           to: "\(AppConfig.picwishEndPoint)/api/tasks/visual/inpaint",
           headers: [
               "X-API-KEY": AppConfig.picwishAPIKey
           ]
        )
        .response { resp in
            switch resp.result {
               case .success(let JSON):
               if let data = JSON {
                    do {
                           guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                               completion(nil, NSLocalizedString("alertErrorMsgJSON", comment: ""))
                               return
                           }
                           
                           guard let data = jsonObject["data"] as? [String: Any], let task_id = data["task_id"] as? String else { return }
                           
                           print(task_id)
                           completion(task_id, nil)
                       
                    } catch {
                        completion(nil, NSLocalizedString("alertErrorMsgJSON", comment: ""))
                        return
                    }
                }
                case .failure(_):
                completion(nil, NSLocalizedString("alertErrorMsgTimeout", comment: ""))
           }
        }
        AF.session.configuration.timeoutIntervalForRequest = 60
    }
    
    func fetchFinalImage(task_id: String?, completion: @escaping (_ data: Data?, _ error: String?) -> ()) {
        
        AF.request(
            "\(AppConfig.picwishEndPoint)/api/tasks/visual/inpaint/\(task_id!)",
            method: .get,
            headers: ["X-API-KEY": AppConfig.picwishAPIKey]
        )
        .response { response in
            switch response.result {
                case .success(let JSONResponse):
                    if let responseData = JSONResponse {
                        do {
                            guard let responseJSONObject = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
                                completion(nil, NSLocalizedString("alertErrorMsgJSON", comment: ""))
                                return
                            }
                            
                            //print(responseJSONObject)
                            
                            guard let resultData = responseJSONObject["data"] as? [String: Any], let resultImageURLStr = resultData["image"] as? String else {
                                completion(nil, NSLocalizedString("alertErrorMsgGenerateImage", comment: ""))
                                return
                            }
                            
                            self.getData(from: URL(string: resultImageURLStr)!) { data, response, error in
                                guard let data = data, error == nil else { return }
                                completion(data, nil)
                            }
                        } catch {
                            completion(nil, NSLocalizedString("alertErrorMsgJSON", comment: ""))
                            return
                        }
                    }
                    case .failure(_):
                    completion(nil, NSLocalizedString("alertErrorMsgTimeout", comment: ""))
            }
        }
        AF.session.configuration.timeoutIntervalForRequest = 60
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

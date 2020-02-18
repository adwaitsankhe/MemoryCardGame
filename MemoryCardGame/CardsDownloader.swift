//
//  CardsDownloader.swift
//  MemoryCardGame
//
//  Created by Adwait Y Sankhé on 1/18/20.
//  Copyright © 2020 Adwait Y Sankhé. All rights reserved.
//

import Alamofire

struct BaseResponse: Decodable {
    let count: Int
    let images: [ImageResponse]
}

struct ImageResponse: Decodable {
    let file: String
}

class CardsDownloader {
    private let subURL = "/images/"
    private let headers = ["X-SHO-verify": "homework", "Authorization": "Bearer 308358df7811aa81e103a4b926cadf6f7f0dca2a"]
    
    private var cards = [Card]()
    private var links = [String]()
    
    private func request() -> DataRequest {
        return Alamofire.request(baseURL + subURL, method: .get, headers: headers)
    }
    
    private func getLinksArray(completion: @escaping (([String]) -> ())) {
        request().responseJSON { [weak self] response in
            if let data = try? JSONDecoder().decode(BaseResponse.self, from: response.data!) {
                for image in data.images {
                    self?.links.append(baseURL + image.file)
                }
            }
            
            completion(Array(self!.links.shuffled()[0..<8]))
        }.resume()
    }
    
    func getCardImages(completion: (([Card]?) -> ())?) {
        var cards = [Card]()
        getLinksArray { (result) in
            result.enumerated().forEach({ (i, imageURLString) in
                if let imageURL = URL(string: imageURLString), let imageData = try? Data(contentsOf: imageURL), let image = UIImage(data: imageData) {
                    let card = Card(image: image, id: i)
                    let copy = card.copy()
                    cards.append(card)
                    cards.append(copy as! Card)
                }
            })
            
            completion?(cards)
        }
    }
    
    var isNetworkReachable: Bool {
        return (NetworkReachabilityManager()?.isReachable ?? true)
    }
}

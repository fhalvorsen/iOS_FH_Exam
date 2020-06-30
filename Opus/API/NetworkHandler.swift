//
//  Top50AlbumReq.swift
//  Opus
//
//  Created by Fulin Halvorsen on 12/10/2018.
//  Copyright © 2018 Fulin Halvorsen. All rights reserved.
//

import Foundation



enum NetworkError: Error {
    case decodingError(message: String)
}


class NetworkHandler {
    
    let resourceURL:URL
    
    init(from url:String) {
        let resourceString = url
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        
        self.resourceURL = resourceURL
    }
    //https://matteomanferdini.com/network-requests-rest-apis-ios-swift/
    
    func load(url: URL, withCompletion: @escaping (Data?) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
            
            guard data != nil && error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
           
            withCompletion(data)
        }).resume()
    }
    
    
    func getTopAlbums(completion: @escaping ([Album]?) -> Void) {
        load(url: resourceURL) { data in
            guard let jsonData = data else {
                completion(nil)
                return
            }
            
            do {
                let topAlbumResp = try JSONDecoder().decode(TopAlbumRoot.self, from: jsonData)
                completion(topAlbumResp.topAlbums)
            } catch let err as NSError {
                fatalError(err.localizedDescription)
            }
        }
    }
    
    func getAlbumTracks(completion: @escaping ([Album]?) -> Void) {
        load(url: resourceURL) { data in
            guard let jsonData = data else {
                completion(nil)
                return
            }
            
            do {
                let topAlbumResp = try JSONDecoder().decode(AlbumTracksRoot.self, from: jsonData)
                completion(topAlbumResp.albumTracks)
            } catch let err as NSError {
                fatalError(err.localizedDescription)
            }
        }
    }
    
    func getReccomended(completion: @escaping (Similar?) -> Void) {
         load(url: resourceURL) { data in
                   guard let jsonData = data else {
                       completion(nil)
                       return
                   }
           
                   do {
                       let reccomendedResp = try JSONDecoder().decode(ReccomendedRoot.self, from: jsonData)
                    completion(reccomendedResp.similar)
                   } catch let err as NSError {
                       fatalError(err.localizedDescription)
                   }
               }
           }
    
    func getAlbumByTitle(completion: @escaping ([Album]?) -> Void) {
        load(url: resourceURL) { data in
            guard let jsonData = data else {
                completion(nil)
                return
            }
            do {
        
                let albumTitleResp = try JSONDecoder().decode(AlbumWTitleRoot.self, from: jsonData)
                completion(albumTitleResp.album)
            } catch {
              completion(nil)
            }
            
        }
    }
}

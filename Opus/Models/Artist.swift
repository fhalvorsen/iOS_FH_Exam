//
//  Artist.swift
//  Opus
//
//  Created  on 12/10/2018.
//  Copyright © 2019 . All rights reserved.
//

import Foundation


struct TopAlbumRoot : Decodable {
    var topAlbums: [Album]
    
    enum CodingKeys: String, CodingKey {
        case topAlbums = "loved"
    }
}


struct AlbumTracksRoot: Decodable {
    let albumTracks: [Album]
    
    enum CodingKeys: String,  CodingKey {
        case albumTracks = "track"
    }
}

struct AlbumWTitleRoot: Decodable {
    let album: [Album]
}


struct Album: Codable {
    var strArtist, strTrack: String
    var strDuration: String
    
    var strAlbum: String
    var idAlbum, idArtist: String
    var strAlbumThumb: String
    var intYearReleased: String
    
    private enum CodingKeys: String, CodingKey {
        case strArtist
        case strTrack
        case strDuration = "intDuration"
        
        case idAlbum
        case idArtist
        case strAlbum
        case strAlbumThumb
        case intYearReleased
        
    }
    
    init(from decoder: Decoder) throws {
        let coverPlaceholder = "https://biturl.top/y6fMje"
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        strArtist = try container.decode(String.self, forKey: .strArtist)
        strTrack = (try container.decodeIfPresent(String.self, forKey: .strTrack)) ?? "NA"
        strDuration = (try container.decodeIfPresent(String.self, forKey: .strDuration)) ?? "NA"
        intYearReleased = (try container.decodeIfPresent(String.self, forKey: .intYearReleased)) ?? "NA"
        idAlbum = try container.decode(String.self, forKey: .idAlbum)
        idArtist = try container.decode(String.self, forKey: .idArtist)
        strAlbum = try container.decode(String.self, forKey: .strAlbum)
        strAlbumThumb = (try container.decodeIfPresent(String.self, forKey: .strAlbumThumb)) ?? coverPlaceholder
    }
}







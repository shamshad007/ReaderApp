//
//  URLS.swift
//  ReaderApp
//
//  Created by Md Shamshad Akhtar on 12/09/25.
//

import Foundation

struct AppURL {
    
    static var getNews: URL {
        return URL(string: "https://newsapi.org/v2/everything?domains=wsj.com&apiKey=eef3efe1cabb427f8f77f148bc2d3da1") ?? URL(fileURLWithPath: "")
    }
    
}

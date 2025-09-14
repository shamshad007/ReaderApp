//
//  NewsModels.swift
//  ReaderApp
//
//  Created by Md Shamshad Akhtar on 13/09/25.
//

import Foundation

struct NewsModels: Codable {
    let status: String?
    let articles: [Articles]?
    
    init(status: String?, articles: [Articles]?) {
        self.status = status
        self.articles = articles
    }
}

struct Articles: Codable {
    var id: UUID?
    let source: Source?
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
    let content: String?
    
    init(id: UUID? = nil, source: Source? = nil, author: String? = "", title: String? = "", description: String? = "", url: String? = "", urlToImage: String? = "", publishedAt: String? = "", content: String? = "") {
        self.id = id
        self.source = source
        self.author = author
        self.title = title
        self.description = description
        self.url = url
        self.urlToImage = urlToImage
        self.publishedAt = publishedAt
        self.content = content
    }
}


struct Source: Codable {
    let id: String?
    let name: String?
    
    init(id: String?, name: String?) {
        self.id = id
        self.name = name
    }
}

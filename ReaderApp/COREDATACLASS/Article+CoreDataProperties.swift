//
//  Article+CoreDataProperties.swift
//  ReaderApp
//
//  Created by Md Shamshad Akhtar on 14/09/25.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var title: String?
    @NSManaged public var descriptions: String?
    @NSManaged public var thumbnail: String?
    @NSManaged public var author: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var isBookmarked: Bool
    @NSManaged public var url: String?

}

extension Article : Identifiable {

}

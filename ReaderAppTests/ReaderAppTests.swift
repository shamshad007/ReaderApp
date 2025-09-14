//
//  ReaderAppTests.swift
//  ReaderAppTests
//
//  Created by Md Shamshad Akhtar on 14/09/25.
//

import XCTest
@testable import ReaderApp

class HomeViewControllerTests: XCTestCase {
    var homeVC: HomeViewController!

    override func setUp() {
        super.setUp()
        homeVC = HomeViewController()
        let sampleArticle = Articles(author: "Author", title: "Test Title")
        homeVC.filteredArray = [sampleArticle]
        homeVC.newsResponse = [sampleArticle]
    }

    func testSearchRecordsWithMatchingTitle() {
        let searchField = UITextField()
        searchField.text = "Test"
        homeVC.searchRecords(searchField)
        XCTAssertEqual(homeVC.newsResponse.count, 1)
        XCTAssertEqual(homeVC.newsResponse.first?.title, "Test Title")
    }

    func testSearchRecordsWithEmptySearch() {
        let searchField = UITextField()
        searchField.text = ""
        homeVC.searchRecords(searchField)
        XCTAssertEqual(homeVC.newsResponse.count, 1)
    }
}

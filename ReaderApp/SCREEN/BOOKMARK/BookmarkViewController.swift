//
//  BookmarkViewController.swift
//  ReaderApp
//
//  Created by Md Shamshad Akhtar on 13/09/25.
//

import UIKit
import CoreData

class BookmarkViewController: BaseViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var tblViewBookmark: UITableView!
    
    //MARK: Variable and Contant
    var newsResponse = [Articles]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tblViewBookmark.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showLocalData()
    }
    
    //MARK: Retrieve bookmark data from local storage
    func showLocalData() {
        // Fetch saved articles from Core Data
        let fetchedArticles = fetchBookmarkedArticles() // returns [Article]
        
        // Clear current newsResponse to avoid duplicates
        newsResponse.removeAll()
        
        // Map Core Data fetched Articles into your newsResponse model
        for article in fetchedArticles {
            var newsItem = Articles()  // Replace with your actual news model
            newsItem.author = article.author ?? ""
            newsItem.title = article.title ?? ""
            newsItem.urlToImage = article.thumbnail ?? ""
            newsItem.publishedAt = article.publishedAt ?? ""
            newsItem.url = article.url ?? ""
            newsResponse.append(newsItem)
        }
        // Reload table view on main thread
        DispatchQueue.main.async {
            self.tblViewBookmark.reloadData()
        }
    }
    
    //MARK: Fetch only bookmarked data
    func fetchBookmarkedArticles() -> [Article] {
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isBookmarked == true")
        
        do {
            let bookmarkedArticles = try context.fetch(fetchRequest)
            return bookmarkedArticles
        } catch {
            print("Failed to fetch bookmarked articles: \(error)")
            return []
        }
    }
}

//MARK: - Table View DataSource
extension BookmarkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell
        let responseData = newsResponse[indexPath.row]
        
        cell?.lblAuthor.text = responseData.author ?? ""
        cell?.lblTitle.text = responseData.title ?? ""
        cell?.lblDates.text = String((responseData.publishedAt ?? "").prefix(10))
        if let thumbnailImage = responseData.urlToImage {
            cell?.imgThumbnail.sd_setImage(with: URL(string: thumbnailImage), placeholderImage: UIImage.gif(name: "Spinner"), context: .none)
            cell?.thumbnailHeight.constant = 200
            cell?.stackView.spacing = 15
        } else {
            cell?.thumbnailHeight.constant = 0
            cell?.stackView.spacing = 05
        }
        self.shadowOnUIView(name: cell?.cardView ?? UIView())
        return cell ?? UITableViewCell()
    }
}

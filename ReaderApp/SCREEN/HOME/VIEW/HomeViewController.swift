//
//  HomeViewController.swift
//  ReaderApp
//
//  Created by Md Shamshad Akhtar on 12/09/25.
//

import UIKit
import Combine
import SDWebImage
import CoreData

class HomeViewController: BaseViewController, UITextFieldDelegate {
    
    //MARK: IBOutlet
    @IBOutlet weak var tblViewHome: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewSearch: UIView!
    
    //MARK: View Model Object
    var newsViewModel: NewsViewModel = .init()
    var cancellable: Set<AnyCancellable> = .init()
    
    //MARK: Variable and Constant Declaration
    var newsResponse = [Articles]()
    var filteredArray = [Articles]()
    let refreshControl = UIRefreshControl()
    let networkChecker = NetworkChecker()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tblViewHome.dataSource = self
        self.showLoader(text: "Loading...")
        self.newsViewModel.fetchNewsListDetails()
        self.subscribeToNewsListDetails()
        self.showLocalData()
        self.setupUI()
        self.checkInternetConnection()
    }
    
    //MARK: Retrieve data from core data and show it offline
    func showLocalData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Fetch saved articles from Core Data
        let fetchedArticles = fetchAllArticles(context: context) // returns [Article]
        
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
        self.filteredArray = self.newsResponse
        // Reload table view on main thread
        DispatchQueue.main.async {
            self.tblViewHome.reloadData()
        }
    }
    
    //MARK: Pull to refresh
    @objc private func refreshData(_ sender: Any) {
        // Fetch new data
        fetchData { [weak self] in
            DispatchQueue.main.async {
                self?.tblViewHome.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }
    
    private func fetchData(completion: @escaping () -> Void) {
        // Your data fetching logic here
        self.newsViewModel.fetchNewsListDetails()
        completion()
    }
    
    //MARK: Setup UI
    func setupUI(){
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = .systemBlue
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        
        // Add to tableview
        tblViewHome.refreshControl = refreshControl
        self.viewSearch.layer.cornerRadius = 10
        self.viewSearch.layer.borderWidth = 1
        self.viewSearch.layer.borderColor = UIColor.black.cgColor
        
        txtSearch.delegate = self
        txtSearch.addTarget(self, action: #selector(searchRecords(_ :)), for: .editingChanged)
    }
    
    //MARK: TextField Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        return true
    }
    
    //MARK: Search Record from the list
    @objc func searchRecords(_ textField: UITextField) {
        newsResponse.removeAll()

        guard let searchText = textField.text?.lowercased(), !searchText.isEmpty else {
            newsResponse = filteredArray
            DispatchQueue.main.async {
                self.tblViewHome?.reloadData()
            }
            return
        }

        for list in filteredArray {
            if let title = list.title?.lowercased(), title.contains(searchText) {
                newsResponse.append(list)
            }
        }

        DispatchQueue.main.async {
            self.tblViewHome?.reloadData()
        }
    }

    
    //MARK: Bookmark the Article
    @objc func bookmarksTapped(_ sender: UIButton) {
        let article: Articles = newsResponse[sender.tag]
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.bookmarkNewsArticle(url: article.url ?? "", context: context)
        self.showAlertWithTextAtController(vc: self, title: "News article saved to bookmarks", message: "")
    }
}

//MARK: - Table View Data Sources
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as? HomeTableViewCell
        let responseData = newsResponse[indexPath.row]
        
        cell?.lblAuthor.text = responseData.author ?? ""
        cell?.lblTitle.text = responseData.title ?? ""
        cell?.lblDates.text = String((responseData.publishedAt ?? "").prefix(10))
        
        if let thumbnailImage = responseData.urlToImage, thumbnailImage != "" {
            cell?.imgThumbnail.sd_setImage(with: URL(string: thumbnailImage), placeholderImage: UIImage.gif(name: "Spinner"), context: .none)
            cell?.thumbnailHeight.constant = 200
            cell?.stackView.spacing = 15
        } else {
            cell?.thumbnailHeight.constant = 0
            cell?.stackView.spacing = 05
        }
        self.shadowOnUIView(name: cell?.cardView ?? UIView())
        cell?.btnBookmark.tag = indexPath.row
        cell?.btnBookmark.addTarget(self, action: #selector(bookmarksTapped(_:)), for: .touchUpInside)
        return cell ?? UITableViewCell()
    }
}

//MARK: - Get Article from API's
extension HomeViewController {
    // get News List Details response
    func subscribeToNewsListDetails() {
        self.newsViewModel.$newsResponse.sink { [weak self] responseData in
            guard self != nil else {return}
            if let response = responseData {
                debugPrint("News data: \(response)")
                self?.newsResponse = response.articles ?? []
                self?.filteredArray = self?.newsResponse ?? []
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                self?.saveArticle(self?.newsResponse ?? [], context: context)
                DispatchQueue.main.async {
                    self?.tblViewHome.reloadData()
                }
            }
            self?.hideLoader()
        }
        .store(in: &self.cancellable)
    }
}

//MARK: - Save and Fetch Data from Local Storage
extension HomeViewController {
    //Save new and existing data
    func saveArticle(_ articles: [Articles], context: NSManagedObjectContext) {
        for item in articles {
            if let existingArticle = fetchArticle(by: item.url ?? "", context: context) {
                // Update existing article
                existingArticle.url = item.url
                existingArticle.title = item.title
                existingArticle.author = item.author
                existingArticle.thumbnail = item.urlToImage
                existingArticle.publishedAt = item.publishedAt
            } else {
                // Create new article
                let newArticle = Article(context: context)
                newArticle.url = item.url
                newArticle.title = item.title
                newArticle.author = item.author
                newArticle.thumbnail = item.urlToImage
                newArticle.publishedAt = item.publishedAt
            }
        }
        do {
            try context.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
    
    //Fetch All List
    func fetchAllArticles(context: NSManagedObjectContext) -> [Article] {
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Fetch all error: \(error)")
            return []
        }
    }
    
    //Fetch List by URL
    func fetchArticle(by url: String, context: NSManagedObjectContext) -> Article? {
        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url == %@", url)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Fetch error: \(error)")
            return nil
        }
    }
    
    // Save Article to Bookmarks
    func bookmarkNewsArticle(url: String, context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        fetchRequest.predicate = NSPredicate(format: "url == %@", url)
        do {
            if let results = try context.fetch(fetchRequest) as? [NSManagedObject], let article = results.first {
                article.setValue(true, forKey: "isBookmarked")
                try context.save()
            }
        } catch {
            print("Failed to bookmark news article: \(error)")
        }
    }
}


//MARK: - Check Internet Connection
extension HomeViewController {
    func checkInternetConnection() {
        networkChecker.onStatusChange = { [weak self] isAvailable in
            if !isAvailable {
                self?.showAlertWithTextAtController(vc: self ?? UIViewController(), title: "❌ No internet connection", message: "")
            }
        }
        networkChecker.startMonitoring()
    }
}

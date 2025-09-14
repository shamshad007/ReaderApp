//
//  NewsViewModel.swift
//  ReaderApp
//
//  Created by Md Shamshad Akhtar on 13/09/25.
//

import Foundation
import Combine

final class NewsViewModel: ObservableObject {
    
    // MARK: - Variables and Constants
    var cancellables = Set<AnyCancellable>()
    var authentication_error = PassthroughSubject<ApiError, Never>()
    @Published var newsResponse: NewsModels?
    
    // MARK: -  Fetch News List and Details
    func fetchNewsListDetails() {
        let webserviceURL = AppURL.getNews
        
        NetworkManager.shared.getData(endpoint: webserviceURL, apiMethod: Endpoint.GET, parameters: nil, type: NewsModels.self)
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .sink { completion in
                switch completion {
                case .finished:
                    print("sucessfully fetch News List data")
                case .failure(let err):
                    print("News List Screen Error", err.localizedDescription)
                    self.authentication_error.send(ApiError(title: "Error", description: err.localizedDescription, code: err.code))
                }
            }
        receiveValue: { [weak self] responseData in
            self?.newsResponse = responseData
        }
        .store(in: &self.cancellables)
    }
}



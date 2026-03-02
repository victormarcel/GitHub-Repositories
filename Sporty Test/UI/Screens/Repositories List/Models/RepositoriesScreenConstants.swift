//
//  Constants.swift
//  Sporty Test
//
//  Created by Victor Marcel on 01/03/26.
//

extension RepositoriesViewController {
    
    enum Constants {
        
        static let pullToRefreshErrorDescription = "Couldn't refresh repositories. Please try again."
        
        enum ViewController {
            static let title = "Repositories"
        }
        
        enum TableView {
            static let numberOfSections = 1
        }
        
        enum FeedbackView {
            static let errorStateData = FeedbackViewData(
                imageName: "wifi.slash",
                title: "Couldn't Load Repositories",
                description: "Something went wrong on our end. Please try again later."
            )
            
            static let emptyStateData = FeedbackViewData(
                imageName: "tray",
                title: "No Repositories Found",
                description: "We couldn't find any repositories matching your search. Try different keywords."
            )
            
            static let unauthorizedStateData = FeedbackViewData(
                imageName: "lock.shield",
                title: "Access Denied",
                description: "Your API key is invalid or expired. Please update it and try again."
            )
        }
    }
}

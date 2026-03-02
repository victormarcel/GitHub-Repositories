import GitHubAPI
import SwiftUI
import UIKit

/// A view displaying the details of a GitHub repository.
struct RepositoryView: View {
    let minimalRepository: GitHubMinimalRepository
    let gitHubAPI: GitHubAPI

    @State private var fullRepository: GitHubFullRepository?

    var body: some View {
        List {
            Group {
                RepositoryValueView(key: "Name") {
                    Text(minimalRepository.name)
                        .foregroundColor(.secondary)
                }

                RepositoryValueView(key: "Description") {
                    if let description = minimalRepository.description {
                        Text(description)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No description")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }

                RepositoryValueView(key: "Stars") {
                    Text("\(minimalRepository.stargazersCount)")
                        .foregroundColor(.secondary)
                }

                RepositoryValueView(key: "Forks") {
                    if let fullRepository {
                        Text("\(fullRepository.networkCount)")
                            .foregroundColor(.secondary)
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .task {
            do  {
                fullRepository = try await gitHubAPI.repository(minimalRepository.fullName)
            } catch {
                print("Error loading full repository: \(error)")
            }
        }
    }
}

private struct RepositoryValueView<Value: View>: View {
    let key: String
    let value: Value

    var body: some View {
        VStack(alignment: .leading) {
            Text(key)
                .font(.headline)
            value
        }
    }

    init(key: String, @ViewBuilder value: () -> Value) {
        self.key = key
        self.value = value()
    }
}

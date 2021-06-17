import Foundation
import UIKit

class ImageLoader {
    private let decodingQueue = DispatchQueue(label: "com.tink.TinkMoneyManagerUI.ImageLoader.Decoding", qos: .utility)

    static let shared = ImageLoader()

    class ImageLoadingTaskManager {
        struct Handle: Hashable {
            private let id: UUID
            private let cancellationHandler: (Handle) -> Void

            fileprivate init(cancellationHandler: @escaping (Handle) -> Void) {
                self.id = UUID()
                self.cancellationHandler = cancellationHandler
            }

            func cancel() {
                cancellationHandler(self)
            }

            static func == (lhs: Self, rhs: Self) -> Bool {
                return lhs.id == rhs.id
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
        }

        private var completionHandlers: [Handle: (Result<UIImage, Error>) -> Void] = [:]

        fileprivate var task: URLSessionDataTask?

        fileprivate init() {}

        fileprivate func addCompletionHandler(_ completion: @escaping (Result<UIImage, Error>) -> Void) -> Handle {
            let handle = Handle { [weak self] handle in
                self?.removeCompletionHandler(for: handle)
            }
            completionHandlers[handle] = completion
            return handle
        }

        private func removeCompletionHandler(for token: Handle) {
            completionHandlers.removeValue(forKey: token)
            if completionHandlers.isEmpty {
                cancel()
            }
        }

        fileprivate func complete(with result: Result<UIImage, Error>) {
            for (_, observer) in completionHandlers {
                observer(result)
            }
            completionHandlers.removeAll()
        }

        private func cancel() {
            task?.cancel()
        }
    }

    private enum State {
        case loading(ImageLoadingTaskManager)
        case loaded(Result<UIImage, Error>)
    }

    private var imageLoadingStateByUrl: [URL: State] = [:]

    @discardableResult
    func loadImage(at url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> ImageLoadingTaskManager.Handle? {
        switch imageLoadingStateByUrl[url] {
        case .loading(let handler):
            let handle = handler.addCompletionHandler(completion)
            return handle
        case .loaded(let result):
            completion(result)
            switch result {
            case .success: return nil
            case .failure:
                return addImageLadingTask(with: url, completion)
            }
        case .none:
            return addImageLadingTask(with: url, completion)
        }
    }

    private func addImageLadingTask(with url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> ImageLoader.ImageLoadingTaskManager.Handle? {
        let taskManager = ImageLoadingTaskManager()
        let handle = taskManager.addCompletionHandler(completion)

        taskManager.task = fetchImage(with: url) { [weak self] result in
            DispatchQueue.main.async {
                taskManager.complete(with: result)
                self?.imageLoadingStateByUrl[url] = .loaded(result)
            }
        }

        imageLoadingStateByUrl[url] = .loading(taskManager)

        return handle
    }

    private func fetchImage(with url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { [decodingQueue] data, response, error in
            if let data = data {
                decodingQueue.async {
                    if let image = UIImage(data: data) {
                        completion(.success(image))
                    } else {
                        completion(.failure(CocoaError(.coderReadCorrupt)))
                    }
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(URLError(.unknown)))
            }
        }
        task.resume()
        return task
    }
}

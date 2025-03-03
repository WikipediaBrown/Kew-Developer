//
//  Network Manager.swift
//  Xcode Extension
//
//  Created by nonplus on 2/28/25.
//

import Network
import AppKit
import Combine
import OSLog

/// The public API for the NetworkingManagerManager.
protocol NetworkingManaging {
    // MARK: - Declare properties and methods needed to access the manager.
    func request<T: Decodable>(for endPoint: EndPoint, decoder: JSONDecoder?, idempotencyKey: UUID?) -> AnyPublisher<T, Error>
    func request<T: Decodable, E: Encodable>(for endPoint: EndPoint, body: E?, decoder: JSONDecoder?, idempotencyKey: UUID?) -> AnyPublisher<T, Error>
}

class NetworkingManager: NSObject, NetworkingManaging {
    
    // MARK: - Initialization
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
        super.init()
        
        /// Setup Netowrk Status Passthrough Subject
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.networkStatus.send(path.status)
        }
        networkMonitor.start(queue: dispatchQueue)
    }
    
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let decoder: JSONDecoder
    private let dispatchQueue = DispatchQueue(label: LocalConstants.networkQueueLabel)
    private let networkMonitor = NWPathMonitor()
    private let networkStatus = PassthroughSubject<NWPath.Status, Never>()
    private let delegateQueue = OperationQueue()
    private let logger = Logger(forComponent: "Authentication", andCategory: #fileID)
    private lazy var session = URLSession(configuration: .default, delegate: self, delegateQueue: delegateQueue)
    
    
    // MARK: - Public Methods
    
    /// This method returns the publisher with the coresponding type decoded from the request enpoint.
    /// - Parameters:
    ///   - endPoint: `Endpoint` object corresponding to the URL to connect to.
    ///   - decoder: The object used to decode the returned `JSON`.
    ///   - idempotencyKey: The `idempotencyKey` is a key that is used to prevent this operation from being performed more than once.
    /// - Returns: `AnyPublisher` that publishes type corresponding to the `Decodable` generic.
    func request<T: Decodable>(for endPoint: EndPoint, decoder: JSONDecoder? = nil, idempotencyKey: UUID?) -> AnyPublisher<T, Error> {
        dataPublisher(for: endPoint, idempotencyKey: idempotencyKey)
            .tryMap { [weak self] data in
                guard let self = self
                else { throw WeakReferenceError.selfDeallocated }
                return try self.decode(data: data, decoder: decoder)
            }
            .eraseToAnyPublisher()
    }
    
    /// This method returns the publisher with the coresponding type decoded from the request enpoint and body.
    /// - Parameters:
    ///   - endPoint: `Endpoint` object corresponding to the URL to connect to.
    ///   - body: The body object of the request.
    ///   - decoder: The object used to decode the returned `JSON`.
    ///   - idempotencyKey: The `idempotencyKey` is a key that is used to prevent this operation from being performed more than once.
    /// - Returns: `AnyPublisher` that publishes type corresponding to the `Decodable` generic.
    func request<E: Encodable, T: Decodable>(for endPoint: EndPoint, body: E, decoder: JSONDecoder? = nil, idempotencyKey: UUID?) -> AnyPublisher<T, Error> {
        dataPublisher(for: endPoint, body: body, idempotencyKey: idempotencyKey)
            .tryMap { [weak self] data in
                guard let self = self
                else { throw WeakReferenceError.selfDeallocated }
                return try self.decode(data: data, decoder: decoder)
            }
            .eraseToAnyPublisher()
    }
    
    /// This method returns a `Data` publisher for an `Endpoint`.
    /// - Parameters:
    ///   - endPoint: `Endpoint` object corresponding to the URL to connect to.
    ///   - idempotencyKey: The `idempotencyKey` is a key that is used to prevent this operation from being performed more than once.
    /// - Returns: Returns a type erased publisher for the data returned from the `Enpoint`.
    private func dataPublisher(for endPoint: EndPoint, idempotencyKey: UUID?)  -> AnyPublisher<Data, Error> {
        var delay = 1
        return dataTaskPublisher(for: endPoint, idempotencyKey: idempotencyKey)
            .tryMap(HTTPResponseCode.checkResponseCodeWithRetries)
            .catch { error -> AnyPublisher<DataTaskResult, Error> in
                switch error as? NetworkingError {
                case .networkErrorResponse(_) : // `HTTPResponseCode.checkResponseCodeWithRetries` returned an error that is retryable.
                    delay += delay
                    let jutter = Int.random(in: 0...(delay / 4))
                    return Fail(error: error)
                        .delay(for: .milliseconds(delay + jutter), scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                default: // Handle Result Normally
                    return Just(.failure(error))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .retry(ConfigurationService.maxRetries)
            .tryMap { try $0.get() }
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    /// This method returns a `Data` publisher for an `Endpoint` and an `Encodable` body.
    /// - Parameters:
    ///   - endPoint: `Endpoint` object corresponding to the URL to connect to.
    ///   - body: The body object of the request.
    ///   - idempotencyKey: The `idempotencyKey` is a key that is used to prevent this operation from being performed more than once.
    /// - Returns: Returns a type erased publisher for the data returned from the `Enpoint`.
    private func dataPublisher<E: Encodable>(for endPoint: EndPoint, body: E, idempotencyKey: UUID?)  -> AnyPublisher<Data, Error> {
        var delay = 1
        return dataTaskPublisher(for: endPoint, body: body, idempotencyKey: idempotencyKey)
            .tryMap(HTTPResponseCode.checkResponseCodeWithRetries)
            .catch { error -> AnyPublisher<DataTaskResult, Error> in
                switch error as? NetworkingError {
                case .networkErrorResponse(_) : // `HTTPResponseCode.checkResponseCodeWithRetries` returned an error that is retryable.
                    delay += delay
                    let jutter = Int.random(in: 0...(delay / 4))
                    return Fail(error: error)
                        .delay(for: .milliseconds(delay + jutter), scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                default: // Handle Result Normally
                    return Just(.failure(error))
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .retry(ConfigurationService.maxRetries)
            .tryMap { try $0.get() }
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    /// This mehtod returns a `DataTaskPublisher` type erased to it's `AnyPublisher` version using an `Endpoint`.
    /// - Parameters:
    ///   - endPoint: `Endpoint` object corresponding to the URL to connect to.
    ///   - idempotencyKey: The `idempotencyKey` is a key that is used to prevent this operation from being performed more than once.
    /// - Returns: An `AnyPublisher` that publishes the result of the data task request.
    private func dataTaskPublisher(for endPoint: EndPoint, idempotencyKey: UUID?) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        let request = createRequest(endPoint: endPoint, idempotencyKey: idempotencyKey)
        return session.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
    
    /// This mehtod returns a `DataTaskPublisher` type erased to it's `AnyPublisher` version using an `Endpoint` and body object.
    /// - Parameters:
    ///   - endPoint: `Endpoint` object corresponding to the URL to connect to.
    ///   - body: The body object of the request.
    ///   - idempotencyKey: The `idempotencyKey` is a key that is used to prevent this operation from being performed more than once.
    /// - Returns: An `AnyPublisher` that publishes the result of the data task request.
    private func dataTaskPublisher<E: Encodable>(for endPoint: EndPoint, body: E, idempotencyKey: UUID?) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        let request = createRequest(endPoint: endPoint, body: body, idempotencyKey: idempotencyKey)
        return session.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
    
    /// This method creates and returens a `URLRequest` object.
    /// - Parameters:
    ///   - idToken: The Authorization token for the request. This identifies the user to the server securely.
    ///   - endPoint: The `Endpoint` that the request should be made to.
    ///   - body: The `JSONEncodable`object that is sent in the `httpBody` property of the `URLRequest`.
    ///   - idempotencyKey: The `idempotencyKey` is a key that is used to prevent this operation from being performed more than once.
    /// - Returns: The created `URLRequest` object.
    private func createRequest<E: Encodable>(idToken: String? = nil, endPoint: EndPoint, body: E, idempotencyKey: UUID?) -> URLRequest {
        var request = createRequest(idToken: idToken, endPoint: endPoint, idempotencyKey: idempotencyKey)
        
        switch endPoint.method {
        case .put, .post, .patch: request.httpBody = try? JSONEncoder().encode(body)
        default: break
        }
        logger.trace("Creating request to URL: \(endPoint.url).")
        return request
    }
    
    /// This method creates and returens a `URLRequest` object.
    /// - Parameters:
    ///   - idToken: The Authorization token for the request. This identifies the user to the server securely.
    ///   - endPoint: The `Endpoint` that the request should be made to.
    ///   - idempotencyKey: The `idempotencyKey` is a key that is used to prevent this operation from being performed more than once.
    /// - Returns: The created `URLRequest` object.
    private func createRequest(idToken: String? = nil, endPoint: EndPoint, idempotencyKey: UUID?) -> URLRequest {
        var request = URLRequest(url: endPoint.url)
        request.httpMethod = endPoint.method.rawValue
        if let token = idToken {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        let uuid = idempotencyKey ?? UUID()
        request.setValue(uuid.uuidString, forHTTPHeaderField: "Idempotency-Key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /// This method decodes a `JSON` object, either with a provided `JSONDecoder` or with the default decoder. If either decoder is a `CoreDataJSONDecoder` and the `save` flag is set to true, the method will use the decoder to save the decoded result to `CoreData`.
    /// - Parameters:
    ///   - data: `JSON` data to be decoded.
    ///   - decoder: `JSONDecoder` to be used for this specific decode.
    ///   - save: A flag that determines if the decoded result is saved to `CoreData`.
    /// - Returns: This method returns the decoded type equalt to the generic type `T`.
    private func decode<T: Decodable>(data: Data, decoder: JSONDecoder?) throws -> T {
        let decoder = decoder ?? self.decoder
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - Local Constants
    
    /// These are the constants used by the manager.
    enum LocalConstants {
        static let networkQueueLabel = "com.hellanillas.Kew-Developer.NetworkMonitor"
    }
}

// MARK: - URLSessionDelegate

extension NetworkingManager: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        //    DispatchQueue.main.async {
        //      if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        //        let completionHandler = appDelegate.backgroundSessionCompletionHandler {
        //        appDelegate.backgroundSessionCompletionHandler = nil
        //
        //        completionHandler()
        //      }
        //    }
    }
}

enum NetworkAddresses: String {
    case chatGPTFeature = "http://localhost:3000/api/ChatGPT/4o/dev"
    
    
}

actor NetworkingService {
    
    func request<T: Decodable>() async throws -> T {
        let url = URL(string: "http://localhost:3000/api/ChatGPT/4o/dev")!

        var urlRequest = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
//    func requ/*est<E: Encodable, T: Decodable>(for endPoint: EndPoint, body: E, decoder: JSONDecoder? = nil, idempotencyKey: UUID?) -> T {}*/

}

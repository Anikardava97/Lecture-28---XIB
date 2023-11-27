//
//  NetworkManager.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import UIKit

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - Fetch Products
    func fetchProducts(completion: @escaping (Result<[ProductModel], Error>) -> Void) {
        let urlStr = "https://dummyjson.com/products"
        
        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NSError(domain: "HTTPError", code: httpResponse.statusCode, userInfo: nil)))
                return
            }

            guard let data else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let productsResponse = try JSONDecoder().decode(ProductResponseModel.self, from: data)
                completion(.success(productsResponse.products))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Download Image
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data, error == nil,
                let image = UIImage(data: data)
            else {
                completion(nil)
                return
            }
            
            completion(image)
        }.resume()
    }
}




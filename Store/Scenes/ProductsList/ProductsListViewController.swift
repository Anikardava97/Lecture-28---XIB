//
//  ProductsListViewController.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import UIKit

class ProductsListViewController: UIViewController {
    
    private let productsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .purple
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.style = .large
        indicator.color = .white
        return indicator
    }()
    
    private let totalPriceLbl: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "total: 0$"
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    var products = [ProductModel]()
    private let productsViewModel = ProductsListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupProductsViewModel()
        activityIndicator.startAnimating()
        productsViewModel.viewDidLoad()
    }
    
    //MARK: setup UI
    func setupUI() {
        view.backgroundColor = .orange
        setupTableView()
        setupIndicator()
        setupTotalPriceLbl()
    }
    
    func setupTableView() {
        view.addSubview(productsTableView)
        
        NSLayoutConstraint.activate([
            productsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            productsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            productsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            productsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        productsTableView.register(UINib(nibName: "ProductCell", bundle: nil), forCellReuseIdentifier: "ProductCell")
        productsTableView.dataSource = self
        productsTableView.delegate = self
    }
    
    func setupIndicator() {
        
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupTotalPriceLbl() {
        view.addSubview(totalPriceLbl)
        
        NSLayoutConstraint.activate([
            totalPriceLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            totalPriceLbl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            totalPriceLbl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: Setup delegates
    private func setupProductsViewModel() {
        productsViewModel.delegate = self
    }
}

extension ProductsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
                as? ProductCell else {
            fatalError("Could not dequeue cell with identifier: productCell")
        }
        cell.reload(with: products[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension ProductsListViewController: ProductsListViewModelDelegate {
    
    func showError(_ receivedError: Error) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            let alert = UIAlertController(title: "Error", message: receivedError.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func productsFetched(_ products: [ProductModel]) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.products = products
            self.productsViewModel.products = products
            self.productsTableView.reloadData()
        }
    }
    
    func productsAmountChanged() {
        totalPriceLbl.text = "Total price: \(productsViewModel.totalPrice ?? 0)"
    }
}

extension ProductsListViewController: ProductCellDelegate {
    
    func removeProduct(for cell: ProductCell) {
        if let indexPath = productsTableView.indexPath(for: cell) {
            productsViewModel.removeProduct(at: indexPath.row)
            
            if let updatedInfo = productsViewModel.products?[indexPath.row] {
                cell.updateQuantityAndStockLabel(with: updatedInfo)
            }
        }
    }
    
    func addProduct(for cell: ProductCell) {
        if let indexPath = productsTableView.indexPath(for: cell) {
            productsViewModel.addProduct(at: indexPath.row)
            
            if let updatedInfo = productsViewModel.products?[indexPath.row] {
                cell.updateQuantityAndStockLabel(with: updatedInfo)
            }
        }
    }
}


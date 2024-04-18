//
//  PokemonListViewController.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/25.
//

import UIKit

class PokemonListViewController: UIViewController {
    @IBOutlet weak var favoriteSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var styleSegmentedControl: UISegmentedControl!
    private let emptyFavoriteView = EmptyFavoriteView()
    private let viewModel = PokemonListViewModel(apiService: APIService.shared)
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pokédex"
        initTableView()
        initCollectionView()
        initEmptyFavoriteView()
        binding()
        viewModel.loadPokemons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.checkFavoriteStatus()
    }
    
    // MARK: - Private Methods
    private func binding() {
        viewModel.didLoadPokemons = { [weak self] in
            self?.tableView.reloadData()
            self?.collectionView.reloadData()
        }
        
        viewModel.loadingStatus = { [weak self] isLoading in
            if isLoading {
                self?.showLoadingIndicator()
            } else {
                self?.hideLoadingIndicator()
            }
        }
        
        viewModel.favoriteStatus = { [weak self] in
            self?.tableView.reloadData()
            self?.collectionView.reloadData()
        }
        
        viewModel.displayStatus = { [weak self] style in
            switch style {
            case.List:
                self?.tableView.isHidden = false
                self?.collectionView.isHidden = true
            case.Grid:
                self?.tableView.isHidden = true
                self?.collectionView.isHidden = false
            }
        }
        
        viewModel.emptyFavoriteStatus = { [weak self] isEmpty in
            self?.emptyFavoriteView.isHidden = !isEmpty
        }
        
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(UINib(nibName: "PokedexTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.TableViewCell.pokedexCell)
    }
    
    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(UINib(nibName: Constants.CollectionViewCell.pokedexCell, bundle: nil), forCellWithReuseIdentifier: "PokedexCollectionViewCell")
    }
    
    private func initEmptyFavoriteView() {
        view.addSubview(emptyFavoriteView)
        emptyFavoriteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyFavoriteView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyFavoriteView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyFavoriteView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyFavoriteView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        emptyFavoriteView.isHidden = true
    }
    
    private func showPokemonDetail(pokedex: Pokedex) {
        let pokemonDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PokemonDetailViewController") as! PokemonDetailViewController
        pokemonDetailViewController.pokemonURL = pokedex.pokemonURL
        navigationController?.pushViewController(pokemonDetailViewController, animated: true)
    }
    
    private func showLoadingIndicator() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = spinner
        tableView.tableFooterView?.isHidden = false
    }
    
    private func hideLoadingIndicator() {
        tableView.tableFooterView = nil
        tableView.tableFooterView?.isHidden = true
    }
    
    // MARK: - IBActions
    @IBAction func favoriteSwitchAction(_ sender: UISwitch) {
        viewModel.isFavoriteMode = sender.isOn
    }
    
    @IBAction func styleSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.displayStyle = sender.selectedSegmentIndex == 0 ? .List : .Grid
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PokemonListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCell.pokedexCell, for: indexPath) as! PokedexTableViewCell
        let pokedex = viewModel.getPokedexForCell(at: indexPath)
        cell.configure(with: pokedex)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPokemonDetail(pokedex: viewModel.getPokedexForDetail(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.loadMore(currentRow: indexPath.row)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PokemonListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCell.pokedexCell, for: indexPath) as! PokedexCollectionViewCell
        let pokedex = viewModel.getPokedexForCell(at: indexPath)
        cell.configure(with: pokedex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showPokemonDetail(pokedex: viewModel.getPokedexForDetail(at: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetch(indexPaths: indexPaths)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PokemonListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.width/2.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

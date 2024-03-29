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
    private let viewModel = PokemonListViewModel()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Pokédex"
        initTableView()
        initCollectionView()
        initEmptyFavoriteView()
        loadPokemons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if favoriteSwitch.isOn {
            tableView.reloadData()
            collectionView.reloadData()
            updateEmptyFavoriteView()
        }
    }
    
    // MARK: - Private Methods
    private func loadPokemons() {
        viewModel.loadPokemons { [weak self] in
            self?.tableView.reloadData()
            self?.collectionView.reloadData()
            self?.hideLoadingIndicator()
        }
    }
    
    private func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(UINib(nibName: "PokedexTableViewCell", bundle: nil), forCellReuseIdentifier: "PokedexTableViewCell")
    }
    
    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(UINib(nibName: "PokedexCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PokedexCollectionViewCell")
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
    
    private func updateEmptyFavoriteView() {
        emptyFavoriteView.isHidden = !(favoriteSwitch.isOn && viewModel.pokemonFavorite.isEmpty)
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
        tableView.reloadData()
        collectionView.reloadData()
        updateEmptyFavoriteView()
    }
    
    @IBAction func styleSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        tableView.isHidden = sender.selectedSegmentIndex == 1
        collectionView.isHidden = sender.selectedSegmentIndex == 0
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PokemonListViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokedexTableViewCell", for: indexPath) as! PokedexTableViewCell
        let pokedex = viewModel.getPokedexForCell(at: indexPath)
        cell.configure(with: pokedex)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPokemonDetail(pokedex: viewModel.getPokedexForDetail(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !favoriteSwitch.isOn && indexPath.row == viewModel.pokedex.count - 1 else { return }
        showLoadingIndicator()
        loadPokemons()
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PokemonListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokedexCollectionViewCell", for: indexPath) as! PokedexCollectionViewCell
        let pokedex = viewModel.getPokedexForCell(at: indexPath)
        cell.configure(with: pokedex)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showPokemonDetail(pokedex: viewModel.getPokedexForDetail(at: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard !favoriteSwitch.isOn else { return }
        let lastIndexPath = IndexPath(item: viewModel.pokedex.count - 1, section: 0)
        if indexPaths.contains(lastIndexPath) { loadPokemons()}
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

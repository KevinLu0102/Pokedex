//
//  PokemonDetailViewController.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/25.
//

import UIKit

class PokemonDetailViewController: UIViewController {
    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonIDLabel: UILabel!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var pokemonTypesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statsCollectionView: UICollectionView!
    @IBOutlet weak var statsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var evolutionsCollectionView: UICollectionView!
    @IBOutlet weak var evolutionsCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: UIButton!
    private var activityIndicator: UIActivityIndicatorView!
    private var loadingBackgroundView: UIView!
    private let viewModel = PokemonDetailViewModel()
    var pokemonURL = ""
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initStatsCollectionView()
        initEvolutionsCollectionView()
        initLoadingView()
        
        showLoadingIndicator()
        viewModel.loadPokemonDetail(url: pokemonURL) { [weak self] in
            self?.setDatailUI()
            self?.hideLoadingIndicator()
        }
    }
    
    // MARK: - Private Methods
    private func setDatailUI() {
        pokemonImageView.sd_setImage(with: viewModel.imageURL)
        pokemonIDLabel.text = viewModel.id
        pokemonNameLabel.text = viewModel.name
        pokemonTypesLabel.text = viewModel.types
        updateFavoriteStatus()
        statsCollectionView.reloadData()
        setStatsCollectionViewContentSizeHeight()
        descriptionLabel.text = viewModel.description
        evolutionsCollectionView.reloadData()
        setEvolutionCollectionViewContentSizeHeight()
    }
    
    private func initLoadingView() {
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        let loadingBackgroundFrame = CGRect(x: 0, y: navigationBarHeight,
                                            width: view.bounds.width,
                                            height: view.bounds.height - navigationBarHeight)
        loadingBackgroundView = UIView(frame: loadingBackgroundFrame)
        loadingBackgroundView.backgroundColor = .white
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.center = CGPoint(x: loadingBackgroundView.bounds.midX,
                                           y: loadingBackgroundView.bounds.midY)
        loadingBackgroundView.addSubview(activityIndicator)
    }
    
    private func showLoadingIndicator() {
        view.addSubview(loadingBackgroundView)
        activityIndicator.startAnimating()
    }
        
    private func hideLoadingIndicator() {
        loadingBackgroundView.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
    
    private func initEvolutionsCollectionView() {
        evolutionsCollectionView.register(UINib(nibName: "EvolutionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.CollectionViewCell.evolutionCell)
        evolutionsCollectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        evolutionsCollectionView.dataSource = self
        evolutionsCollectionView.delegate = self
        evolutionsCollectionView.isScrollEnabled = false
    }
    
    private func setEvolutionCollectionViewContentSizeHeight() {
        let contentHeight = evolutionsCollectionView.collectionViewLayout.collectionViewContentSize.height
        self.evolutionsCollectionViewHeight.constant = contentHeight
    }
    
    private func initStatsCollectionView() {
        statsCollectionView.register(UINib(nibName: "StatCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.CollectionViewCell.statCell)
        statsCollectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        statsCollectionView.dataSource = self
        statsCollectionView.delegate = self
        statsCollectionView.isScrollEnabled = false
    }
    
    private func setStatsCollectionViewContentSizeHeight() {
        let contentHeight = statsCollectionView.collectionViewLayout.collectionViewContentSize.height
        statsCollectionViewHeight.constant = contentHeight
    }
    
    private func updateFavoriteStatus() {
        let imageName = viewModel.isFavorite ? "star.fill" : "star"
        let image = UIImage(systemName: imageName)
        favoriteButton.setImage(image, for: .normal)
        favoriteButton.tintColor = viewModel.isFavorite ? .orange : .gray
    }
    
    // MARK: - IBActions
    @IBAction func favoriteAction(_ sender: UIButton) {
        viewModel.updateFavoriteData(pokemonURL: pokemonURL)
        updateFavoriteStatus()
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension PokemonDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == statsCollectionView {
             return viewModel.statsCount
         } else if collectionView == evolutionsCollectionView {
             return viewModel.evolutionSpecies.count
         }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == statsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCell.statCell, for: indexPath) as! StatCollectionViewCell
            if let stat = viewModel.getStat(index: indexPath.row) {
                let cellHeight = cell.contentView.bounds.height
                let statHeight = viewModel.getStatBackgroundHeight(for: stat, cellHeight: cellHeight)
                cell.configure(with: stat, statHeight: statHeight)
            }
            return cell
        } else if collectionView == evolutionsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionViewCell.evolutionCell, for: indexPath) as! EvolutionCollectionViewCell
            let isLastCell = (indexPath.item == collectionView.numberOfItems(inSection: indexPath.section) - 1)
            cell.configure(evolutionSpecies: viewModel.getEvolutionSpecies(index: indexPath.row), isLastCell: isLastCell)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == evolutionsCollectionView{
            let pokemonDetailViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PokemonDetailViewController") as! PokemonDetailViewController
            let originalURL = viewModel.evolutionSpecies[indexPath.row].url
            let modifiedURL = originalURL.replacingOccurrences(of: "pokemon-species", with: "pokemon")
            pokemonDetailViewController.pokemonURL = modifiedURL
            navigationController?.pushViewController(pokemonDetailViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as! HeaderView
            if collectionView == statsCollectionView {
                headerView.configure(with: "Stats")
            } else if collectionView == evolutionsCollectionView {
                headerView.configure(with: "Evolutions")
            }
            return headerView
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PokemonDetailViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.width/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

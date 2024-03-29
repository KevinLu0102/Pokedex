//
//  EvolutionCollectionViewCell.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/26.
//

import UIKit

class EvolutionCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(evolutionSpecies: NameURLPair, isLastCell: Bool) {
        nameLabel.text = evolutionSpecies.name
        arrowImageView.isHidden = isLastCell
    }

}

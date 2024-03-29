//
//  StatCollectionViewCell.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/26.
//

import UIKit

class StatCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var statValueLabel: UILabel!
    @IBOutlet weak var statNameLabel: UILabel!
    @IBOutlet weak var statBackgroundHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with stat: PokemonStat, statHeight: CGFloat) {
        statValueLabel.text = String(stat.baseStat)
        statNameLabel.text = stat.stat.name
        statBackgroundHeight.constant = statHeight
    }
}

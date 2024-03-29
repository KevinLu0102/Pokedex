//
//  PokedexTableViewCell.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/3/25.
//

import UIKit
import SDWebImage

class PokedexTableViewCell: UITableViewCell {
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typesLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    func configure(with pokemon: Pokedex) {
        idLabel.text = String(format: "#%04d", pokemon.id)
        nameLabel.text = pokemon.name
        
        let typeNames = pokemon.types.map { $0.type.name }
        typesLabel.text = typeNames.joined(separator: ", ")
        
        if let imageURL = URL(string: pokemon.imageURL.frontDefault) {
            thumbnailImageView.sd_setImage(with: imageURL)
        }
    }
}

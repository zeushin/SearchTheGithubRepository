//
//  SearchResultCell.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/22/24.
//

import UIKit

class SearchResultCell: UITableViewCell {

  @IBOutlet weak var thumbnailView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

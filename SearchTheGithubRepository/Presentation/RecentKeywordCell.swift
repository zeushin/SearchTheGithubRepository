//
//  RecentKeywordCell.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import UIKit

final class RecentKeywordCell: UITableViewCell {
  
  @IBOutlet weak var keywordLabel: UILabel!
  
  var onDelete: (() -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  @IBAction func deleteAction(_ sender: UIButton) {
    onDelete?()
  }
  
}

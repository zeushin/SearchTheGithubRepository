//
//  RemoveAllCell.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/21/24.
//

import UIKit

class RemoveAllCell: UITableViewCell {
  
  private let separatorView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray5
    return view
  }()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.addSubview(separatorView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    separatorView.frame = CGRect(
      x: 0, y: contentView.frame.height - 1,
      width: contentView.frame.width, height: 1
    )
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

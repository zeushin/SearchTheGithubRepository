//
//  HeaderView.swift
//  SearchTheGithubRepository
//
//  Created by Masher Shin on 9/23/24.
//

import UIKit

final class HeaderView: UIView {
  
  private let headerLabel = UILabel()
  
  init(title: String, textColor: UIColor?, margins: UIEdgeInsets) {
    super.init(frame: .zero)
    setupView(title: title, textColor: textColor, margins: margins)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  private func setupView(title: String, textColor: UIColor?, margins: UIEdgeInsets) {
    self.backgroundColor = .clear
    
    headerLabel.frame = CGRect(
      x: margins.left,
      y: 0,
      width: UIScreen.main.bounds.width - (margins.left + margins.right),
      height: 28
    )
    headerLabel.font = UIFont.boldSystemFont(ofSize: 14)
    headerLabel.text = title
    headerLabel.textColor = textColor
    
    self.addSubview(headerLabel)
  }
    
}

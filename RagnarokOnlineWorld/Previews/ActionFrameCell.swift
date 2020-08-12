//
//  ActionFrameCell.swift
//  RagnarokOnlineWorld
//
//  Created by Leon Li on 2020/8/13.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import UIKit

class ActionFrameCell: UICollectionViewCell {

    let frameView: UIImageView

    override init(frame: CGRect) {
        frameView = UIImageView()
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.contentMode = .scaleAspectFit

        super.init(frame: frame)

        contentView.addSubview(frameView)
        frameView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        frameView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        frameView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        frameView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        let backgroundView = UIView()
        backgroundView.backgroundColor = .secondarySystemBackground
        self.backgroundView = backgroundView

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .tertiarySystemBackground
        self.selectedBackgroundView = selectedBackgroundView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

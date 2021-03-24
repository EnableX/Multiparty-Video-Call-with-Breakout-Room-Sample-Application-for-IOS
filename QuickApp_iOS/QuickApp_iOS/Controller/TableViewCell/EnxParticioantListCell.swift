//
//  EnxParticioantListCell.swift
//  QuickApp_iOS
//
//  Created by VCX-LP-11 on 24/03/21.
//  Copyright © 2021 Daljeet Singh. All rights reserved.
//

import UIKit

class EnxParticioantListCell: UITableViewCell {
    @IBOutlet weak var nameOfParticipant: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

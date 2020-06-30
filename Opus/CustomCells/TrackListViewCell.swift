//
//  TopAlbumListViewCellTableViewCell.swift
//  Opus
//
//  Created   on 23/10/2018.
//  Copyright © 2019 All rights reserved.
//

import UIKit

class TrackListViewCell: UITableViewCell {

    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackDuration: UILabel!

   
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
      
       
        // Configure the view for the selected state
    }
    
    
}

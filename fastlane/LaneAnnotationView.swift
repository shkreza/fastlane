//
//  LaneAnnotationView.swift
//  fastlane
//
//  Created by Reza Sherafat on 3/5/16.
//  Copyright © 2016 No org. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class LaneAnnotationView: MKAnnotationView {
    
    var lane: Lane!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
 
        let laneAnnotation = annotation as! LaneAnnotation
        lane = laneAnnotation.lane
        if laneAnnotation.primaryTrip {
            let imagename = "lane\(lane.lane!)full"
            let image = UIImage(named: imagename)
            self.image = resizeImage(image!, newWidth: 20)
        } else {
            let imagename = "lane\(lane.lane!)"
            let image = UIImage(named: imagename)
            self.image = resizeImage(image!, newWidth: 20)
        }
    }
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

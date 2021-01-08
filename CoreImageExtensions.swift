import SpriteKit
// for fixing the out- of hexagon clicking bug


extension SKNode {

    func pointInside(point: CGPoint) -> Bool {
        
        let slope : CGFloat = 0.57735
        let grace_value : CGFloat = 3 // makes sure there is some leeway for the bounds to be drawn above the pixel boundaries
        if let tex = (self as? SKSpriteNode)?.texture { let y_intercept = tex.size().width * (1 / CGFloat(3.464) + CGFloat(0.2887)) + grace_value
            let pointX = CGFloat(trunc(point.x) )
            let pointY = CGFloat(trunc(point.y) )
//            print("Testing if click \(pointX) \(pointY) is out of hexagon.")
            // Pixels proved to be too hard!( All the research was in objective C and confusing) I'm using geometry to figure out if the click is within a hexagon.
            if ( ( pointY >  slope * pointX + y_intercept )  || (pointY <  -slope *  pointX - y_intercept )  || ( pointY >   -slope * pointX + y_intercept) || ( pointY <   slope * pointX - y_intercept ) ){
//                print( " not in bounds " )
                return false }
              } else { return false } // print for debug here
        
        return true
    }
}

//
//  InterfaceFunctions.swift
//  2Dgame1
//
//  Created by sebi d on 22.12.20.
//

import SpriteKit

// Purely for better organization of the code, I am putting functions belonging to exclusively to GameScenes here. If I want a function shared between SCene types, that will go in another file called SKSceneExtensions.swift

func grayOut( sprite : SKNode, strength: CGFloat, color : NSColor) {
    if let sprite = sprite as? SKSpriteNode  // unit
    { sprite.color = color ; sprite.colorBlendFactor = strength}
    else if let sprite = sprite as? SKLabelNode { sprite.color = color ; sprite.colorBlendFactor = strength; } else {  }// label
}
func grayReset( sprite : SKNode ) {
    if let sprite = sprite as? SKSpriteNode  // unit
    { sprite.colorBlendFactor = 0}
    else if let sprite = sprite as? SKLabelNode { sprite.colorBlendFactor = 0; } else {
        fatalError( "The node in dictionary is niether a label nor a sprite, nor shape but \(sprite)")  }// label
   // debug print("grayReset() called")
}

func inBounds( _ pos : SIMD2<Int>) -> Bool {
    if pos[0] < map_width + 1 {
    } else { return false }
    if pos[0] > -1 {
    } else { return false }
    if pos[1] < map_height + 1 {
    } else { return false}
    if pos[1] > -1 {
    } else { return false }
    return true
}
// does as expected, for any of the code, the reader is welcome to go through the logic here, or send questions to sebastian.detering@gmail.com
func adjacentTiles( pos : SIMD2<Int>, omit : [SIMD2<Int>] ) -> [SIMD2<Int>] {
    // First, if we are on an even y pos, those above need an offset
    var coords_out : [SIMD2<Int>] = [ ]
    let x = pos[0]
    let y = pos[1]
    let left = SIMD2<Int>( x - 1, y)
    let right = SIMD2<Int>( x + 1, y)
    let left_top = SIMD2<Int>( x - 1 + y % 2, y + 1)
    let right_top = SIMD2<Int>( x + y % 2, y + 1)
    let left_bottom = SIMD2<Int>( x - 1 + y % 2, y - 1)
    let right_bottom = SIMD2<Int>( x + y % 2, y - 1)
    
    if inBounds( left ) && !( omit.contains( left ) ) {
        coords_out.append( left)
    }
    if inBounds( right) && !( omit.contains( right ))  {
        coords_out.append( right )
    }
    if inBounds( left_top ) && !( omit.contains( left_top ) ){
        coords_out.append( left_top )
    }
    if inBounds( right_top) && !( omit.contains( right_top ) ){
        coords_out.append( right_top)
    }
    if inBounds( left_bottom) && !( omit.contains( left_bottom ) ){
        coords_out.append( left_bottom )
    }
    if inBounds( right_bottom) && !( omit.contains( right_bottom ) ){
        coords_out.append( right_bottom)
    }
    return coords_out
}



extension GameScene {
    // for use in the computeRange() method. Should be able to be recursively used.
    func branchTiles( positions : [SIMD2<Int>:Int8], omit : [SIMD2<Int>], u_class : unit_classes ) -> [SIMD2<Int>: Int8]  {
        var branched_options = positions
        var new_omit = omit
        var made_a_change : Bool = false
        for i in positions {
            for t in adjacentTiles(pos: i.key , omit: omit) {
                    if let it_terr = vec_dict[t]?[0] as? Terrain {
                    for c in terr_forms[ it_terr.typeName ]!.effects {
                        // an ugly way to get the movement specs
                        if c["class"] == u_class.rawValue {
                            if let mcost = Int8(c["movement"]! ) {
                                let mp_prime = i.value - mcost
                                if mp_prime < 0 {
                                    new_omit.append( t )
                                } else {
                                    if let prev_eval = branched_options[t] {
                                        if prev_eval < mp_prime {
                                            branched_options[t] = mp_prime
                                            made_a_change = true
                                        }
                                    } else { branched_options[t] = mp_prime; made_a_change = true; new_omit.append(t) }
                                }
                            }
                        }
                    }
                }
            }
        }
        if made_a_change {
            return branchTiles(positions: branched_options, omit: new_omit, u_class: u_class)
        }
        return branched_options
    }
    
    // takes in the position of unit selected, and with the corresponding specs based on the class, computes where it can and can't move.
    func computeRange( unitPos : SIMD2<Int> ) -> [SIMD2<Int> : Int8] {
        var moves_Out : [ SIMD2<Int> : Int8 ] = [unitPos : 0]
        if let myunit = vec_dict[unitPos]?[2] as? Unit {
            let u_class = myunit.unitclass
            if let move_points = Int8( unit_forms[ myunit.typeName ]!.actions[ 1 ]["movementPoints"]! ) {
                // when two tiles are stepping stones to a tile, select the one with least points, flag the tile as using X m. points...
                moves_Out = branchTiles(positions: [ unitPos: move_points], omit: [unitPos], u_class: u_class)
                return moves_Out

            } else { fatalError( "xmlParser formatting for unit movement specs is prob. causing this problem" )
            // use all the movment points up, finding most efficient path to tile.
            }
        } else { print("WARNING : Called computeRange() on tile not containing unit."); return moves_Out; }
    }
    
    func placeSelector( pos : SIMD2<Int> ) {
        let selector_node = SKSpriteNode( imageNamed : "blue_select")
        let spriteReference = vec_dict[pos]![0] as! SKSpriteNode
        selector_node.position = spriteReference.position
        selector_node.size = spriteReference.size
        selector_node.zPosition = spriteReference.zPosition + 1
        selectors.append(selector_node)
//        print("adding selector")
        background.addChild(selector_node)
        for i in vec_dict[ pos ]! {
            grayReset( sprite : i )
        }
    }
    
    func clearSelectors() {
        for s in selectors {
            s.removeFromParent()
        }
    }

    func unselectAll() {
        tile_selected = nil
        for t in vec_dict {
            for node in t.value {
                grayReset( sprite : node )
            }

        }
        clearSelectors()
    }
    
    func selectTile( clicked : SKNode , strength : CGFloat, color : NSColor   ) {
        var unit_pos : SIMD2<Int>? = nil
        for t1 in vec_dict {
            if (t1.value.count > 1)  { if let aNode = t1.value[0] as? SKSpriteNode {
                if aNode == clicked { unit_pos = t1.key
                    
                }
                else {
                    aNode.colorBlendFactor = strength
                    aNode.color = color
                    if (t1.value.count > 1) {
                        for b in 1...t1.value.count - 1{
                            grayOut( sprite : t1.value[b], strength : strength, color : color)
                        }
                    }
                } }
            else { print(" Don't know what was clicked here") }}
            else {
            
               if let aNode = t1.value[0] as? SKSpriteNode {
                   if (aNode == clicked) {
                    tile_selected = t1.key
                       aNode.colorBlendFactor = 0
                   } else {
                        // unnocupied tile :
                    grayOut( sprite : aNode, strength : strength, color : color )}
               } else { print(" the first dictionary value is not a Sprite node but a \(t1.value[0])")}
            } }
            // if the break statement hit, we continue here and go through a loop that will follow selection rules concerning units
        if unit_pos != nil {
        tile_selected = unit_pos
        var sround_tiles : [SIMD2<Int>] = []
        for t in computeRange( unitPos: unit_pos! ).keys {
            print(t)
            sround_tiles.append(t)
        }
        print(sround_tiles)
            if sround_tiles.count > 1 {
        for _ in vec_dict {
             for index in 0...sround_tiles.count - 1 {
                 if let rad_highlight = vec_dict[ sround_tiles[index] ] {
                 for b in 0...rad_highlight.count - 1{
                if let bb = rad_highlight[b] as? SKSpriteNode  // other tile
                {  bb.colorBlendFactor = 0 }
                else if let bb = rad_highlight[b] as? SKLabelNode { bb.colorBlendFactor = 0; } else {  }
                 } } }
        }
            }  else { for elem in vec_dict {
                if elem.key != unit_pos {
                for i in elem.value {
                    grayOut(sprite: i, strength: strength, color: color)  }
                } else { for i in elem.value {
                    grayReset( sprite : i)
                } }} } }
   }
    
    // Dotted Background
    func create_dbshader() -> SKShader {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_h_pix_thickness", float: 1.5),
            SKUniform(name: "u_v_pix_thickness", float: 1.5),
            SKUniform(name: "u_v_invrs_dens", float: 4 * 9),
            SKUniform(name: "u_h_invrs_dens", float: 4 * 16),
            SKUniform(name : "u_width", float : Float(bg_width)),
            SKUniform(name : "u_height", float : Float(bg_width)),
            SKUniform(name: "u_dot_color", color: .black),
            SKUniform(name: "u_bg_color", color: NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)),
        ]
        
        let attributes :  [SKAttribute] = [
        SKAttribute(name: "a_size", type: .vectorFloat2 )
    ]
        return SKShader(fromFile: "dottedbackground", uniforms: uniforms, attributes: attributes)
    }
}

//// function which takes in a SIMD2 position and radius, and tries to come up with hexagonal grid positions which fit an interpolated circle.
//// NOT NECESSARY when adjacent square point- moving is movement method.
//func radiusSelect( pos : SIMD2<Int>, radius : Int ) -> [SIMD2<Int>] {
//    //
//    var tiles_out : [SIMD2<Int>] = []
//    // add gauranteed horizontal tile positions
//    if radius > 3 {
//        tiles_out = radiusSelect(pos: pos, radius: 1)
//    for x in 1...radius - 1{
//            tiles_out.append(SIMD2<Int>(pos.x + x, pos.y))
//            if pos.x - x >= 0 {
//                tiles_out.append(SIMD2<Int>(pos.x - x, pos.y)) }
//    }
//        let y_max = Int( round(Float(radius) * 0.866) )
//    print(y_max)
//    for x in 0...radius - 1 {
//        for y in 1...y_max {
//            // here is the distance formula. The distance is computed based on ratios of hexagons, and the geometrical layout of a hexagon map.
//            let test_vector0 = SIMD2<Float>( Float(x) + 1, Float(y) * 0.866 )
//            let test_vector1 = SIMD2<Float>( Float(x) + 1/2, Float(y) * 0.866 )
//            // there will be an even number of tiles when the modulo 2 doesn't match the original row, otherwise calculate distance regularly and add any fitting guys.
//            if ( y % 2 != 1 ) {
//            if ( distance_squared(SIMD2<Float>(0,0), test_vector0 ) <= pow(Float(radius),2)) && x > 0{
//                tiles_out.append( SIMD2<Int>( pos.x + x, pos.y + y))
//                tiles_out.append( SIMD2<Int>( pos.x - x, pos.y + y))
//                tiles_out.append( SIMD2<Int>( pos.x - x, pos.y - y))
//                tiles_out.append( SIMD2<Int>( pos.x + x, pos.y - y))
//            } else {tiles_out.append( SIMD2<Int>( pos.x, pos.y + y))
//                tiles_out.append( SIMD2<Int>( pos.x, pos.y - y)) } }
//            else {
//                if ( distance_squared(SIMD2<Float>(0,0), test_vector1 ) <= pow(Float(radius),2)) && x > 0 {
//                    tiles_out.append( SIMD2<Int>( pos.x + x - 1 + pos.y % 2 , pos.y + y))
//                    tiles_out.append( SIMD2<Int>( pos.x - x + pos.y % 2, pos.y + y))
//                    tiles_out.append( SIMD2<Int>( pos.x - x + pos.y % 2, pos.y - y))
//                    tiles_out.append( SIMD2<Int>( pos.x + x - 1 + pos.y % 2, pos.y - y))
//                } else { tiles_out.append( SIMD2<Int>( pos.x  + pos.y % 2, pos.y + y))
//                    tiles_out.append( SIMD2<Int>( pos.x + pos.y % 2, pos.y - y))
//                    tiles_out.append( SIMD2<Int>( pos.x - 1 + pos.y % 2, pos.y + y))
//                        tiles_out.append( SIMD2<Int>( pos.x - 1 + pos.y % 2, pos.y - y))
//                }
//            }
//
//    }
//    } } else { if radius == 1 {
//        // manually do the first few tiles, since the circle interpolation is very rough when there are few hexagons, recursive definitions make this neater.
//        tiles_out = [pos]}
//    else if radius == 2 {
//        tiles_out = radiusSelect(pos: pos, radius: 1)
//        for v in [SIMD2<Int>(pos.x + 1 , pos.y ),
//                  SIMD2<Int>(pos.x - 1 , pos.y ),
//                  SIMD2<Int>(pos.x + pos.y % 2, pos.y + 1   ),
//                  SIMD2<Int>(pos.x + pos.y % 2, pos.y - 1),
//              SIMD2<Int>(pos.x - 1 + pos.y % 2, pos.y - 1),
//              SIMD2<Int>(pos.x - 1 + pos.y % 2, pos.y + 1)]
//        {
//            tiles_out.append(v)
//        }
//    }
//    else if radius == 3 {
//        tiles_out = radiusSelect(pos: pos, radius : 2)
//        for v in [SIMD2<Int>(pos.x + 2, pos.y    ),
//                  SIMD2<Int>(pos.x + 1, pos.y + 2),
//                  SIMD2<Int>(pos.x - 1, pos.y + 2),
//                  SIMD2<Int>(pos.x - 2 + pos.y % 2, pos.y + 1),
//                  SIMD2<Int>(pos.x - 2 + pos.y % 2, pos.y - 1),
//                  SIMD2<Int>(pos.x - 2, pos.y    ),
//                  SIMD2<Int>(pos.x - 1, pos.y - 2),
//                  SIMD2<Int>(pos.x + 1, pos.y - 2),
//                  SIMD2<Int>(pos.x ,    pos.y - 2),
//                  SIMD2<Int>(pos.x + 1 + pos.y % 2,    pos.y - 1),
//                  SIMD2<Int>(pos.x ,    pos.y + 2),
//                  SIMD2<Int>(pos.x + 1 + pos.y % 2,    pos.y + 1), ]
//        { if v.x > 0 {tiles_out.append(v)} }
//    }
//    }
//    return tiles_out
//}

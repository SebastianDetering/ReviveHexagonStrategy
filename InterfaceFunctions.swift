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

extension GameScene {
    func unselectAll() {
        tile_selected = nil
        for t in vec_dict {
            for node in t.value {
                grayReset( sprite : node )
            }

        }
        }
    func selectTile( clicked : SKNode , strength : CGFloat, color : NSColor   ) {
        var unit_pos : SIMD2<Int>? = nil
        for t1 in vec_dict {
            if (t1.value.count > 1)  { if let aNode = t1.value[0] as? SKSpriteNode { if aNode == clicked { unit_pos = t1.key } else { aNode.colorBlendFactor = strength
                aNode.color = color
                if (t1.value.count > 1) {
                 for b in 1...t1.value.count - 1{
                    if let ba = t1.value[b] as? SKSpriteNode  // unit
                    { ba.color = color ; ba.colorBlendFactor = strength}
                    else if let ba = t1.value[b] as? SKLabelNode { ba.color = color ; ba.colorBlendFactor = strength; } else {  }// label
                }
            }} }  else { print(" Don't know what was clicked here") }}
            else {
            
               if let aNode = t1.value[0] as? SKSpriteNode {
                   if (aNode == clicked) {
                    tile_selected = t1.key
                       aNode.colorBlendFactor = 0
                   } else {
                        // unnocupied tile :
                           aNode.color = color
                           aNode.colorBlendFactor = strength}
               } else { print(" the first dictionary value is not a Sprite node but a \(t1.value[0])")}
            } }
            // if the break statement hit, we continue here and go through a loop that will follow selection rules concerning units
        if unit_pos != nil {
        tile_selected = unit_pos
        let sround_tiles = radiusSelect(pos: unit_pos!, radius: 2)
//        print(sround_tiles)  // debug: So I can see how the radius function outputs
        for _ in vec_dict {
             for index in 0...sround_tiles.count - 1 {
                 if let rad_highlight = vec_dict[ sround_tiles[index] ] {
                 for b in 0...rad_highlight.count - 1{
                if let bb = rad_highlight[b] as? SKSpriteNode  // other tile
                {  bb.colorBlendFactor = 0 }
                else if let bb = rad_highlight[b] as? SKLabelNode { bb.colorBlendFactor = 0; } else {  }
                 } } }
        }
        }
   }
    // function which takes in a SIMD2 position and radius, and tries to come up with hexagonal grid positions which fit an interpolated circle.
    func radiusSelect( pos : SIMD2<Int>, radius : Int ) -> [SIMD2<Int>] {
        //
        var tiles_out : [SIMD2<Int>] = []
        // add gauranteed horizontal tile positions
        if radius > 3 {
            tiles_out = radiusSelect(pos: pos, radius: 1)
        for x in 1...radius - 1{
                tiles_out.append(SIMD2<Int>(pos.x + x, pos.y))
                if pos.x - x >= 0 {
                    tiles_out.append(SIMD2<Int>(pos.x - x, pos.y)) }
        }
            let y_max = Int( round(Float(radius) * 0.866) )
        print(y_max)
        for x in 0...radius - 1 {
            for y in 1...y_max {
                // here is the distance formula. The distance is computed based on ratios of hexagons, and the geometrical layout of a hexagon map.
                let test_vector0 = SIMD2<Float>( Float(x) + 1, Float(y) * 0.866 )
                let test_vector1 = SIMD2<Float>( Float(x) + 1/2, Float(y) * 0.866 )
                // there will be an even number of tiles when the modulo 2 doesn't match the original row, otherwise calculate distance regularly and add any fitting guys.
                if ( y % 2 != 1 ) {
                if ( distance_squared(SIMD2<Float>(0,0), test_vector0 ) <= pow(Float(radius),2)) && x > 0{
                    tiles_out.append( SIMD2<Int>( pos.x + x, pos.y + y))
                    tiles_out.append( SIMD2<Int>( pos.x - x, pos.y + y))
                    tiles_out.append( SIMD2<Int>( pos.x - x, pos.y - y))
                    tiles_out.append( SIMD2<Int>( pos.x + x, pos.y - y))
                } else {tiles_out.append( SIMD2<Int>( pos.x, pos.y + y))
                    tiles_out.append( SIMD2<Int>( pos.x, pos.y - y)) } }
                else {
                    if ( distance_squared(SIMD2<Float>(0,0), test_vector1 ) <= pow(Float(radius),2)) && x > 0 {
                        tiles_out.append( SIMD2<Int>( pos.x + x - 1 + pos.y % 2 , pos.y + y))
                        tiles_out.append( SIMD2<Int>( pos.x - x + pos.y % 2, pos.y + y))
                        tiles_out.append( SIMD2<Int>( pos.x - x + pos.y % 2, pos.y - y))
                        tiles_out.append( SIMD2<Int>( pos.x + x - 1 + pos.y % 2, pos.y - y))
                    } else { tiles_out.append( SIMD2<Int>( pos.x  + pos.y % 2, pos.y + y))
                        tiles_out.append( SIMD2<Int>( pos.x + pos.y % 2, pos.y - y))
                        tiles_out.append( SIMD2<Int>( pos.x - 1 + pos.y % 2, pos.y + y))
                            tiles_out.append( SIMD2<Int>( pos.x - 1 + pos.y % 2, pos.y - y))
                    }
                }
                
        }
        } } else { if radius == 1 {
            // manually do the first few tiles, since the circle interpolation is very rough when there are few hexagons, recursive definitions make this neater.
            tiles_out = [pos]}
        else if radius == 2 {
            tiles_out = radiusSelect(pos: pos, radius: 1)
            for v in [SIMD2<Int>(pos.x + 1 , pos.y ),
                      SIMD2<Int>(pos.x - 1 , pos.y ),
                      SIMD2<Int>(pos.x + pos.y % 2, pos.y + 1   ),
                      SIMD2<Int>(pos.x + pos.y % 2, pos.y - 1),
                  SIMD2<Int>(pos.x - 1 + pos.y % 2, pos.y - 1),
                  SIMD2<Int>(pos.x - 1 + pos.y % 2, pos.y + 1)]
            {
                tiles_out.append(v)
            }
        }
        else if radius == 3 {
            tiles_out = radiusSelect(pos: pos, radius : 2)
            for v in [SIMD2<Int>(pos.x + 2, pos.y    ),
                      SIMD2<Int>(pos.x + 1, pos.y + 2),
                      SIMD2<Int>(pos.x - 1, pos.y + 2),
                      SIMD2<Int>(pos.x - 2 + pos.y % 2, pos.y + 1),
                      SIMD2<Int>(pos.x - 2 + pos.y % 2, pos.y - 1),
                      SIMD2<Int>(pos.x - 2, pos.y    ),
                      SIMD2<Int>(pos.x - 1, pos.y - 2),
                      SIMD2<Int>(pos.x + 1, pos.y - 2),
                      SIMD2<Int>(pos.x ,    pos.y - 2),
                      SIMD2<Int>(pos.x + 1 + pos.y % 2,    pos.y - 1),
                      SIMD2<Int>(pos.x ,    pos.y + 2),
                      SIMD2<Int>(pos.x + 1 + pos.y % 2,    pos.y + 1), ]
            { if v.x > 0 {tiles_out.append(v)} }
        }
        }
        return tiles_out
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

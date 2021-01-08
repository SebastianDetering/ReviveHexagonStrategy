//
//  GameScene.swift
//  2Dgame1
//
//  Created by sebi d on 3.12.20.
//
// This file is an earlier version of the GameScene and contains a good starting point for making a Mapping Scene.

import SpriteKit
import GameplayKit

// Stuff not needed to be declared


//class Tile : SKSpriteNode { }
//// my preset background values
//let bg_width : CGFloat = 1920
//let bg_height : CGFloat = 1080
//// unit texture stuff
//let foot = SKTexture( imageNamed: "blue_soldier.png")
//let heavy = SKTexture( imageNamed : "heavy" )
//let unit_texs = [  unit_types.foot : foot, unit_types.heavy : heavy]
//// end of unit texture stuff
//// terrain texture stuff
//let grass = SKTexture(imageNamed:  "green_hex3")
//let water = SKTexture(imageNamed:  "blue_hex1")
//
//let terrains = [ terr_types.grass : grass,
//                 terr_types.water :  water]
//// end of terrain texture stuff

 // todo : add the remaining textures and stuff, add gamelogic here
class MappingScene: SKScene {
    var start_time : TimeInterval = 0
    var game_time : TimeInterval = 0
    var stage : game_stages = .menu
    var vec_dict : [SIMD2<Int>:[SKNode]] = [:]
    var background : SKSpriteNode = SKSpriteNode(imageNamed: "bg")

    override func didMove(to view: SKView) {
        
        start_time = Double(CVGetCurrentHostTime())

        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 1
        
        background.size = CGSize( width :  bg_width, height: bg_height )
        background.zPosition = -1
        
        background.shader = create_dbshader()
        addChild(background)
        
        vec_dict = positionAllNodes(terrains: createTerrainsfromXML(mapParsed: exMap1), units: createUnitsfromXML(mapParsed: exMap1))
        
        for entry in vec_dict {
            background.addChild(entry.value[0])
            // check if there is something besides the tile.
            if ( entry.value.count > 1) { background.addChild(entry.value[1]); background.addChild( entry.value[2] )}
        }

    }
    // Dotted Background
    func create_dbshader() -> SKShader {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_h_pix_thickness", float: 1.5),
            SKUniform(name: "u_v_pix_thickness", float: 2),
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
    
    

    let p1_income = 200
    let p2_income = 200
    let p1_gold = 250
    let p2_gold = 250
    
//    var turn = 0 {
//        didSet {
//            pl_gold += p1_income
//            p2_gold += p2_income
//        }
//    }
    
     func selectTile( clicked : SKNode , strength : CGFloat, color : NSColor   ) {
        for t in vec_dict {
            let a = t.value[0] as! SKSpriteNode
                if (a == clicked) {
                    // print( "clicked_tile is \(a)")
                    a.colorBlendFactor = 0

                } else {
                    
                    if (t.value.count > 1) { // handles the occupied tile case.
                    print("different tyle reached, and has a unit")
                        
                        /* Not to self: you can technically make the for loop take care of even the 0th case but this shouldn't not be a tile (SKSPrite)  */
                        
                    for b in 1...t.value.count - 1{
                        if let ba = t.value[b] as? SKSpriteNode  // unit
                        { ba.color = color ; ba.colorBlendFactor = strength}
                        else if let ba = t.value[b] as? SKLabelNode { ba.color = color ; ba.colorBlendFactor = strength; } else { fatalError( "The node in dictionary is niether a label nor a sprite but \(t.value[b])") }// label
                    }
                } // unnocupied tile :
                    else  { //print("different unnocupied tile")
                        a.color = color
                        a.colorBlendFactor = strength}}

        }
    }
    
    func unselectAll() {
        for t in vec_dict {
            for node in t.value {
                if let a = node as? SKSpriteNode {
                    a.colorBlendFactor = 0 } else if let a = node as? SKLabelNode { a.colorBlendFactor = 0} else { fatalError( "The node in dictionary is niether a label nor a sprite but \(node)")
            }

        }
        }}
    
    override func mouseDown(with event: NSEvent) {
        let position = event.locationInWindow
        guard let clicked_tile = nodes(at: position).first(where: { $0 is Terrain}) as? Terrain else { unselectAll(); return}
        // highlights clicked tile debug print statements
        let select_color = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.2)
        selectTile(clicked: clicked_tile, strength: 0.2, color: select_color)
    }
    
    override func update(_ currentTime: TimeInterval) {
        game_time = currentTime - start_time / 1000000000
        // Called before each frame is rendered
//        switch stage {
//        case .menu :
//
        
        }
        
    
}


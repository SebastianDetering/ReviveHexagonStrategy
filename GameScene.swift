//
//  GameScene.swift
//  2Dgame1
//
//  Created by sebi d on 3.12.20.
//

import SpriteKit
import GameplayKit

// my preset background values
let bg_width : CGFloat = 2660
let bg_height : CGFloat = 1880

// end of terrain texture stuff
// HP counter custom texture

var hptextures : [SKTexture] = []
// todo : add the remaining textures and stuff, add gamelogic here

// introducing the array of unit textures
class GameScene: SKScene {
    var players = 2
    let game_unit_font = "Avenir-Book"
    let game_title_font = "Impact"
    var time_offset : TimeInterval = 0
    var start_time : TimeInterval = 0
    var game_time : TimeInterval = 0
    var vec_dict : [SIMD2<Int>:[SKNode]] = [:]
    var background : SKSpriteNode = SKSpriteNode()
    var game_running : Bool = false
    // temporary button stuff
    let ready_button = Button(imageNamed: "upbutton" )
    let pressed_tex = SKTexture( imageNamed : "downbutton" )
    let button_tex = SKTexture( imageNamed : "upbutton" )
    let ready_label =  SKLabelNode( text: "ready?")

    //declare time
    let timeLabel = SKLabelNode(fontNamed: "Impact")
    var time = 0 {
        didSet{
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedTime = formatter.string(from : time as NSNumber) ?? "0"
        timeLabel.text = "time: \(formattedTime)"
        }
    }
    // declare turn
    let turnLabel = SKLabelNode(fontNamed: "Impact")
    var turn = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from : turn as NSNumber) ?? "0"
            turnLabel.text = "turn: \(formattedScore)"
        }
    }
    let tileLabel = SKLabelNode(fontNamed : "Impact")
    var tile_selected : SIMD2<Int>? = nil {
        didSet {
            if let formattedTyle = tile_selected {
                tileLabel.text = "Selected Tyle : (\(formattedTyle[0]),\(formattedTyle[1]))"
            }
            else {tileLabel.text = "Selected Tyle : (None, None)"}
        }
    }
    // Custom start units ( For play testing . )
    // start of didMove()
    override func didMove(to view: SKView) {
        // Starting the GameScene in setup mode :
        stage = .setup
        // This is to make an array of each unit type and to include it
        // (Probably a better place to put this, but it initializes the list of hp counters' textures
        for i in 1...10 {
            hptextures.append( SKTexture(imageNamed : "counter_\(i)") )
        }
        // time
        timeLabel.position = CGPoint(x: bg_width/2 + 10, y: bg_height/2 + 30)
        start_time = Double(CVGetCurrentHostTime())
        time_offset = start_time
        //turn
        turnLabel.fontName = game_title_font
        turn = 1
        turnLabel.position = CGPoint(x: bg_width/2, y: bg_height/2)
        turnLabel.zPosition = 1
        //background
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 1
        background.size = CGSize( width :  bg_width, height: bg_height )
        background.zPosition = -1
        background.shader = create_dbshader()
        // tile select
        tileLabel.text = "Selected Tyle : (None, None)"
        tileLabel.alpha = 1
        tileLabel.position = CGPoint(x: bg_width/2 + 10, y: bg_height/2 + 58)
        tileLabel.zPosition = 100
        tileLabel.fontName = game_title_font
        // Buttons
        ready_button.position = CGPoint(x: bg_width/2 + 10, y: bg_height/2 - 35)
        ready_button.size = CGSize(width: 100, height: 40)
        ready_label.position = ready_button.position
        ready_label.color = NSColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1)
        ready_label.colorBlendFactor = 1
        ready_label.zPosition = 2
        // add the nodes
        addChild(ready_label)
        addChild(ready_button)
        addChild(timeLabel)
        addChild(turnLabel)
        addChild(background)

        vec_dict = positionAllNodes(terrains: createTerrainsfromXML(mapParsed: exMap1), units: createUnitsfromXML(mapParsed: exMap1))
//        print( vec_dict[ SIMD2<Int>(x : 0, y: 0) ])
        for tilenode in vec_dict {
            background.addChild(tilenode.value[0] )
            // check if there is something besides the tile.
            if (tilenode.value.count > 1) {
                for i in 1...tilenode.value.count - 1 {
                    background.addChild( tilenode.value[i] )
                }}
        }
    } //End of didMove()
    // it is recommended to have most gamelogic outside of update()
    override func mouseDown(with event: NSEvent) {
        let position = event.locationInWindow
        switch stage {
        case .setup:
            guard let clicked_button = nodes(at : position).first(where : { $0 is Button } ) as? Button else { return }
            if clicked_button == ready_button{
                ready_button.texture = pressed_tex
            }
        default:
            // hexagon bounds check (Sprite kit presents SpriteNode Hitboxes as rects)
            if let clicked_terrain = nodes(at: position).first(where: { $0 is Terrain && $0.pointInside( point : CGPoint(x : background.position.x + $0.position.x - position.x, y : background.position.y  + $0.position.y - position.y ) ) }) as? Terrain
            { let select_color = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
                selectTile(clicked: clicked_terrain, strength: 0.2, color: select_color) }
            else { unselectAll(); }
            // highlights clicked tile debug print statements
        }
        
    }
    override func mouseUp(with event: NSEvent) {
        ready_button.texture = button_tex
        let position = event.locationInWindow
        guard let clicked_button = nodes(at : position).first(where : { $0 is Button } ) as? Button else { return }
        if clicked_button == ready_button {
            stage = .play
            ready_label.removeFromParent()
            ready_button.removeFromParent()
        } else {  }
    }
    override func update(_ currentTime: TimeInterval) {
        switch stage {
        case .pause :
            time_offset = currentTime * 1000000000
            usleep(1)
        case .setup :
            time_offset = currentTime * 1000000000
            usleep(1)
        case .play :
            time = Int(currentTime - time_offset / 1000000000)
            usleep(1)
        default:
            print("Invalid game stage (\(time))")
            time = Int(currentTime - time_offset / 1000000000 )
            usleep(1)
        }
        
    }
}

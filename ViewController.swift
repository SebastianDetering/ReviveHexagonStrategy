//
//  ViewController.swift
//  2Dgame1
//
//  Created by sebi d on 3.12.20.
//

import Cocoa
import SpriteKit
import GameplayKit
var exMap1 : map!

var unit_texture_names = ["antiair","battleship","bomber"]
// my idea here was to have [ Color : Name ] : Texture dictionaries of Colors and names as keys of texture dictionary.
var unit_textures : [ [ colors : String] : SKTexture ] = [:]
var terrain_textures : [ [colors? : String ] : SKTexture ] = [:] // colors is optional since unowned bases exist.
let xmltoPng : [String : String] = [ "Desert" : "desert", "Woods" : "forest", "Mountains" : "mountain", "Plains" : "plain", "Swamp" : "swamp", "Water" : "water", "Airfield" : "airfield", "Base" : "city", "Harbor" : "harbor" ] // this is required because xml type names are different than the image names.
let pngtoXml : [String : String ] = [ "001" : "Trooper", "002" : "Heavy", "003" : "Raider", "004" : "Assault Artillery", "005": "Tank" ]

var stage : game_stages = .menu // this is the universal game stage which will be switched on (for later)
class ViewController: NSViewController {

    @IBOutlet var skView: SKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for the unit_texture names initialization, a lot of stuff used here is defined in StructandEnums.swift
        for i in 0...9  {
            unit_texture_names.append( "00" + String(i))
        }
        unit_texture_names.append("010")
        for c in colors.allCases {
            for n in unit_texture_names {
                if let mapValue =  pngtoXml[n] {
                unit_textures[ [c : mapValue ] ] = SKTexture(imageNamed: c.rawValue + "_" + n )
                } else { unit_textures[ [c : n ] ] = SKTexture(imageNamed: c.rawValue + "_" + n ) }
            }
        }
        // for the terrain_textures initialization., first I do the unowned case.
        for n in terrains.allCases {
            if let pngName = xmltoPng[ n.rawValue ]{
                terrain_textures[ [nil :  n.rawValue ] ] = SKTexture(imageNamed: pngName ) }
        }
        // now for the owned cases (airfields, bases, and harbors (elements 0 to 2).)
     
        for n in 0...["city", "airfield", "harbor"].count - 1 {
            for c in colors.allCases {
                terrain_textures[ [ c : ["Base", "Airfield", "Harbor"][n] ]] =  SKTexture(imageNamed : c.rawValue + "_" + ["city", "airfield", "harbor"][n] )
            }
        }
        
        // next I need to grab all the specifications from the xml files.
        // I'm going to try looping through my enum raw values.
        var unit_forms : [units:unit] = [:]
        var terr_forms : [terrains : terr] = [:]
        for u in units.allCases {
            // MARK: I can't get the file url to search only through a particular directory. FRUSTRATING
            if let unitFilepath = Bundle.main.url(forResource: u.rawValue, withExtension: "xml") {
                do {
                let xml = try String( contentsOf: unitFilepath )
                let unitParser = UnitParser(withXML: xml)
                let units = unitParser.parse()
                unit_forms[u]  = units[0]
                } catch { print("couldn't parse unitFile found \(unitFilepath)")}
                } else { print("failed fetching unit file with with supposed name: " + u.rawValue)}
        }
        for t in terrains.allCases {
            if let unitFileUrl = Bundle.main.url(forResource: t.rawValue, withExtension: "xml") {
                do {
                let xml = try String( contentsOf: unitFileUrl )
                let terrainParser = TerrainParser( withXML: xml)
                let terrains = terrainParser.parse()
                terr_forms[t]  = terrains[0]
                } catch { print("couldn't parse unitFile found \(unitFileUrl)")}
                } else { print("failed fetching unit file with with supposed name: " + t.rawValue)}
            }
        // Example xml formatted map for parsing, and instantiating
        var ex_maps : [map]? = []
        let mapName = "tragic triangle - 32" // Example map name
        if let mapUrl = Bundle.main.url(forResource : mapName, withExtension: "xml") {
            do {
            let xml = try String( contentsOf: mapUrl )
            let mapParser = MapParser( withXML: xml)
            let maps = mapParser.parse()
            ex_maps!.append( maps[0] )
            } catch { print("couldn't parse unitFile found \(mapUrl)")}
            } else { print("failed fetching unit file with supposed name: " + mapName)}
        exMap1 = ex_maps![0]
        // Everything above is for parsing xmls into usable data.
        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            let scenes = ["MenuScene","GameScene"]
            var current_scene : Int = 1
            if let scene = SKScene(fileNamed: scenes[current_scene]) {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .resizeFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}


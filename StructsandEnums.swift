import SpriteKit

class Button : SKSpriteNode { }
// If time : explore how using string enums or UInt8 typeIds is superior
class Terrain : SKSpriteNode {
    let typeName  : terrains
    var team_color : colors?     // mutable
    init( typeName: terrains, team_color : colors?, init_Texture : SKTexture?, size : CGSize ){
        self.typeName = typeName
        self.team_color = team_color
        super.init(texture: init_Texture, color : NSColor(deviceWhite: 1, alpha: 1), size: size)
    }
    required init?(coder aDecoder: NSCoder) { fatalError( "init(coder:) has not been implemented") }
    func colorDidChange( _ to : colors? ) {
        team_color = to
        self.texture = terrain_textures[ [to : typeName.rawValue ]]
    }
}
class Unit : SKSpriteNode {
    let typeName : units
    let team_color : colors!
    var health : Int8
    init( typeName : units, team_color : colors!, initialHealth : Int8, init_Texture : SKTexture?, size : CGSize) {
        self.typeName = typeName
        self.team_color = team_color
        self.health = initialHealth
        super.init(texture: init_Texture, color : NSColor(deviceWhite: 1, alpha: 1), size: size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum colors : String, CaseIterable {
    case blue = "blue",
         red = "red",
         green = "green",
         purple = "purple",
         white = "white",
         yellow = "yellow"
}
enum game_stages {
    case menu, edit, play, setup, pause, ended
}
struct terrain {
    let ownership : colors?
    let terrain : terrains
}

enum unit_classes : String , CaseIterable {
    case soft = "soft",
         hard = "hard",
         sub  = "sub",
         boat = "boat",
         amphibic = "amphibic",
         air = "air",
         speedboat = "speedboat"
}
enum terrains : String, CaseIterable {
    case Desert = "Desert",
         Plains = "Plains",
         Swamp = "Swamp",
         Bridge = "Bridge",
         Mountains = "Mountains",
         Woods = "Woods",
         Water = "Water",
         Base  = "Base",
         Repairshop = "Repairshop",
         Airfield   = "Airfield",
         Harbor     = "Harbor"
}
enum units : String, CaseIterable {
    case Berserker = "Berserker",
         Helicopter = "Helicopter",
         Trooper = "Trooper",
         Heavy_Trooper = "Heavy Trooper",
         Destroyer = "Destroyer",
         Submarine = "Submarine",
         Light_Artillery = "Light Artillery",
         DFA = "DFA",
         Heavy_Tank = "Heavy Tank",
         Jet = "Jet",
         Anti_Aircraft = "Anti Aircraft",
         Battleship = "Battleship",
         Heavy_Artillery = "Heavy Artillery",
         Raider = "Raider",
         Assault_Artillery = "Assault Artillery",
         Bomber = "Bomber",
         Hovercraft = "Hovercraft",
         Speedboat = "Speedboat",
         Tank = "Tank"
}

enum unit_typeIds : UInt8 {
    case Berserker = 6,
         Helicopter = 15,
         Trooper =  0,
         Heavy_Trooper = 1,
         Destroyer = 14,
         Submarine = 19,
         Light_Artillery = 7,
         DFA = 9,
         Heavy_Tank = 5,
         Jet = 17,
         Anti_Aircraft = 10,
         Battleship = 11,
         Heavy_Artillery = 8,
         Raider = 2,
         Assault_Artillery = 3,
         Bomber = 12,
         Hovercraft = 16,
         Speedboat = 18,
         Tank = 4
}

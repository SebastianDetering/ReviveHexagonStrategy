//
//  XMLParser.swift
//  2Dgame1
//
//  Created by sebi d on 17.12.20.
//
// I PUKE AT THIS !
import Foundation
// Map parser
class map : CustomStringConvertible {
    var mapId : Int = 0
    var name =  ""
    var author = ""
    var map_terrains : [ [String : String ] ] = [ [:] ]
    var initialCredits : Int = 0
    var perBaseCredits : Int = 0
    var description : String {
    return "Id : \(mapId), map name : \(name), created by \(author) "
}
}

class MapParser : NSObject {
    var xmlParser : XMLParser?
    var xmlText = ""
    // I added this to reduce confusion of the <unit> as the entire class tag and < unit...> inside <effects>
    var effectManagement = true
    var currentMap : map?
    var current_terrains : [ [String:String] ] =  []
    var maps : [map] = []
    init(withXML xml : String) {
        if let data = xml.data(using: String.Encoding.utf8){
            xmlParser = XMLParser(data : data)
        }
    }
    
    func parse() -> [map] {
        xmlParser?.delegate = self
        xmlParser?.parse()
        return maps
    }
}
extension MapParser : XMLParserDelegate {
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [ String : String] = [:]) {
        xmlText = ""
        if elementName == "map" {
            currentMap = map()
            if let mapIdint = Int(attributeDict["id"]!) {
                currentMap?.mapId = mapIdint }
        }
        if elementName == "terrains" {
            // terrains dict. array begins parsing after this
        }
        if elementName == "terrain" {
            // handles if the terrain is preoccupied with a if let statement.
            if let startUnit = attributeDict["startUnit"] {
                if let startFaction = attributeDict["startFaction"] {
                    current_terrains.append( [ "x" : attributeDict["x"]!, "y" : attributeDict["y"]!, "startUnit" : startUnit, "startUnitOwner" : attributeDict["startUnitOwner"]!, "type" : attributeDict["type"]!, "startFaction" : startFaction ] )  } // owned bases
                else {
                        current_terrains.append( [ "x" : attributeDict["x"]!, "y" : attributeDict["y"]!, "startUnit" : startUnit, "startUnitOwner" : attributeDict["startUnitOwner"]!, "type" : attributeDict["type"]! ] )
                    }
            } else { current_terrains.append( [ "x" : attributeDict["x"]!, "y" : attributeDict["y"]!, "startUnitOwner" : attributeDict["startUnitOwner"]!, "type" : attributeDict["type"]! ] ) }
        }
    }
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == "creator" {
            currentMap?.author = xmlText
        }
        if elementName == "name" {
            currentMap?.name = xmlText
        }
        if elementName == "perBaseCredits" {
            if let intForm = Int(xmlText) {
            currentMap?.perBaseCredits = intForm
            }
        }
        if elementName == "initialCredits" {
            if let intForm = Int(xmlText) {
                currentMap?.initialCredits = intForm
            }
        }
        if elementName == "terrains" {
            currentMap?.map_terrains = current_terrains
        }
        if elementName == "map" {
            if let finishedMap = currentMap {
                maps.append( finishedMap )
            }
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        xmlText += string
    }
}
// Map above

// Below handles parsing of terrain .xml specifications
class terr : CustomStringConvertible {
        var typeId : Int8 = 0
        var typeName =  ""
        var incomeGeneration : Int = 0
        var effects : [ [String:String] ] =  [ ]
    var buildableUnits : [String] = []
    var description : String {
        return "\n (NEW TERRAIN) typeId : \(typeId), name : \(typeName), incomeGeneration : \(incomeGeneration), \n effects: <-- The effects this terrain has on unit classes --> \n \(effects) \n \n "
    }
}

class TerrainParser : NSObject {
    var xmlParser : XMLParser?
    var terrs : [terr] = []
    var currentTerr : terr?
    // for setting the final unit effects array
    var effects : [ [String : String ] ] = []
    var buildableUnits : [units] = []
    // Anything above will be put into a terr() class.
    var xmlText = ""
    // I added this to reduce confusion of the <unit> as the entire class tag and < unit...> inside <effects>
    var effectManagement = true
    init(withXML xml : String) {
        if let data = xml.data(using: String.Encoding.utf8){
            xmlParser = XMLParser(data : data)
        }
    }
    
    func parse() -> [terr] {
        xmlParser?.delegate = self
        xmlParser?.parse()
        return terrs
    }
}
extension TerrainParser : XMLParserDelegate {
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [ String : String] = [:]) {
        xmlText = ""
        if elementName == "effects" {
            
            effectManagement = false
        }
        if elementName == "terrain" && effectManagement{
            currentTerr = terr()
        }
        // should handle the unit effects attributes, then add to the attributes dictionary list.
        else { if elementName == "unit" && !effectManagement {
            effects.append( [ "class" : attributeDict["class"]!, "attack" : attributeDict["attack"]!, "movement" : attributeDict["movement"]!, "canRepair" : attributeDict["canRepair"]!, "repair" : attributeDict["repair"]!, "capturedAttack" : attributeDict["capturedAttack"]!, "capturedDefence" : attributeDict["capturedDefence"]!, "capturedRepair" : attributeDict["capturedRepair"]! ])
            
        } }
        
    }
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == "typeId" {
            if let typeId = Int8(xmlText) {
                currentTerr!.typeId = typeId
            }
            else { print("typeId in xml file \"\(xmlText)\" not a number") }
        }
        if elementName == "typeName" {
            // stringByTrimmingCharactersInSet( set : NSCharacterSet.ex) replaced by .trimmingCharacters() : Source 1
            currentTerr?.typeName = xmlText.trimmingCharacters(in : NSCharacterSet.whitespacesAndNewlines)
        }
        if elementName == "incomeGeneration" {
            if let incomeInt = Int(xmlText) {
                currentTerr?.incomeGeneration = incomeInt
            }
        }
        if elementName == "effects" {
            currentTerr?.effects = effects
            effectManagement = true
        }
        // this handles the end of the this unit class
        if elementName == "unit" && effectManagement {
            if let enumform = units(rawValue : xmlText) {
                buildableUnits.append( enumform )
            }
        }
        if elementName == "terrain" {
            if let finishedTerr = currentTerr {
                terrs.append( finishedTerr )
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        xmlText += string
    }
}

// above is terrain xml parsing
// Everything below handles parsing unit .xml specifications
// to parse the xml data I used youtube video ( #2 )

// note to self : In the future figure out whether there is a way to not use a bunch of var declarations.
class unit : CustomStringConvertible {
        var typeId : Int8 = 0
        var typeName =  ""
        var className = ""
        var cost = 0
        var initialHealth = 0
        var maxHealth = 0
        var capturableTerrain : [ terrains ] = []
        var canOccupyEnemyTerrain : Bool = false
        var canRepairOnEnemyTerrain : Bool = false
        var defence = 0
        var effects : [ [String:String] ] =  [ ]
    var description : String {
        return "\n (NEW UNIT) typeId : \(typeId), name : \(typeName), class : \(className), cost : \(cost), initialHealth : \(initialHealth), maxHealth : \(maxHealth), capturableTerrain : \(capturableTerrain), canOccupyEnemyTerrain : \(canOccupyEnemyTerrain), canRepairOnEnemyTerrain : \(canRepairOnEnemyTerrain), defence : \(defence), \n effects: <-- The effects this has on other units --> \n \(effects) \n \n  "
    }
}

class UnitParser : NSObject {
    var xmlParser : XMLParser?
    var units : [unit] = []
    var xmlText = ""
    var currentUnit : unit?
    // for setting the final unit effects array
    var effects : [ [String : String ] ] = []
    // I added this to reduce confusion of the <unit> as the entire class tag and < unit...> inside <effects>
    var effectManagement = true
    init(withXML xml : String) {
        if let data = xml.data(using: String.Encoding.utf8){
            xmlParser = XMLParser(data : data)
        }
    }
    
    func parse() -> [unit] {
        xmlParser?.delegate = self
        xmlParser?.parse()
        return units
    }
}
extension UnitParser : XMLParserDelegate {
    func parser(_ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [ String : String] = [:]) {
        xmlText = ""
        if elementName == "effects" {
            
            effectManagement = false
        }
        if elementName == "unit" && effectManagement{
            currentUnit = unit()
            effectManagement = false
        }
        // should handle the unit effects attributes, then add to the attributes dictionary list.
        else { if elementName == "unit" && !effectManagement {
            effects.append( [ "class" : attributeDict["class"]!, "attack" : attributeDict["attack"]!, "zocRange" : attributeDict["zocRange"]!, "attackMinRange" : attributeDict["attackMinRange"]!, "attackMaxRange" : attributeDict["attackMaxRange"]! ])
            
        } }
        
    }
    func parser(_ parser: XMLParser,
                didEndElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?) {
        if elementName == "typeId" {
            if let typeId = Int8(xmlText) {
                currentUnit!.typeId = typeId
            }
            else { print("typeId in xml file \"\(xmlText)\" not a number") }
        }
        if elementName == "typeName" {
            // stringByTrimmingCharactersInSet( set : NSCharacterSet.ex) replaced by .trimmingCharacters() : Source 1
            currentUnit?.typeName = xmlText.trimmingCharacters(in : NSCharacterSet.whitespacesAndNewlines)
        }
        if elementName == "class" {
            currentUnit?.className = xmlText.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        }
        if elementName == "cost" {
            if let cost = Int(xmlText) {
                currentUnit?.cost = cost
            }
            else { print("cost in xml file \"\(xmlText)\" not a number") }
        }
        if elementName == "initialHealth" {
            if let initialHP = Int(xmlText) {
                currentUnit!.initialHealth = initialHP
            }
        }
        if elementName == "maxHealth" {
            if let maxHP = Int(xmlText) {
                currentUnit!.maxHealth = maxHP
            }
        }
        if elementName == "terrain" {
            if let enumForm = terrains( rawValue : xmlText ) {
                currentUnit!.capturableTerrain.append(enumForm)
            }
        }
        if elementName == "canOccupyEnemyTerrain" {
            if let boolOccupy = Bool(xmlText) {
                currentUnit?.canOccupyEnemyTerrain = boolOccupy }
        }
        if elementName == "canOccupyEnemyTerrain" {
            if let boolOccupy = Bool(xmlText) {
                currentUnit?.canOccupyEnemyTerrain = boolOccupy }
        }
        if elementName == "effects" {
            currentUnit?.effects = effects
            effectManagement = true
        }
        // this handles the end of the this unit class
        if elementName == "unit" && effectManagement {
            if let unit = currentUnit {
                units.append( unit )
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        xmlText += string
    }
}

import SpriteKit

let universcale : CGFloat = 4.7
var team_names : [String] = ["blue","red","green", "purple", "white","yellow"]

func teamfromNum( number : String ) -> colors? {
    if team_names.count < 1 {
    for name in colors.allCases {
        team_names.append( name.rawValue )
    } } // if the team_names has been constructed already, don't do again.
    if Int( number )! > 0 {
        return colors(rawValue: team_names[  Int( number  )! - 1  ] )} else {return nil} // (value nil is unnowned)
}

func createTerrainsfromXML( mapParsed : map ) -> [SIMD2<Int> : Terrain] {
    
    // Dec 21 map maker from terrain and unit dictionary, renamed to organize, since the inputs are more or less in the right form.
    let scale : CGFloat = bg_width * universcale // sprite scale factor ( times 100 )
    // this is to universalize the image sizes, I take one sprite image to measure dimensions so that this value isn't needlessly computed in loop
    let image_forsizing = terrain_textures[ [nil : "Base" ] ]!
    let image_width = image_forsizing.size().width * scale / 10000
    let image_height = image_forsizing.size().height * scale / 10000
    let sprite_size = CGSize(width : image_width, height : image_height )
    
    print("Converting map named \(mapParsed.name) by \(mapParsed.author) to terrains" )
    var terrains_out : [SIMD2<Int> : Terrain] = [:]
    // loops over the non occupied terrains
    
    for t in mapParsed.map_terrains {
        let curr_coord : SIMD2<Int> = SIMD2<Int>( x: Int(t["x"]!)!, y: Int(t["y"]!)! )
        if let curr_num =  t["startFaction"]  {
            let curr_color = teamfromNum( number : curr_num )
            let curr_tex = terrain_textures[ [ curr_color : t["type"]! ]  ]
            curr_tex!.filteringMode = .nearest
        // a lot can go wrong here
            let curr_terrain = Terrain(typeName: terrains(rawValue: t["type"]!)!,
                                       team_color : curr_color,
                                       init_Texture : curr_tex,
                                       size : sprite_size)
            curr_terrain.zPosition = 1
            terrains_out[curr_coord] = curr_terrain
        }
        else {
            if let curr_tex = terrain_textures[ [ nil : t["type"]! ] ] {
            curr_tex.filteringMode = .nearest
            let curr_terrain = Terrain(typeName: terrains( rawValue : t["type"]! )!,
                                       team_color: nil,
                                       init_Texture: curr_tex,
                                       size: sprite_size )
            curr_terrain.zPosition = 1
            terrains_out[curr_coord] = curr_terrain
            }
        }
    }
    return terrains_out
}

func createUnitsfromXML( mapParsed : map ) -> [ SIMD2<Int> : Unit ] {
    // Dec 21 map maker from terrain and unit dictionary, renamed to organize, since the inputs are more or less in the right form.
    let scale : CGFloat = bg_width * universcale  // sprite scale factor ( times 100 )
    // this is to universalize the image sizes, I take one sprite image to measure dimensions so that this value isn't needlessly computed in loop
    let image_forsizing = terrain_textures[ [nil : "Base" ]]
    let image_width = image_forsizing!.size().width * scale / 10000
    let image_height = image_forsizing!.size().height * scale / 10000
    let sprite_size = CGSize(width : image_width, height : image_height )
    
    print("Converting map named \(mapParsed.name) by \(mapParsed.author) to units" )
    var units_out : [SIMD2<Int> : Unit] = [:]
    // loops over the non occupied terrains
    
    for t in mapParsed.map_terrains {
        let curr_coord : SIMD2<Int> = SIMD2<Int>( x: Int(t["x"]!)!, y: Int(t["y"]!)! )
        if t["startUnit"] != "0" {
        
        if let startUnit = t["startUnit"] {
            if let startingOwner = Int( t["startUnitOwner"]! ) {
            let curr_tex = unit_textures[ [ colors(rawValue : team_names[ startingOwner ])! : startUnit  ]  ]
            curr_tex!.filteringMode = .nearest
        // a lot can go wrong here
            let curr_unit = Unit(typeName: units(rawValue: t["startUnit"]!)!,
                                       team_color : colors(rawValue: team_names[ startingOwner]),
                                       initialHealth: 10, // change later if necessary ?
                                       init_Texture : curr_tex,
                                       size : sprite_size)
                curr_unit.zPosition = 1
                units_out[curr_coord] = curr_unit }
            }
        }
        else {
            // no such thing as a unowned unit
        }
    }
    return units_out
}

func positionAllNodes( terrains : [SIMD2<Int> : Terrain], units : [SIMD2<Int> : Unit]?) -> [ SIMD2<Int> : [SKNode] ] {
    print( "positioning everything" )
    // Dec 21 map maker from terrain and unit dictionary, renamed to organize, since the inputs are more or less in the right form.
    var nodes_out : [SIMD2<Int> : [SKNode] ] = [:] // nodes_out declaration
    let scale : CGFloat = bg_width * universcale  // sprite scale factor ( times 100 )
    // this is to universalize the image sizes, I take one sprite image to measure dimensions so that this value isn't needlessly computed in loop
    let image_forsizing = terrain_textures[ [nil : "Base" ]]
    let image_width = image_forsizing!.size().width * scale / 10000
    let image_height = image_forsizing!.size().height * scale / 10000
//    let center = [ (image_forsizing!.size().width )/2, (image_forsizing!.size().height  - bg_height / 4)/2]
    let center = [ -bg_width / 7, -bg_width / 10]
    var hex_offset_x : CGFloat!
    // tile adding phase
    // to do : Make the drawing positions fit a generalized ratio of coordinates
    for t in terrains {
            // node offset ( to shift the hexagons correctly )
            hex_offset_x = CGFloat(image_width  / 2) *  CGFloat(t.key.y % 2 )
            // position based on hexagon centers
            t.value.position = CGPoint( x :  CGFloat( t.key.x ) * image_width + center[0] + hex_offset_x,
                                        y : CGFloat( t.key.y ) * image_height / CGFloat(1.3334)  + center[1] )
            // checks if the unit type is nil, or if the current position doesnt have a dictionary reference in from second param. "units"
            nodes_out[ t.key ] = [ t.value ]
    }
    if units != nil {
    for u in units! {
        u.value.position = nodes_out[ u.key ]![0].position
        let counter = SKSpriteNode( texture: hptextures[ Int(u.value.health - 1) ] )
        counter.size = CGSize( width : image_width, height: image_height)
        counter.position = nodes_out[ u.key ]![0].position
        counter.texture!.filteringMode = .nearest
        counter.zPosition = 2 // top
        nodes_out[ u.key ] = [ nodes_out[ u.key ]![0] , counter, u.value]
    }
    }
    else { }
    print("done positioning")
    return nodes_out
} // end of tile and map rendering function.

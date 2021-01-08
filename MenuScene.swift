//
//  MenuScene.swift
//  2Dgame1
//
//  Created by sebi d on 8.12.20.
//

import SceneKit
import GameplayKit

class MenuScene : SKScene {
//    low priority  : make let pretty_background
    let fancy_background = SKSpriteNode()
    let cookie_hex = SKSpriteNode(imageNamed: "green_hex.png")
    override func didMove(to view: SKView) {
        fancy_background.size = CGSize(width: bg_width, height: bg_height)
//        fancy_background.shader = hex_shader(WIDTH: bg_width, HEIGHT: bg_height, scale: CGSize(width: 10, height : 10) )
        fancy_background.zPosition = -100
//        addChild(fancy_background)
        
        cookie_hex.position = CGPoint(x: frame.midX, y : frame.midY)
        cookie_hex.size = CGSize(width: 36, height : 36)
        cookie_hex.shader = cookiecutter(psuedo: false)
        addChild(cookie_hex)
    }
    // custom non-node generating shader code.
    
    func hex_shader(WIDTH: CGFloat, HEIGHT: CGFloat, scale: CGSize) -> SKShader {
        var uniforms : [SKUniform] = [
            SKUniform(name: "u_width", float : Float(WIDTH)),
            SKUniform(name: "u_height", float : Float(HEIGHT)),
            SKUniform(name: "u_scalew", float : Float(scale.width) ),
            SKUniform(name: "u_scaleh", float : Float(scale.height) )

        ]
        for t in terrain_textures {
            let u_texture = SKUniform(name: "\(t.key)", texture : t.value)
            uniforms.append(u_texture)
        }
        
        let attributes : [SKAttribute] = [
            SKAttribute(name: "a_size", type : .vectorFloat2)]
        
        return SKShader(fromFile: "hexgridshader", uniforms: uniforms, attributes: attributes)
    }
    // hexagon cookie cutter declaration ( I used this to define the triangles to cut from the square to make a hexagon.)
    func cookiecutter(psuedo : Bool ) -> SKShader {
        var filename : String = "psuedoHexCutter"
        if psuedo {
            filename =  "psuedoHexCutter"
        }
        else {
          filename = "equilateralhex"
        }
        return SKShader( fromFile: filename)
    }
    
    override func update( _ atTime : TimeInterval) {
    }
}

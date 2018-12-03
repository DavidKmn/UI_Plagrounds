//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
view.backgroundColor = .white
PlaygroundPage.current.liveView = view


let shapeLayer = CAShapeLayer()
view.layer.addSublayer(shapeLayer)

let height = view.bounds.height * 0.4
let width = height * 0.6
let path = UIBezierPath()
path.move(to: CGPoint(x: 0, y: bounds.midY))
path.addLine(to: CGPoint(x: width, y: 0))
path.move(to: CGPoint(x: 0, y: bounds.midY))
path.addLine(to: CGPoint(x: width, y: height))

shapeLayer.path = path.cgPath
shapeLayer.fillColor = UIColor.yellow.cgColor
shapeLayer.strokeColor = UIColor.black.cgColor
shapeLayer.lineWidth = 6





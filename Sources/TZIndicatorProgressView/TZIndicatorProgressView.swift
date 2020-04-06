//
//  TZProgressView.swift
//  TZIndicatorProgressView
//
//  Created by Tasin Zarkoob on 06/04/2020.
//  Copyright © 2020 Tasin. All rights reserved.
//

import UIKit

struct TZIndicatorThemeConfig {
    /**CGFont for the labels.**Default is Helvitica***/
    var font: CGFont = CGFont("Helvetica" as CFString)!
    
    /**Font Size for the labels. **Default is 12** */
    var fontSize : CGFloat = 12.0
    
    /**Color for the inactive graphics like indicator or text.**Default is gray***/
    var inactiveColor = UIColor.gray
    
    /**Color for the active graphics like indicator or text.**Default is white***/
    var activeColor = UIColor.white
    
    /**Color for the completed graphics like indicator or text.**Default is green***/
    var completedColor = UIColor.green
    
    /**Radius of the indicator drawn.**Default is 5***/
    var indicatorRadius: CGFloat = 5
    
    /**LineWidth of the progress bar drawn.**Default is 3***/
    var lineWidth: CGFloat = 3
    
    /** Time Interval for Stroke Animation Duration. **Default is 0.75** */
    var strokeAnimationDuration: CFTimeInterval = 0.75
    
    init(){}
}

class TZIndicatorProgressView: UIView {
    var theme = TZIndicatorThemeConfig()
    var labels: [String] = [] {
        didSet {
            setupLayers()
        }
    }
    
    private var componentWidth : CGFloat {
        return self.bounds.width / CGFloat(labels.count)
    }
    private var componentCount: Int {
        return labels.count - 1
    }
    private var indicatorCenters: [CGPoint] = []
    private let inactiveLayer = CAShapeLayer()
    private let activeLayer = CAShapeLayer()
    private let completedLayer = CAShapeLayer()
    private var indicatorLayers : [CAShapeLayer] = []
    private var textLayers: [CATextLayer] = []
    private var currentIndex = 0
    private var previousCompletedIndex: Int?
    private var completedIndex: Int {
        return currentIndex - 1
    }
    
    private func setupLayers() {
        createIndicatorCenters()
        drawInactiveLayer()
        drawActiveLayer()
        drawCompletedLayer()
        drawIndicatorLayer()
        drawLabels()
    }
    
    private func createIndicatorCenters(){
        let componentHeight = self.bounds.height
        let tempComponentBox = CGRect(x: 0, y: 0, width: componentWidth, height: componentHeight)
        let firstIndicatorCenter = CGPoint(x: tempComponentBox.midX, y: tempComponentBox.midY)
        
        indicatorCenters.removeAll()
        for i in 0..<labels.count {
            let x = firstIndicatorCenter.x + (CGFloat(i) * componentWidth)
            let y = firstIndicatorCenter.y
            let point = CGPoint(x: x, y: y)
            indicatorCenters.append(point)
        }
        
    }
    
    private func drawInactiveLayer(){
        let path = CGMutablePath()
        path.addLines(between: [indicatorCenters[0], indicatorCenters[indicatorCenters.count-1]])
        inactiveLayer.strokeColor = theme.inactiveColor.cgColor
        inactiveLayer.lineWidth = theme.lineWidth
        inactiveLayer.strokeEnd = 1
        inactiveLayer.path = path
        self.layer.addSublayer(inactiveLayer)
    }
    
    private func drawActiveLayer(){
        let path = CGMutablePath()
        path.addLines(between: [indicatorCenters[0], indicatorCenters[indicatorCenters.count-1]])
        activeLayer.strokeColor = theme.activeColor.cgColor
        activeLayer.lineWidth = theme.lineWidth
        activeLayer.strokeStart = 0
        activeLayer.strokeEnd = 0
        activeLayer.path = path
        self.layer.addSublayer(activeLayer)
    }
    
    private func drawCompletedLayer(){
        let path = CGMutablePath()
        path.addLines(between: [indicatorCenters[0], indicatorCenters[indicatorCenters.count-1]])
        completedLayer.strokeColor = theme.completedColor.cgColor
        completedLayer.lineWidth = theme.lineWidth
        completedLayer.strokeStart = 0
        completedLayer.strokeEnd = 0
        completedLayer.path = path
        self.layer.addSublayer(completedLayer)
    }
    
    private func drawIndicatorLayer(){
        for point in indicatorCenters {
            let layer = CAShapeLayer()
            layer.path = UIBezierPath(arcCenter: point, radius: theme.indicatorRadius, startAngle: CGFloat(0.0), endAngle: CGFloat(Double.pi * 2), clockwise: true).cgPath
            layer.fillColor = theme.inactiveColor.cgColor
            indicatorLayers.append(layer)
            self.layer.addSublayer(layer)
        }
    }
    
    private func drawLabels(){
        for index in 0..<labels.count {
            let textLayer = CATextLayer()
            textLayer.foregroundColor = theme.inactiveColor.cgColor
            
            let string = labels[index]
            let centrePoint = indicatorCenters[index]
            let updatedPoint = CGPoint(x: centrePoint.x - (componentWidth/2), y: centrePoint.y + 10)
            textLayer.string = string
            textLayer.font = theme.font
            textLayer.fontSize = theme.fontSize
            textLayer.alignmentMode = CATextLayerAlignmentMode.center
            textLayer.display()
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.frame = CGRect(origin: updatedPoint, size: CGSize(width: componentWidth, height: 18))
            
            textLayers.append(textLayer)
            
            self.layer.addSublayer(textLayer)
        }
    }
    
    // MARK: -
    func move(to index: Int) {
        previousCompletedIndex = completedIndex
        currentIndex = index
        updateLayers()
    }
    
    private func updateLayers() {
        if completedIndex >= 0 {
            let completedEnd = CGFloat(completedIndex)/CGFloat(componentCount)
            let completedLayerAnimation = pathAnimation
            completedLayerAnimation.toValue = completedEnd
            if let previousIndex = previousCompletedIndex {
                completedLayerAnimation.fromValue = CGFloat(previousIndex)/CGFloat(componentCount)
            }
            completedLayer.add(completedLayerAnimation, forKey: "strokeEndAnimation")
            for i in 0...completedIndex {
                indicatorLayers[i].fillColor = theme.completedColor.cgColor
                textLayers[i].foregroundColor = theme.completedColor.cgColor
            }
        } else {
            let completedEnd = 0.0
            let completedLayerAnimation = pathAnimation
            completedLayerAnimation.toValue = completedEnd
            completedLayer.add(completedLayerAnimation, forKey: "strokeEndAnimation")
        }
        let activeLayerAnimation = pathAnimation
        let activeEnd = CGFloat(currentIndex)/CGFloat(componentCount)
        activeLayerAnimation.toValue = activeEnd
        activeLayerAnimation.fromValue = CGFloat(completedIndex)/CGFloat(componentCount)
        activeLayer.add(activeLayerAnimation, forKey: "strokeEndAnimation")
        indicatorLayers[currentIndex].fillColor = theme.activeColor.cgColor
        textLayers[currentIndex].foregroundColor = theme.activeColor.cgColor
        
        for i in (currentIndex+1)..<indicatorLayers.count {
            indicatorLayers[i].fillColor = theme.inactiveColor.cgColor
            textLayers[i].foregroundColor = theme.inactiveColor.cgColor
        }
    }
    
    private var pathAnimation: CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = theme.strokeAnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.fillMode = .both
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    func nextIndex() {
        previousCompletedIndex = completedIndex
        currentIndex += 1
        updateLayers()
    }

    
}

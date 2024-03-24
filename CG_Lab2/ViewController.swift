//
//  ViewController.swift
//  CG_Lab2
//
//  Created by Lubomyr Chorniak on 05.03.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let startPoint: PointView = {
        let view = PointView(origin: CGPoint(x: 100, y: 350))
        view.backgroundColor = .blue
        return view
    }()
    
    let endPoint: PointView = {
        let view = PointView(origin: CGPoint(x: 350, y: 380))
        view.backgroundColor = .blue
        return view
    }()
    
    lazy var controlPoints: [PointView] = {
        return [startPoint ,controlPoint1, controlPoint2, endPoint]
    }()
    
    let controlPoint1: PointView = {
        let view = PointView(origin: CGPoint(x: 200, y: 200))
        return view
    }()
    
    let controlPoint2: PointView = {
        let view = PointView(origin: CGPoint(x: 300, y: 100))
        return view
    }()
    
    let canvasView = CanvasView()
//    let pickerView = UIPickerView()
    
//    let data = ["Параметричний", "Матричний"]

    private func addPoint(point: UIView) {
        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.addTarget(self, action: #selector(onPointDoubleTapped))
        point.addGestureRecognizer(doubleTapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.minimumPressDuration = 0.1
        longPressGesture.addTarget(self, action: #selector(onPointLongPressed))
        point.addGestureRecognizer(longPressGesture)
        
        canvasView.addSubview(point)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(canvasView)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .yellow
        canvasView.snp.makeConstraints { make in
            make.leading.top.bottom.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        for point in controlPoints {
            addPoint(point: point)
        }
        
        let tapGstureRecognizer = UITapGestureRecognizer()
        tapGstureRecognizer.numberOfTapsRequired = 2
        tapGstureRecognizer.numberOfTouchesRequired = 1
        tapGstureRecognizer.addTarget(self, action: #selector(onCanvasDoubleTapped))
        canvasView.addGestureRecognizer(tapGstureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        canvasView.controlPoints.append(contentsOf: controlPoints.map{ $0.center })
        canvasView.setNeedsDisplay()
    }
    
    @objc func onCanvasDoubleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let pointToAdd = gestureRecognizer.location(in: canvasView)
        let point = PointView(origin: pointToAdd)
        addPoint(point: point)
        canvasView.controlPoints.insert(point.center, at: canvasView.controlPoints.endIndex - 1)
        controlPoints.insert(point, at: controlPoints.endIndex - 1)
        canvasView.setNeedsDisplay()
    }
    
    @objc func onPointLongPressed(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard let controlPoint = gestureRecognizer.view else { return }
        
        switch gestureRecognizer.state {
        case .began:
            UIView.animate(withDuration: 0.05) {
                controlPoint.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
            return
        case .ended:
            UIView.animate(withDuration: 0.05) {
                controlPoint.transform = .identity
            }
            return
        @unknown default:
            break
        }

        if gestureRecognizer.state == .changed {
            
            let location = gestureRecognizer.location(in: canvasView)
            controlPoint.center = location
            
            for index in 0..<controlPoints.count {
                if controlPoint === controlPoints[index] {
                    canvasView.controlPoints[index] = controlPoint.center
                }
            }

            canvasView.setNeedsDisplay()
        }
    }
    
    @objc func onPointDoubleTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let controlPoint  = gestureRecognizer.view else { return }
        guard controlPoint !== startPoint && controlPoint !== endPoint else { return }
        controlPoint.removeFromSuperview()
        
        for index in 0..<controlPoints.count {
            if controlPoint === controlPoints[index] {
                canvasView.controlPoints.remove(at: index)
                controlPoints.remove(at: index)
                break
            }
        }
        
        canvasView.setNeedsDisplay()
    }
    
    
    
    // MARK: - UIPickerViewDataSource
    
    private func showAlert(_ message: String? = nil) {
        let alertController = UIAlertController(title: "Error Happended", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }


}

class PointView: UIView {
    
    init(origin: CGPoint) {
        let size: CGFloat = 40
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
        layer.cornerRadius = size / 2.0
        backgroundColor = .gray
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let expandedBounds = CGRect(x: -5, y: -5, width: self.frame.width + 10, height: self.frame.height + 10)
        if expandedBounds.contains(point) {
          return self
        } else {
          return super.hitTest(point, with: event)
        }
    }
    
}

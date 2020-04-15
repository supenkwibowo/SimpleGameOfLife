//
//  ViewController.swift
//  SimpleGameOfLife
//
//  Created by Sugeng Wibowo on 15/04/20.
//  Copyright © 2020 Sugeng Wibowo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var worldView: WorldView!
    
    deinit {
        serialDisposable.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private let serialDisposable = SerialDisposable()
    @IBAction func onTapStart(_ sender: UIButton) {
        let initial = initialWorld()
        serialDisposable.disposable = Observable<Int>
            .interval(.milliseconds(50), scheduler: MainScheduler.instance)
            .scan(initial) { previousWorld, _ in
                newGeneration(previousGeneration: previousWorld)
            }
            .startWith(initial)
            .bind { [weak self] world in
                self?.worldView.world = world
                self?.worldView.setNeedsDisplay()
            }
    }
    
    private func initialWorld() -> World {
        let initialCellPositions = randomAliveCellPosition(size: World.size)
        var board: [[Bool]] = World().board
        initialCellPositions.forEach { position in
            board[position.y][position.x] = true
        }
        return World(board)
    }
    
    private func randomAliveCellPosition(size: World.Size) -> [CellPosition] {
        let randomAliveCell = 10000
        return (1...randomAliveCell).map { _ in
            CellPosition(x: Int.random(in: 0..<size.vertical),
                         y: Int.random(in: 0..<size.horizontal))
        }
    }
    
    private struct CellPosition: Equatable {
        let x: Int
        let y: Int
    }
}

final class WorldView: UIView {
    
    var world: World?
    @IBInspectable var cellColor: UIColor?
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(),
            let world = world
            else { return }
        let pixelSize = self.pixelSize(of: World.size)
        context.setFillColor((cellColor ?? .white).cgColor)
        let cells = world.board.enumerated().flatMap { horizontal in
            horizontal.element.enumerated().compactMap { cell -> CGPoint? in
                guard cell.element else { return nil }
                return CGPoint(x: CGFloat(cell.offset) * pixelSize.width,
                               y: CGFloat(horizontal.offset) * pixelSize.height)
            }.map { CGRect(origin: $0, size: pixelSize) }
        }
        context.addRects(cells)
        context.drawPath(using: .fill)
    }
    
    private func pixelSize(of worldSize: World.Size) -> CGSize {
        let viewSize = frame.size
        return CGSize(
            width: viewSize.width / CGFloat(worldSize.horizontal),
            height: viewSize.height / CGFloat(worldSize.vertical)
        )
    }
}

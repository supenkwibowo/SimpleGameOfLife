//
//  World.swift
//  SimpleGameOfLife
//
//  Created by Sugeng Wibowo on 15/04/20.
//  Copyright © 2020 Sugeng Wibowo. All rights reserved.
//

import Foundation

struct World {
    let board: [[Bool]]
    static let size: Size = .init(horizontal: 300, vertical: 300)
    
    init(_ board: [[Bool]]) {
        self.board = board
    }
    
    init() {
        board = (0..<World.size.horizontal)
            .map { _ in (0..<World.size.vertical).map { _ in false } }
    }
    
    struct Size {
        let horizontal: Int
        let vertical: Int
    }
}

func newGeneration(previousGeneration: World) -> World {
    func numberOfNeighbour(x: Int, y: Int) -> Int {
        let trailingX = x - 1
        let trailingY = y - 1
        let leadingX = x + 1
        let leadingY = y + 1
        
        var neighbour = 0
        if trailingX >= 0 {
            if previousGeneration.board[y][trailingX] {
                neighbour += 1
            }
            if trailingY >= 0 && previousGeneration.board[trailingY][trailingX] {
                neighbour += 1
            }
            if leadingY < World.size.horizontal && previousGeneration.board[leadingY][trailingX] {
                neighbour += 1
            }
        }
        if leadingX < World.size.vertical {
            if previousGeneration.board[y][leadingX] {
                neighbour += 1
            }
            if trailingY >= 0 && previousGeneration.board[trailingY][leadingX] {
                neighbour += 1
            }
            if leadingY < World.size.horizontal && previousGeneration.board[leadingY][leadingX] {
                neighbour += 1
            }
        }
        if trailingY >= 0 && previousGeneration.board[trailingY][x] {
            neighbour += 1
        }
        if leadingY < World.size.horizontal && previousGeneration.board[leadingY][x] {
            neighbour += 1
        }
        return neighbour
    }
    return World(previousGeneration.board.enumerated().map { horizontal in
        horizontal.element.enumerated().map { cell in
            switch (cell.element, numberOfNeighbour(x: cell.offset, y: horizontal.offset)) {
            case (false, 3): return true
            case (true, 2...3): return true
            default: return false
            }
        }
    })
}

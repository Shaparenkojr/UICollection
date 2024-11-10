//
//  ViewController.swift
//  UICollectionViewLayout
//
//  Created by Тарас Шапаренко on 06.11.2024.
//

enum Alignment {
    case center
    case left
    case right
}

struct Data {
    let alignment: Alignment
    let elements: [[Size]]
}

enum Size: Float {
    case small = 0.2
    case normal = 0.4
}

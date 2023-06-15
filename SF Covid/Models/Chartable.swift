//
//  Chartable.swift
//  SF Covid
//
//  Created by Michael Critz on 6/14/23.
//

import Foundation

protocol Chartable: Codable {
    var count: Int? { get }
    var lastUpdated: Date { get }
    var title: String { get }
}

//
//  ScrollViewOffsetPreferenceKey.swift
//  ScrollViewDynamicBackground
//
//  Created by Alexandre MONTCUIT on 06/07/2023.
//

import Foundation
import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

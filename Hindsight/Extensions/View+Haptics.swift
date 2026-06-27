//
//  View+Haptics.swift
//  Hindsight
//
//  Ergonomic SwiftUI sugar over HapticsManager. Lets a view fire a
//  toggle-respecting haptic whenever a value changes — handy for tab and
//  page transitions where there's no single button action to hook into.
//

import SwiftUI

extension View {

    /// Plays `pattern` (respecting the user's haptics preference) whenever
    /// `trigger` changes value. Handy for tab / page transitions where
    /// there's no single button action to hook into.
    func haptics<T: Equatable>(_ pattern: HapticPattern, trigger: T) -> some View {
        onChange(of: trigger) { _, _ in
            HapticsManager.shared.play(pattern)
        }
    }
}

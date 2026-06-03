import SwiftUI

enum MomentumMotion {
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.82)
    static let layoutMorph = Animation.spring(response: 0.4, dampingFraction: 0.85)
    static let panelEnter = Animation.spring(response: 0.35, dampingFraction: 0.78)
    static let exportFly = Animation.spring(response: 0.55, dampingFraction: 0.72)
}

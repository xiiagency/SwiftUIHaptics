#if os(macOS)

import SwiftFoundationExtensions
import os

/**
 A macOS implementation of the haptics player.
 
 NOTE: Currently a no-op that always returns false for `isAvailable` and does nothing when starting/stopping or playing an event.
 */
class HapticsPlayer {
  private static let logger: Logger = .loggerFor(HapticsPlayer.self)
  
  /**
   NOTE: We currently do not support haptics feedback on macOS.
   */
  static let isAvailable: Bool = false
  
  /**
   NOTE: We currently do not support haptics feedback on macOS, this is a no-op.
   */
  func start() {}
  
  /**
   NOTE: We currently do not support haptics feedback on macOS, this is a no-op.
   */
  func stop() {}
  
  /**
   NOTE: We currently do not support haptics feedback on macOS.
   */
  func play(event: HapticEvent) {
    Self.logger.warning("No haptics support on MacOS.")
  }
}

#endif

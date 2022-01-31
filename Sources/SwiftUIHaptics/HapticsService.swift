import SwiftFoundationExtensions
import SwiftUI
import os

/**
 A service that integrates to the device's haptics engine, if it is available.
 
 NOTE: The haptics feedback are only implemented for iOS/watchOS, but not on macOS.
       The play function will not produce feedback and will return control right away.
 */
public class HapticsService : ObservableObject {
  private static let logger: Logger = .loggerFor(HapticsService.self)
  
  /**
   Return true if the device supports haptic feedback, false otherwise.
   */
  public var isAvailable: Bool {
    HapticsPlayer.isAvailable
  }
  
  // The underlying, platform-specific, haptics player.
  private let player: HapticsPlayer = HapticsPlayer()
  
  public init() {
    initialize()
  }
  
  deinit {
    deinitialize()
  }
  
  /**
   Called when the service is initialized, initializes the `HapticsPlayer` for the current platform.
   
   NOTE: Implemented as a separate fileprivate func in order to allow for the mock of this service to override the initialization process.
   */
  fileprivate func initialize() {
    player.start()
  }
  
  /**
   Called when the service is de-initialized, de-initializes the `HapticsPlayer` for the current platform.
   
   NOTE: Implemented as a separate fileprivate func in order to allow for the mock of this service to override the de-initialization process.
   */
  fileprivate func deinitialize() {
    player.stop()
  }
  
  /**
   Plays a pattern of haptic events using the current haptics player, if haptics are supported.
   */
  public func play(event: HapticEvent) {
    player.play(event: event)
  }
}

#if DEBUG
/**
 Provides the ability to create a "mock" `HapticsService` to be used in preview code.
 */
public class MockHapticsService : HapticsService {
  override func initialize() {
    // no-op, blocks default initializer.
  }
  
  override func deinitialize() {
    // no-op, blocks default shutdown.
  }
  
  public var isAvailableCallback: () -> Bool = { true }
  public var playCallback: (HapticEvent) -> Void = { _ in Void() }
  
  public override var isAvailable: Bool {
    isAvailableCallback()
  }
  
  public override func play(event: HapticEvent) {
    playCallback(event)
  }
}
#endif

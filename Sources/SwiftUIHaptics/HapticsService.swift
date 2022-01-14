import CoreHaptics
import SwiftFoundationExtensions
import SwiftUI
import os

/**
 A service that integrates to the device's haptics engine, if it is available.
 */
public class HapticsService : ObservableObject {
  private static let logger: Logger = .loggerFor(HapticsService.self)
  
  /**
   True if the device supports haptic feedback, false otherwise.
   */
  public private(set) var isAvailable: Bool = CHHapticEngine.capabilitiesForHardware()
    .supportsHaptics
  
  /**
   The currently initialized haptics engine.
   */
  private var currentEngine: CHHapticEngine? = nil
  
  public init() {
    initialize()
  }
  
  deinit {
    deinitialize()
  }
  
  /**
   Called when the service is initialized, subscribes to foreground/background notifications and initializes the haptics engine.
   
   NOTE: Implemented as a separate fileprivate func in order to allow for the mock of this service to override the initialization process.
   */
  fileprivate func initialize() {
    startReceivingAppStatusNotifications()
    setupEngine()
  }
  
  /**
   Called when the service is de-initialized, unsubscribes to foreground/background notifications.
   
   NOTE: Implemented as a separate fileprivate func in order to allow for the mock of this service to override the de-initialization process.
   */
  fileprivate func deinitialize() {
    stopReceivingAppStatusNotifications()
  }
  
  /**
   Called to subscribe to notifications of the app entering/exiting foreground so that we can start/shutdown the haptics engine to match.
   */
  private func startReceivingAppStatusNotifications() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(setupEngine),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(shutdownEngine),
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
  }
  
  /**
   Called when de-initialized to unsubscribe from foreground/background notifications.
   */
  private func stopReceivingAppStatusNotifications() {
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
    
    NotificationCenter.default.removeObserver(
      self,
      name: UIApplication.willResignActiveNotification,
      object: nil
    )
  }
  
  /**
   Sets up the device's haptic engine. Called when this service is initialized or whenever the app returns to foreground.
   */
  @objc
  private func setupEngine() {
    shutdownEngine()
    
    do {
      let engine = try CHHapticEngine()
      engine.start(
        completionHandler: { [self] error in
          if let error = error {
            Self.logger.error("Error starting haptics engine: \(error.description, privacy: .public)")
            return
          }
          
          currentEngine = engine
        }
      )
    } catch {
      Self.logger.error("Error creating haptics engine: \(error.description, privacy: .public)")
    }
  }
  
  /**
   Shuts down the haptic engine. Called whenever the app enters background.
   */
  @objc
  private func shutdownEngine() {
    guard let engine = currentEngine else {
      return
    }
    
    engine.stop(
      completionHandler: { [self] error in
        if let error = error {
          Self.logger.error("Error occurred shutting down haptics engine: \(error.description, privacy: .public)")
        }
        
        currentEngine = nil
      }
    )
  }
  
  /**
   Plays a pattern of haptic events using the current haptics engine, if it is defined and haptics are supported.
   */
  public func play(event: HapticEvent) {
    guard let engine = currentEngine else {
      return
    }
    
    do {
      let pattern = try CHHapticPattern(events: event.underlyingEvents, parameters: [])
      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      Self.logger.error("Error attempting to play haptics pattern: \(error.description, privacy: .public)")
    }
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

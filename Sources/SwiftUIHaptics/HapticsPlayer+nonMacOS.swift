#if !os(macOS)

import CoreHaptics
import SwiftFoundationExtensions
import SwiftUI
import os

/**
 The UIKit implementation of the `HapticsPlayer`, utilizing CoreHaptics.
 */
class HapticsPlayer {
  private static let logger: Logger = .loggerFor(HapticsPlayer.self)
  
  /**
   Returns true if the device supports haptic feedback, false otherwise.
   */
  static var isAvailable: Bool {
    CHHapticEngine.capabilitiesForHardware().supportsHaptics
  }
  
  /**
   The currently initialized haptics engine.
   */
  private var currentEngine: CHHapticEngine? = nil
  
  /**
   Subscribes to foreground/background notifications and initializes the haptics engine.
   */
  func start() {
    startReceivingAppStatusNotifications()
    setupEngine()
  }
  
  /**
   Unsubscribes to foreground/background notifications.
   */
  func stop() {
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
  func play(event: HapticEvent) {
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

#endif

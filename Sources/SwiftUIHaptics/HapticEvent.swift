import CoreHaptics

/**
 A struct containing a series of `CHHapticEvent`s to be played via the `HapticsService`.
 */
public struct HapticEvent {
  /**
   The underlying events to be played.
   */
  public let underlyingEvents: [CHHapticEvent]
}

public extension HapticEvent {
  /**
   Creates a single `HapticEvent`, with the ability to specify all the parameters and defaulting others.
   */
  static func single(
    intensity: Float? = nil,
    sharpness: Float? = nil,
    attack: Float? = nil,
    decay: Float? = nil,
    release: Float? = nil,
    sustained: Float? = nil,
    relativeTime: TimeInterval = 0.0,
    duration: TimeInterval = 0.0
  ) -> HapticEvent {
    var hapticsParameters: [CHHapticEventParameter] = []
    if let intensity = intensity {
      hapticsParameters.append(
        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
      )
    }
    
    if let sharpness = sharpness {
      hapticsParameters.append(
        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
      )
    }
    
    if let attack = attack {
      hapticsParameters.append(
        CHHapticEventParameter(parameterID: .attackTime, value: attack)
      )
    }
    
    if let decay = decay {
      hapticsParameters.append(
        CHHapticEventParameter(parameterID: .decayTime, value: decay)
      )
    }
    
    if let release = release {
      hapticsParameters.append(
        CHHapticEventParameter(parameterID: .releaseTime, value: release)
      )
    }
    
    if let sustained = sustained {
      hapticsParameters.append(
        CHHapticEventParameter(parameterID: .sustained, value: sustained)
      )
    }
    
    return HapticEvent(
      underlyingEvents: [
        CHHapticEvent(
          eventType: .hapticTransient,
          parameters: hapticsParameters,
          relativeTime: relativeTime,
          duration: duration
        )
      ]
    )
  }
  
  /**
   Creates a pattern of haptic events by combining all underlying events for the provided `HapticEvent` instances.
   */
  static func pattern(events: [HapticEvent]) -> HapticEvent {
    let combinedUnderlyingEvents: [CHHapticEvent] = events.flatMap { event in
      event.underlyingEvents
    }
    
    return HapticEvent(underlyingEvents: combinedUnderlyingEvents)
  }
  
  /**
   Creates a pattern of haptic events by combining all underlying events for the provided `HapticEvent` instances.
   */
  static func pattern(_ events: HapticEvent...) -> HapticEvent {
    pattern(events: events)
  }
  
  /**
   Returns a time shifted `HapticEvent` with the provided relative time and play duration specified.
   */
  func timeShifted(relativeTime: TimeInterval, duration: TimeInterval) -> HapticEvent {
    let shiftedUnderlyingEvents: [CHHapticEvent] = underlyingEvents.map { event in
      CHHapticEvent(
        eventType: .hapticTransient,
        parameters: event.eventParameters,
        relativeTime: relativeTime,
        duration: duration
      )
    }
    
    return HapticEvent(underlyingEvents: shiftedUnderlyingEvents)
  }
}

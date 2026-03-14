# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module AttentionSpotlight
      module Helpers
        class AttentionTarget
          include Constants

          attr_reader   :id, :label, :domain, :created_at
          attr_accessor :salience, :relevance, :in_spotlight, :in_periphery,
                        :capture_count, :last_attended_at

          def initialize(label:, domain:, salience: 0.5, relevance: 0.5)
            @id             = SecureRandom.uuid
            @label          = label
            @domain         = domain
            @salience       = salience.clamp(0.0, 1.0)
            @relevance      = relevance.clamp(0.0, 1.0)
            @in_spotlight   = false
            @in_periphery   = false
            @capture_count  = 0
            @created_at     = Time.now.utc
            @last_attended_at = nil
          end

          def compelling?
            @salience >= Constants::CAPTURE_THRESHOLD
          end

          def salient?
            @salience >= Constants::PERIPHERAL_DETECTION_THRESHOLD
          end

          def to_h
            {
              id:               @id,
              label:            @label,
              domain:           @domain,
              salience:         @salience.round(10),
              relevance:        @relevance.round(10),
              in_spotlight:     @in_spotlight,
              in_periphery:     @in_periphery,
              capture_count:    @capture_count,
              compelling:       compelling?,
              salient:          salient?,
              created_at:       @created_at,
              last_attended_at: @last_attended_at
            }
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionSpotlight
      module Helpers
        class Spotlight
          include Constants

          attr_reader :center_target_id, :intensity, :breadth, :mode

          def initialize
            @center_target_id = nil
            @intensity        = Constants::DEFAULT_INTENSITY
            @breadth          = Constants::DEFAULT_BREADTH
            @mode             = :idle
          end

          def focus_on!(target_id)
            @center_target_id = target_id
            @mode             = :focused
            @intensity        = (@intensity + Constants::INTENSITY_GAIN).clamp(0.0, 1.0).round(10)
          end

          def broaden!
            @breadth    = (@breadth + Constants::ZOOM_STEP).clamp(0.0, 1.0).round(10)
            @intensity  = (@intensity - Constants::INTENSITY_LOSS).clamp(0.0, 1.0).round(10)
            @mode       = :scanning if @mode == :focused
          end

          def narrow!
            @breadth    = (@breadth - Constants::ZOOM_STEP).clamp(0.0, 1.0).round(10)
            @intensity  = (@intensity + Constants::INTENSITY_GAIN).clamp(0.0, 1.0).round(10)
            @mode       = :focused if @center_target_id && @mode == :scanning
          end

          def capture!(target_id)
            @center_target_id = target_id
            @mode             = :captured
            @intensity        = 1.0
          end

          def release!
            @center_target_id = nil
            @mode             = :idle
            @intensity        = Constants::DEFAULT_INTENSITY
            @breadth          = Constants::DEFAULT_BREADTH
          end

          def zoom_level
            entry = Constants::ZOOM_RANGES.find { |z| z[:range].cover?(@breadth) }
            entry&.fetch(:level, :moderate) || :moderate
          end

          def intensity_label
            entry = Constants::INTENSITY_LABELS.find { |il| il[:range].cover?(@intensity) }
            entry&.fetch(:label, :moderate) || :moderate
          end

          def to_h
            {
              center_target_id: @center_target_id,
              intensity:        @intensity.round(10),
              breadth:          @breadth.round(10),
              mode:             @mode,
              zoom_level:       zoom_level,
              intensity_label:  intensity_label
            }
          end
        end
      end
    end
  end
end

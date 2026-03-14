# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionSpotlight
      module Helpers
        module Constants
          MAX_TARGETS                    = 200
          MAX_PERIPHERAL                 = 100
          DEFAULT_INTENSITY              = 0.5
          DEFAULT_BREADTH                = 0.5
          ZOOM_STEP                      = 0.1
          INTENSITY_GAIN                 = 0.15
          INTENSITY_LOSS                 = 0.1
          PERIPHERAL_DETECTION_THRESHOLD = 0.3
          CAPTURE_THRESHOLD              = 0.8

          ZOOM_LEVELS = %i[laser narrow moderate wide diffuse].freeze
          MODE_LABELS = %i[focused scanning captured idle].freeze

          ZOOM_RANGES = [
            { range: (0.0..0.2),  level: :laser    },
            { range: (0.21..0.4), level: :narrow   },
            { range: (0.41..0.6), level: :moderate },
            { range: (0.61..0.8), level: :wide     },
            { range: (0.81..1.0), level: :diffuse  }
          ].freeze

          INTENSITY_LABELS = [
            { range: (0.8..1.0),  label: :blazing  },
            { range: (0.6..0.79), label: :bright   },
            { range: (0.4..0.59), label: :moderate },
            { range: (0.2..0.39), label: :dim      },
            { range: (0.0..0.19), label: :dark     }
          ].freeze
        end
      end
    end
  end
end

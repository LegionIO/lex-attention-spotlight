# lex-attention-spotlight

**Level 3 Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Grandparent**: `/Users/miverso2/rubymine/legion/CLAUDE.md`

## Purpose

Spotlight model of attention (Posner + Eriksen zoom lens) for brain-modeled agentic AI. Models attention as a movable spotlight with adjustable breadth — narrow/intense for focused processing or wide/diffuse for broad scanning. Implements Posner's spatial metaphor and Eriksen's zoom-lens model where narrowing the beam increases processing intensity on the focused target.

## Gem Info

- **Gem name**: `lex-attention-spotlight`
- **Version**: `0.1.0`
- **Module**: `Legion::Extensions::AttentionSpotlight`
- **Ruby**: `>= 3.4`
- **License**: MIT

## File Structure

```
lib/legion/extensions/attention_spotlight/
  attention_spotlight.rb          # Main extension module
  version.rb                      # VERSION = '0.1.0'
  client.rb                       # Client wrapper
  helpers/
    constants.rb                  # Intensity/breadth defaults, zoom levels, mode labels, thresholds
    attention_target.rb           # AttentionTarget value object
    spotlight.rb                  # Spotlight — position, intensity, breadth management
    spotlight_engine.rb           # SpotlightEngine — manages targets + spotlight state
  runners/
    attention_spotlight.rb        # Runner module with 10 public methods
spec/
  (spec files)
```

## Key Constants

```ruby
MAX_TARGETS                    = 200
MAX_PERIPHERAL                 = 100
DEFAULT_INTENSITY              = 0.5
DEFAULT_BREADTH                = 0.5
ZOOM_STEP                      = 0.1
INTENSITY_GAIN                 = 0.15    # focusing increases intensity
INTENSITY_LOSS                 = 0.1     # releasing focus reduces intensity
PERIPHERAL_DETECTION_THRESHOLD = 0.3    # salience above this appears in periphery
CAPTURE_THRESHOLD              = 0.8    # automatic attention capture threshold

ZOOM_LEVELS = %i[laser narrow moderate wide diffuse]
MODE_LABELS = %i[focused scanning captured idle]
ZOOM_RANGES = [
  { range: (0.0..0.2),  level: :laser    },
  { range: (0.21..0.4), level: :narrow   },
  ...
  { range: (0.81..1.0), level: :diffuse  }
]
INTENSITY_LABELS = [{ range: (0.8..1.0), label: :blazing }, ... { range: (0.0..0.19), label: :dark }]
```

## Runners

### `Runners::AttentionSpotlight`

All methods delegate to a private `@engine` (`Helpers::SpotlightEngine` instance). All methods wrap in `rescue StandardError`.

- `register_target(label:, domain:, salience: 0.5, relevance: 0.5)` — register an attention target
- `focus_spotlight(target_id:)` — move spotlight to target; increases intensity by `INTENSITY_GAIN`
- `broaden_spotlight` — increase breadth by `ZOOM_STEP`
- `narrow_spotlight` — decrease breadth by `ZOOM_STEP`
- `scan_targets` — scan all registered targets; captures any above `CAPTURE_THRESHOLD`
- `check_peripheral` — list targets in the peripheral zone
- `check_capture` — check if any target exceeds `CAPTURE_THRESHOLD` and triggers involuntary capture
- `release_focus` — move spotlight away from current target; reduces intensity
- `spotlight_report` — comprehensive report: mode, intensity, breadth, zoom_level, current focus
- `most_salient(limit: 5)` — top targets by salience
- `spotlight_state` — full state hash

## Helpers

### `Helpers::SpotlightEngine`
Core engine managing `@targets`, `@spotlight` (Spotlight object), and mode. `scan` iterates targets, promotes to peripheral those above threshold, and captures those above `CAPTURE_THRESHOLD`. `check_peripheral` returns targets in the peripheral zone sorted by salience.

### `Helpers::Spotlight`
Geometric spotlight model: breadth (0–1, maps to zoom level) and intensity (0–1, maps to brightness label). `broaden` and `narrow` adjust breadth by `ZOOM_STEP`.

### `Helpers::AttentionTarget`
Value object: label, domain, salience, relevance, detected_at.

## Integration Points

No actor defined. Part of the attention family alongside lex-attention (filtering), lex-attention-regulation (executive control), lex-attention-schema (self-modeling), and lex-attention-economy (budget). The spotlight model is the geometric layer — breadth determines how wide the conscious beam is, intensity determines processing depth. In lex-cortex wiring, spotlight state can gate which memory traces and predictions receive full processing budget.

## Development Notes

- `scan_targets` handles both peripheral detection and capture in a single pass
- `CAPTURE_THRESHOLD = 0.8` is high — only very salient events trigger involuntary capture
- All runner methods wrap in rescue StandardError, making errors recoverable without crashing the tick
- Intensity and breadth are independent axes: narrow+blazing = laser-focused deep processing; wide+dim = broad shallow monitoring

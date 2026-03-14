# lex-attention-spotlight

Spotlight model of attention (Posner + Eriksen zoom lens) for brain-modeled agentic AI.

## What It Does

Models attention as a movable spotlight with adjustable breadth and intensity. Based on Posner's spatial metaphor (attention is a spotlight that can be moved) and Eriksen's zoom-lens model (narrowing the beam increases processing intensity on the focused target). The spotlight can be manually directed, broadened or narrowed, and can be captured involuntarily by high-salience stimuli.

## Core Concept: Zoom Lens

Breadth and intensity are independent controls:
- **Narrow + high intensity (`:laser`)**: deep focused processing of one target
- **Wide + low intensity (`:diffuse`)**: broad shallow monitoring across many targets
- **Automatic capture**: stimuli above salience 0.8 pull the spotlight involuntarily

## Usage

```ruby
client = Legion::Extensions::AttentionSpotlight::Client.new

# Register targets
client.register_target(label: :security_event, domain: :security, salience: 0.9)
client.register_target(label: :health_metrics, domain: :monitoring, salience: 0.3)

# Focus on a specific target
client.focus_spotlight(target_id: security_event_id)

# Narrow for deep processing
client.narrow_spotlight
client.narrow_spotlight  # zoom_level: :narrow

# Check what's in the periphery
client.check_peripheral
# => { peripheral_targets: [...], count: 1 }

# Scan for high-salience capture events
client.scan_targets
# => { mode: :captured, captured: { label: :security_event, salience: 0.9 } }

# Get full state
client.spotlight_report
# => { mode: :focused, intensity: 0.65, breadth: 0.3, zoom_level: :narrow }
```

## Integration

Part of the full attention stack: lex-attention (filtering) → lex-attention-regulation (executive control) → lex-attention-spotlight (geometric model) → lex-attention-schema (self-modeling).

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT

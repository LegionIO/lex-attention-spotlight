# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionSpotlight::Helpers::SpotlightEngine do
  subject(:engine) { described_class.new }

  def register(label: 'task', domain: :work, salience: 0.5, relevance: 0.5)
    engine.register_target(label: label, domain: domain, salience: salience, relevance: relevance)
  end

  describe '#initialize' do
    it 'starts with empty targets' do
      expect(engine.targets).to be_empty
    end

    it 'starts with a Spotlight instance' do
      expect(engine.spotlight).to be_a(Legion::Extensions::AttentionSpotlight::Helpers::Spotlight)
    end

    it 'starts with empty peripheral' do
      expect(engine.peripheral).to be_empty
    end
  end

  describe '#register_target' do
    it 'registers a target and returns a target_id' do
      result = register
      expect(result[:registered]).to be true
      expect(result[:target_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores the target in @targets' do
      result = register
      expect(engine.targets).to have_key(result[:target_id])
    end

    it 'respects MAX_TARGETS limit' do
      stub_const('Legion::Extensions::AttentionSpotlight::Helpers::Constants::MAX_TARGETS', 2)
      register(label: 'a')
      register(label: 'b')
      result = register(label: 'c')
      expect(result[:registered]).to be false
      expect(result[:reason]).to eq(:max_targets_reached)
    end

    it 'returns the label and domain' do
      result = register(label: 'my task', domain: :health)
      expect(result[:label]).to eq('my task')
      expect(result[:domain]).to eq(:health)
    end
  end

  describe '#focus' do
    it 'focuses on a registered target' do
      id = register[:target_id]
      result = engine.focus(target_id: id)
      expect(result[:focused]).to be true
      expect(result[:mode]).to eq(:focused)
    end

    it 'marks the target as in_spotlight' do
      id = register[:target_id]
      engine.focus(target_id: id)
      expect(engine.targets[id].in_spotlight).to be true
    end

    it 'returns not_found for unknown target_id' do
      result = engine.focus(target_id: 'nonexistent')
      expect(result[:focused]).to be false
      expect(result[:reason]).to eq(:not_found)
    end

    it 'sets last_attended_at on the target' do
      id = register[:target_id]
      engine.focus(target_id: id)
      expect(engine.targets[id].last_attended_at).to be_a(Time)
    end

    it 'clears previous spotlight focus when refocusing' do
      id1 = register(label: 'first')[:target_id]
      id2 = register(label: 'second')[:target_id]
      engine.focus(target_id: id1)
      engine.focus(target_id: id2)
      expect(engine.targets[id1].in_spotlight).to be false
    end
  end

  describe '#broaden' do
    it 'increases spotlight breadth' do
      initial = engine.spotlight.breadth
      engine.broaden
      expect(engine.spotlight.breadth).to be > initial
    end

    it 'returns broadened true with zoom_level' do
      result = engine.broaden
      expect(result[:broadened]).to be true
      expect(result).to have_key(:zoom_level)
    end
  end

  describe '#narrow' do
    it 'decreases spotlight breadth' do
      engine.broaden
      before = engine.spotlight.breadth
      engine.narrow
      expect(engine.spotlight.breadth).to be < before
    end

    it 'returns narrowed true with zoom_level' do
      result = engine.narrow
      expect(result[:narrowed]).to be true
      expect(result).to have_key(:zoom_level)
    end
  end

  describe '#scan' do
    it 'sets spotlight mode to scanning' do
      3.times { |i| register(label: "task #{i}") }
      engine.scan
      expect(engine.spotlight.mode).to eq(:scanning)
    end

    it 'returns targets_swept count' do
      3.times { |i| register(label: "task #{i}") }
      result = engine.scan
      expect(result[:targets_swept]).to eq(3)
    end

    it 'marks all targets as attended' do
      ids = 3.times.map { |i| register(label: "task #{i}")[:target_id] }
      engine.scan
      ids.each do |id|
        expect(engine.targets[id].last_attended_at).to be_a(Time)
      end
    end
  end

  describe '#check_peripheral' do
    it 'detects salient targets outside spotlight' do
      register(label: 'salient', salience: 0.6)
      engine.check_peripheral
      expect(engine.peripheral).not_to be_empty
    end

    it 'does not detect targets below threshold' do
      register(label: 'low', salience: 0.1)
      engine.check_peripheral
      expect(engine.peripheral).to be_empty
    end

    it 'marks detected targets as in_periphery' do
      id = register(label: 'salient', salience: 0.6)[:target_id]
      engine.check_peripheral
      expect(engine.targets[id].in_periphery).to be true
    end

    it 'respects MAX_PERIPHERAL limit' do
      stub_const('Legion::Extensions::AttentionSpotlight::Helpers::Constants::MAX_PERIPHERAL', 2)
      5.times { |i| register(label: "t#{i}", salience: 0.8) }
      result = engine.check_peripheral
      expect(result[:detected]).to be <= 2
    end
  end

  describe '#check_capture' do
    it 'returns captured false when no compelling target exists' do
      register(label: 'low', salience: 0.3)
      result = engine.check_capture
      expect(result[:captured]).to be false
    end

    it 'captures the most salient compelling target' do
      register(label: 'high', salience: 0.9)
      result = engine.check_capture
      expect(result[:captured]).to be true
      expect(result[:salience]).to eq(0.9)
    end

    it 'sets spotlight mode to captured' do
      register(label: 'urgent', salience: 0.85)
      engine.check_capture
      expect(engine.spotlight.mode).to eq(:captured)
    end

    it 'increments capture_count on the captured target' do
      id = register(label: 'urgent', salience: 0.85)[:target_id]
      engine.check_capture
      expect(engine.targets[id].capture_count).to eq(1)
    end

    it 'does not capture the currently spotlighted target' do
      id = register(label: 'current', salience: 0.9)[:target_id]
      engine.focus(target_id: id)
      register(label: 'other', salience: 0.85)
      result = engine.check_capture
      expect(result[:target_id]).not_to eq(id)
    end
  end

  describe '#release_focus' do
    it 'returns released true' do
      result = engine.release_focus
      expect(result[:released]).to be true
    end

    it 'clears all spotlight flags' do
      id = register(label: 'focused')[:target_id]
      engine.focus(target_id: id)
      engine.release_focus
      expect(engine.targets[id].in_spotlight).to be false
    end

    it 'sets spotlight mode to idle' do
      engine.release_focus
      expect(engine.spotlight.mode).to eq(:idle)
    end
  end

  describe '#targets_in_spotlight' do
    it 'returns empty when no focus is set' do
      register(label: 'x')
      expect(engine.targets_in_spotlight).to be_empty
    end

    it 'returns the focused target' do
      id = register(label: 'focused task')[:target_id]
      engine.focus(target_id: id)
      result = engine.targets_in_spotlight
      ids = result.map(&:id)
      expect(ids).to include(id)
    end
  end

  describe '#most_salient' do
    it 'returns targets ordered by salience descending' do
      register(label: 'low', salience: 0.2)
      register(label: 'high', salience: 0.9)
      register(label: 'mid', salience: 0.5)
      result = engine.most_salient(limit: 3)
      expect(result.map(&:salience)).to eq([0.9, 0.5, 0.2])
    end

    it 'respects the limit parameter' do
      5.times { |i| register(label: "t#{i}", salience: i * 0.1) }
      expect(engine.most_salient(limit: 2).size).to eq(2)
    end
  end

  describe '#spotlight_report' do
    it 'includes spotlight, in_spotlight, in_periphery, most_salient, total_targets' do
      register(label: 'x', salience: 0.6)
      report = engine.spotlight_report
      expect(report.keys).to include(:spotlight, :in_spotlight, :in_periphery, :most_salient, :total_targets)
    end

    it 'includes peripheral_count' do
      register(label: 'p', salience: 0.6)
      engine.check_peripheral
      report = engine.spotlight_report
      expect(report).to have_key(:peripheral_count)
    end
  end

  describe '#to_h' do
    it 'returns a hash with spotlight and target_count' do
      h = engine.to_h
      expect(h.keys).to include(:spotlight, :target_count, :peripheral_count, :spotlight_targets)
    end

    it 'reflects correct target_count' do
      3.times { |i| register(label: "t#{i}") }
      expect(engine.to_h[:target_count]).to eq(3)
    end
  end
end

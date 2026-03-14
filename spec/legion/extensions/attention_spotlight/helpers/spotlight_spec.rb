# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionSpotlight::Helpers::Spotlight do
  subject(:spotlight) { described_class.new }

  describe '#initialize' do
    it 'starts with nil center_target_id' do
      expect(spotlight.center_target_id).to be_nil
    end

    it 'starts with default intensity' do
      expect(spotlight.intensity).to eq(0.5)
    end

    it 'starts with default breadth' do
      expect(spotlight.breadth).to eq(0.5)
    end

    it 'starts in idle mode' do
      expect(spotlight.mode).to eq(:idle)
    end
  end

  describe '#focus_on!' do
    it 'sets center_target_id' do
      spotlight.focus_on!('abc-123')
      expect(spotlight.center_target_id).to eq('abc-123')
    end

    it 'sets mode to :focused' do
      spotlight.focus_on!('abc-123')
      expect(spotlight.mode).to eq(:focused)
    end

    it 'increases intensity by INTENSITY_GAIN' do
      initial = spotlight.intensity
      spotlight.focus_on!('abc-123')
      expect(spotlight.intensity).to be > initial
    end

    it 'does not exceed 1.0 intensity when already high' do
      spotlight.instance_variable_set(:@intensity, 0.95)
      spotlight.focus_on!('abc-123')
      expect(spotlight.intensity).to eq(1.0)
    end
  end

  describe '#broaden!' do
    it 'increases breadth by ZOOM_STEP' do
      initial = spotlight.breadth
      spotlight.broaden!
      expect(spotlight.breadth).to be_within(0.001).of(initial + 0.1)
    end

    it 'decreases intensity by INTENSITY_LOSS' do
      initial = spotlight.intensity
      spotlight.broaden!
      expect(spotlight.intensity).to be_within(0.001).of(initial - 0.1)
    end

    it 'does not exceed 1.0 breadth' do
      spotlight.instance_variable_set(:@breadth, 0.95)
      spotlight.broaden!
      expect(spotlight.breadth).to eq(1.0)
    end

    it 'does not go below 0.0 intensity' do
      spotlight.instance_variable_set(:@intensity, 0.05)
      spotlight.broaden!
      expect(spotlight.intensity).to eq(0.0)
    end

    it 'transitions focused mode to scanning' do
      spotlight.focus_on!('abc-123')
      spotlight.broaden!
      expect(spotlight.mode).to eq(:scanning)
    end
  end

  describe '#narrow!' do
    it 'decreases breadth by ZOOM_STEP' do
      spotlight.instance_variable_set(:@breadth, 0.5)
      spotlight.narrow!
      expect(spotlight.breadth).to be_within(0.001).of(0.4)
    end

    it 'increases intensity by INTENSITY_GAIN' do
      initial = spotlight.intensity
      spotlight.narrow!
      expect(spotlight.intensity).to be > initial
    end

    it 'does not go below 0.0 breadth' do
      spotlight.instance_variable_set(:@breadth, 0.05)
      spotlight.narrow!
      expect(spotlight.breadth).to eq(0.0)
    end
  end

  describe '#capture!' do
    it 'sets center_target_id to the captured target' do
      spotlight.capture!('urgent-task')
      expect(spotlight.center_target_id).to eq('urgent-task')
    end

    it 'sets mode to :captured' do
      spotlight.capture!('urgent-task')
      expect(spotlight.mode).to eq(:captured)
    end

    it 'sets intensity to 1.0' do
      spotlight.capture!('urgent-task')
      expect(spotlight.intensity).to eq(1.0)
    end
  end

  describe '#release!' do
    it 'clears center_target_id' do
      spotlight.focus_on!('some-target')
      spotlight.release!
      expect(spotlight.center_target_id).to be_nil
    end

    it 'resets mode to :idle' do
      spotlight.focus_on!('some-target')
      spotlight.release!
      expect(spotlight.mode).to eq(:idle)
    end

    it 'resets intensity to default' do
      spotlight.focus_on!('some-target')
      spotlight.release!
      expect(spotlight.intensity).to eq(0.5)
    end

    it 'resets breadth to default' do
      spotlight.broaden!
      spotlight.release!
      expect(spotlight.breadth).to eq(0.5)
    end
  end

  describe '#zoom_level' do
    it 'returns :laser for breadth 0.0' do
      spotlight.instance_variable_set(:@breadth, 0.0)
      expect(spotlight.zoom_level).to eq(:laser)
    end

    it 'returns :moderate for default breadth 0.5' do
      expect(spotlight.zoom_level).to eq(:moderate)
    end

    it 'returns :diffuse for breadth 1.0' do
      spotlight.instance_variable_set(:@breadth, 1.0)
      expect(spotlight.zoom_level).to eq(:diffuse)
    end

    it 'returns :narrow for breadth 0.3' do
      spotlight.instance_variable_set(:@breadth, 0.3)
      expect(spotlight.zoom_level).to eq(:narrow)
    end

    it 'returns :wide for breadth 0.7' do
      spotlight.instance_variable_set(:@breadth, 0.7)
      expect(spotlight.zoom_level).to eq(:wide)
    end
  end

  describe '#intensity_label' do
    it 'returns :blazing for intensity 0.9' do
      spotlight.instance_variable_set(:@intensity, 0.9)
      expect(spotlight.intensity_label).to eq(:blazing)
    end

    it 'returns :dark for intensity 0.1' do
      spotlight.instance_variable_set(:@intensity, 0.1)
      expect(spotlight.intensity_label).to eq(:dark)
    end

    it 'returns :moderate for intensity 0.5' do
      expect(spotlight.intensity_label).to eq(:moderate)
    end
  end

  describe '#to_h' do
    it 'returns all expected keys' do
      h = spotlight.to_h
      expect(h.keys).to include(:center_target_id, :intensity, :breadth, :mode, :zoom_level, :intensity_label)
    end

    it 'includes current mode' do
      spotlight.focus_on!('x')
      expect(spotlight.to_h[:mode]).to eq(:focused)
    end
  end
end

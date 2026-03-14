# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionSpotlight::Helpers::Constants do
  subject(:mod) { described_class }

  describe 'numeric constants' do
    it 'has MAX_TARGETS = 200' do
      expect(mod::MAX_TARGETS).to eq(200)
    end

    it 'has MAX_PERIPHERAL = 100' do
      expect(mod::MAX_PERIPHERAL).to eq(100)
    end

    it 'has DEFAULT_INTENSITY = 0.5' do
      expect(mod::DEFAULT_INTENSITY).to eq(0.5)
    end

    it 'has DEFAULT_BREADTH = 0.5' do
      expect(mod::DEFAULT_BREADTH).to eq(0.5)
    end

    it 'has ZOOM_STEP = 0.1' do
      expect(mod::ZOOM_STEP).to eq(0.1)
    end

    it 'has INTENSITY_GAIN = 0.15' do
      expect(mod::INTENSITY_GAIN).to eq(0.15)
    end

    it 'has INTENSITY_LOSS = 0.1' do
      expect(mod::INTENSITY_LOSS).to eq(0.1)
    end

    it 'has PERIPHERAL_DETECTION_THRESHOLD = 0.3' do
      expect(mod::PERIPHERAL_DETECTION_THRESHOLD).to eq(0.3)
    end

    it 'has CAPTURE_THRESHOLD = 0.8' do
      expect(mod::CAPTURE_THRESHOLD).to eq(0.8)
    end
  end

  describe 'array constants' do
    it 'has 5 ZOOM_LEVELS' do
      expect(mod::ZOOM_LEVELS).to eq(%i[laser narrow moderate wide diffuse])
    end

    it 'has 4 MODE_LABELS' do
      expect(mod::MODE_LABELS).to eq(%i[focused scanning captured idle])
    end
  end

  describe 'ZOOM_RANGES' do
    it 'covers 0.0 with :laser' do
      entry = mod::ZOOM_RANGES.find { |z| z[:range].cover?(0.0) }
      expect(entry[:level]).to eq(:laser)
    end

    it 'covers 0.5 with :moderate' do
      entry = mod::ZOOM_RANGES.find { |z| z[:range].cover?(0.5) }
      expect(entry[:level]).to eq(:moderate)
    end

    it 'covers 1.0 with :diffuse' do
      entry = mod::ZOOM_RANGES.find { |z| z[:range].cover?(1.0) }
      expect(entry[:level]).to eq(:diffuse)
    end
  end

  describe 'INTENSITY_LABELS' do
    it 'covers 0.9 with :blazing' do
      entry = mod::INTENSITY_LABELS.find { |il| il[:range].cover?(0.9) }
      expect(entry[:label]).to eq(:blazing)
    end

    it 'covers 0.1 with :dark' do
      entry = mod::INTENSITY_LABELS.find { |il| il[:range].cover?(0.1) }
      expect(entry[:label]).to eq(:dark)
    end
  end
end

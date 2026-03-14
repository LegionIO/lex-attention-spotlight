# frozen_string_literal: true

RSpec.describe Legion::Extensions::AttentionSpotlight::Helpers::AttentionTarget do
  subject(:target) { described_class.new(label: 'test task', domain: :work) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(target.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets label' do
      expect(target.label).to eq('test task')
    end

    it 'sets domain' do
      expect(target.domain).to eq(:work)
    end

    it 'defaults salience to 0.5' do
      expect(target.salience).to eq(0.5)
    end

    it 'defaults relevance to 0.5' do
      expect(target.relevance).to eq(0.5)
    end

    it 'starts with in_spotlight false' do
      expect(target.in_spotlight).to be false
    end

    it 'starts with in_periphery false' do
      expect(target.in_periphery).to be false
    end

    it 'starts with capture_count 0' do
      expect(target.capture_count).to eq(0)
    end

    it 'sets created_at' do
      expect(target.created_at).to be_a(Time)
    end

    it 'starts with last_attended_at nil' do
      expect(target.last_attended_at).to be_nil
    end

    it 'clamps salience above 1.0' do
      t = described_class.new(label: 'x', domain: :test, salience: 2.5)
      expect(t.salience).to eq(1.0)
    end

    it 'clamps salience below 0.0' do
      t = described_class.new(label: 'x', domain: :test, salience: -0.5)
      expect(t.salience).to eq(0.0)
    end

    it 'clamps relevance to valid range' do
      t = described_class.new(label: 'x', domain: :test, relevance: 1.5)
      expect(t.relevance).to eq(1.0)
    end
  end

  describe '#compelling?' do
    it 'returns false when salience is below capture threshold' do
      target.salience = 0.7
      expect(target.compelling?).to be false
    end

    it 'returns true when salience meets capture threshold' do
      target.salience = 0.8
      expect(target.compelling?).to be true
    end

    it 'returns true when salience exceeds capture threshold' do
      target.salience = 0.95
      expect(target.compelling?).to be true
    end
  end

  describe '#salient?' do
    it 'returns false when salience is below peripheral detection threshold' do
      target.salience = 0.2
      expect(target.salient?).to be false
    end

    it 'returns true when salience meets peripheral detection threshold' do
      target.salience = 0.3
      expect(target.salient?).to be true
    end

    it 'returns true when salience exceeds threshold' do
      target.salience = 0.6
      expect(target.salient?).to be true
    end
  end

  describe '#to_h' do
    it 'returns a hash with all expected keys' do
      h = target.to_h
      expect(h.keys).to include(:id, :label, :domain, :salience, :relevance,
                                 :in_spotlight, :in_periphery, :capture_count,
                                 :compelling, :salient, :created_at, :last_attended_at)
    end

    it 'rounds salience to 10 decimal places' do
      target.salience = 1.0 / 3.0
      h = target.to_h
      expect(h[:salience]).to eq((1.0 / 3.0).round(10))
    end

    it 'includes computed compelling value' do
      target.salience = 0.9
      expect(target.to_h[:compelling]).to be true
    end

    it 'includes computed salient value' do
      target.salience = 0.05
      expect(target.to_h[:salient]).to be false
    end
  end
end

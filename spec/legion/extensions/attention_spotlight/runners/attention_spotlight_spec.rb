# frozen_string_literal: true

require 'legion/extensions/attention_spotlight/client'

RSpec.describe Legion::Extensions::AttentionSpotlight::Runners::AttentionSpotlight do
  let(:client) { Legion::Extensions::AttentionSpotlight::Client.new }

  def reg(label: 'task', domain: :work, salience: 0.5, relevance: 0.5)
    client.register_target(label: label, domain: domain, salience: salience, relevance: relevance)
  end

  describe '#register_target' do
    it 'returns success true on valid registration' do
      result = reg
      expect(result[:success]).to be true
    end

    it 'returns a target_id uuid' do
      result = reg
      expect(result[:target_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'includes label in result' do
      result = reg(label: 'my task')
      expect(result[:label]).to eq('my task')
    end

    it 'includes domain in result' do
      result = reg(domain: :health)
      expect(result[:domain]).to eq(:health)
    end
  end

  describe '#focus_spotlight' do
    it 'returns success true when focusing on a known target' do
      id = reg[:target_id]
      result = client.focus_spotlight(target_id: id)
      expect(result[:success]).to be true
    end

    it 'returns focused true' do
      id = reg[:target_id]
      result = client.focus_spotlight(target_id: id)
      expect(result[:focused]).to be true
    end

    it 'returns success false for unknown target' do
      result = client.focus_spotlight(target_id: 'unknown-id')
      expect(result[:success]).to be false
    end

    it 'returns not_found reason for unknown target' do
      result = client.focus_spotlight(target_id: 'unknown-id')
      expect(result[:reason]).to eq(:not_found)
    end

    it 'sets spotlight mode to focused' do
      id = reg[:target_id]
      client.focus_spotlight(target_id: id)
      result = client.spotlight_state
      expect(result[:spotlight][:mode]).to eq(:focused)
    end
  end

  describe '#broaden_spotlight' do
    it 'returns success true' do
      result = client.broaden_spotlight
      expect(result[:success]).to be true
    end

    it 'returns broadened true' do
      result = client.broaden_spotlight
      expect(result[:broadened]).to be true
    end

    it 'increases breadth' do
      initial = client.spotlight_state[:spotlight][:breadth]
      client.broaden_spotlight
      after = client.spotlight_state[:spotlight][:breadth]
      expect(after).to be > initial
    end
  end

  describe '#narrow_spotlight' do
    it 'returns success true' do
      result = client.narrow_spotlight
      expect(result[:success]).to be true
    end

    it 'returns narrowed true' do
      result = client.narrow_spotlight
      expect(result[:narrowed]).to be true
    end

    it 'decreases breadth when already broadened' do
      client.broaden_spotlight
      before = client.spotlight_state[:spotlight][:breadth]
      client.narrow_spotlight
      after = client.spotlight_state[:spotlight][:breadth]
      expect(after).to be < before
    end
  end

  describe '#scan_targets' do
    it 'returns success true' do
      expect(client.scan_targets[:success]).to be true
    end

    it 'returns scanning true' do
      expect(client.scan_targets[:scanning]).to be true
    end

    it 'returns correct targets_swept count' do
      3.times { |i| reg(label: "t#{i}") }
      result = client.scan_targets
      expect(result[:targets_swept]).to eq(3)
    end
  end

  describe '#check_peripheral' do
    it 'returns success true' do
      expect(client.check_peripheral[:success]).to be true
    end

    it 'returns detected count' do
      reg(label: 'salient', salience: 0.7)
      result = client.check_peripheral
      expect(result[:detected]).to be >= 1
    end

    it 'detects no targets when salience is below threshold' do
      reg(label: 'low', salience: 0.1)
      result = client.check_peripheral
      expect(result[:detected]).to eq(0)
    end

    it 'includes peripheral_ids array' do
      result = client.check_peripheral
      expect(result[:peripheral_ids]).to be_an(Array)
    end
  end

  describe '#check_capture' do
    it 'returns success true' do
      expect(client.check_capture[:success]).to be true
    end

    it 'returns captured false when no compelling target' do
      reg(label: 'low', salience: 0.3)
      expect(client.check_capture[:captured]).to be false
    end

    it 'captures a compelling target' do
      reg(label: 'urgent', salience: 0.9)
      result = client.check_capture
      expect(result[:captured]).to be true
    end

    it 'returns target_id of captured target' do
      id = reg(label: 'urgent', salience: 0.9)[:target_id]
      result = client.check_capture
      expect(result[:target_id]).to eq(id)
    end
  end

  describe '#release_focus' do
    it 'returns success true' do
      expect(client.release_focus[:success]).to be true
    end

    it 'returns released true' do
      expect(client.release_focus[:released]).to be true
    end

    it 'sets mode back to idle' do
      id = reg[:target_id]
      client.focus_spotlight(target_id: id)
      client.release_focus
      expect(client.spotlight_state[:spotlight][:mode]).to eq(:idle)
    end
  end

  describe '#spotlight_report' do
    it 'returns success true' do
      expect(client.spotlight_report[:success]).to be true
    end

    it 'includes total_targets count' do
      3.times { |i| reg(label: "t#{i}") }
      expect(client.spotlight_report[:total_targets]).to eq(3)
    end

    it 'includes spotlight hash' do
      expect(client.spotlight_report[:spotlight]).to be_a(Hash)
    end

    it 'includes in_spotlight array' do
      expect(client.spotlight_report[:in_spotlight]).to be_an(Array)
    end

    it 'includes most_salient array' do
      expect(client.spotlight_report[:most_salient]).to be_an(Array)
    end
  end

  describe '#most_salient' do
    it 'returns success true' do
      expect(client.most_salient[:success]).to be true
    end

    it 'returns ordered targets by salience' do
      reg(label: 'low', salience: 0.2)
      reg(label: 'high', salience: 0.9)
      result = client.most_salient(limit: 2)
      saliences = result[:targets].map { |t| t[:salience] }
      expect(saliences.first).to be > saliences.last
    end

    it 'respects limit parameter' do
      5.times { |i| reg(label: "t#{i}") }
      expect(client.most_salient(limit: 3)[:count]).to eq(3)
    end

    it 'defaults to limit 5' do
      7.times { |i| reg(label: "t#{i}") }
      expect(client.most_salient[:count]).to eq(5)
    end
  end

  describe '#spotlight_state' do
    it 'returns success true' do
      expect(client.spotlight_state[:success]).to be true
    end

    it 'includes spotlight hash' do
      expect(client.spotlight_state[:spotlight]).to be_a(Hash)
    end

    it 'includes target_count' do
      3.times { |i| reg(label: "t#{i}") }
      expect(client.spotlight_state[:target_count]).to eq(3)
    end

    it 'reflects changes after focus' do
      id = reg[:target_id]
      client.focus_spotlight(target_id: id)
      state = client.spotlight_state
      expect(state[:spotlight][:center_target_id]).to eq(id)
    end
  end
end

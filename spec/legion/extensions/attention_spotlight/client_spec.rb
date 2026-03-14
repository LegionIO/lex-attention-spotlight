# frozen_string_literal: true

require 'legion/extensions/attention_spotlight/client'

RSpec.describe Legion::Extensions::AttentionSpotlight::Client do
  it 'responds to all runner methods' do
    client = described_class.new
    expect(client).to respond_to(:register_target)
    expect(client).to respond_to(:focus_spotlight)
    expect(client).to respond_to(:broaden_spotlight)
    expect(client).to respond_to(:narrow_spotlight)
    expect(client).to respond_to(:scan_targets)
    expect(client).to respond_to(:check_peripheral)
    expect(client).to respond_to(:check_capture)
    expect(client).to respond_to(:release_focus)
    expect(client).to respond_to(:spotlight_report)
    expect(client).to respond_to(:most_salient)
    expect(client).to respond_to(:spotlight_state)
  end

  it 'accepts an injected engine' do
    engine = Legion::Extensions::AttentionSpotlight::Helpers::SpotlightEngine.new
    client = described_class.new(engine: engine)
    expect(client.spotlight_state[:success]).to be true
  end

  it 'uses an internal engine when none injected' do
    client = described_class.new
    expect(client.spotlight_state[:success]).to be true
  end
end

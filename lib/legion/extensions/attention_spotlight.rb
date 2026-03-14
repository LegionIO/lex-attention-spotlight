# frozen_string_literal: true

require 'legion/extensions/attention_spotlight/version'
require 'legion/extensions/attention_spotlight/helpers/constants'
require 'legion/extensions/attention_spotlight/helpers/attention_target'
require 'legion/extensions/attention_spotlight/helpers/spotlight'
require 'legion/extensions/attention_spotlight/helpers/spotlight_engine'
require 'legion/extensions/attention_spotlight/runners/attention_spotlight'

module Legion
  module Extensions
    module AttentionSpotlight
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end

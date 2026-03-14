# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionSpotlight
      module Runners
        module AttentionSpotlight
          include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                      Legion::Extensions::Helpers.const_defined?(:Lex)

          def register_target(label:, domain:, salience: 0.5, relevance: 0.5, **)
            Legion::Logging.debug "[attention_spotlight] register target label=#{label} domain=#{domain}"
            result = engine.register_target(label: label, domain: domain,
                                            salience: salience, relevance: relevance)
            { success: result[:registered], **result }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] register_target error: #{e.message}"
            { success: false, error: e.message }
          end

          def focus_spotlight(target_id:, **)
            Legion::Logging.debug "[attention_spotlight] focus target_id=#{target_id[0..7]}"
            result = engine.focus(target_id: target_id)
            { success: result[:focused], **result }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] focus_spotlight error: #{e.message}"
            { success: false, error: e.message }
          end

          def broaden_spotlight(**)
            Legion::Logging.debug '[attention_spotlight] broadening spotlight'
            result = engine.broaden
            { success: true, **result }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] broaden_spotlight error: #{e.message}"
            { success: false, error: e.message }
          end

          def narrow_spotlight(**)
            Legion::Logging.debug '[attention_spotlight] narrowing spotlight'
            result = engine.narrow
            { success: true, **result }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] narrow_spotlight error: #{e.message}"
            { success: false, error: e.message }
          end

          def scan_targets(**)
            Legion::Logging.debug '[attention_spotlight] initiating scan'
            result = engine.scan
            { success: true, **result }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] scan_targets error: #{e.message}"
            { success: false, error: e.message }
          end

          def check_peripheral(**)
            Legion::Logging.debug '[attention_spotlight] checking periphery'
            result = engine.check_peripheral
            { success: true, **result }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] check_peripheral error: #{e.message}"
            { success: false, error: e.message }
          end

          def check_capture(**)
            Legion::Logging.debug '[attention_spotlight] checking for attention capture'
            result = engine.check_capture
            { success: true, **result }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] check_capture error: #{e.message}"
            { success: false, error: e.message }
          end

          def release_focus(**)
            Legion::Logging.debug '[attention_spotlight] releasing focus'
            result = engine.release_focus
            { success: true, **result }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] release_focus error: #{e.message}"
            { success: false, error: e.message }
          end

          def spotlight_report(**)
            Legion::Logging.debug '[attention_spotlight] generating report'
            report = engine.spotlight_report
            { success: true, **report }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] spotlight_report error: #{e.message}"
            { success: false, error: e.message }
          end

          def most_salient(limit: 5, **)
            Legion::Logging.debug "[attention_spotlight] most_salient limit=#{limit}"
            targets = engine.most_salient(limit: limit)
            { success: true, targets: targets.map(&:to_h), count: targets.size }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] most_salient error: #{e.message}"
            { success: false, error: e.message }
          end

          def spotlight_state(**)
            { success: true, **engine.to_h }
          rescue StandardError => e
            Legion::Logging.error "[attention_spotlight] spotlight_state error: #{e.message}"
            { success: false, error: e.message }
          end

          private

          def engine
            @engine ||= Helpers::SpotlightEngine.new
          end
        end
      end
    end
  end
end

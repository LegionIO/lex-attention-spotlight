# frozen_string_literal: true

module Legion
  module Extensions
    module AttentionSpotlight
      module Helpers
        class SpotlightEngine
          include Constants

          attr_reader :targets, :spotlight, :peripheral

          def initialize
            @targets    = {}
            @spotlight  = Spotlight.new
            @peripheral = []
          end

          def register_target(label:, domain:, salience: 0.5, relevance: 0.5)
            return { registered: false, reason: :max_targets_reached, limit: Constants::MAX_TARGETS } if @targets.size >= Constants::MAX_TARGETS

            target = AttentionTarget.new(label: label, domain: domain,
                                         salience: salience, relevance: relevance)
            @targets[target.id] = target
            { registered: true, target_id: target.id, label: label, domain: domain }
          end

          def focus(target_id:)
            target = @targets[target_id]
            return { focused: false, reason: :not_found } unless target

            clear_spotlight_flags
            @spotlight.focus_on!(target_id)
            target.in_spotlight = true
            target.last_attended_at = Time.now.utc
            { focused: true, target_id: target_id, mode: @spotlight.mode, intensity: @spotlight.intensity }
          end

          def broaden
            @spotlight.broaden!
            mark_spotlight_coverage
            { broadened: true, breadth: @spotlight.breadth, zoom_level: @spotlight.zoom_level }
          end

          def narrow
            @spotlight.narrow!
            mark_spotlight_coverage
            { narrowed: true, breadth: @spotlight.breadth, zoom_level: @spotlight.zoom_level }
          end

          def scan
            @spotlight.instance_variable_set(:@mode, :scanning)
            mark_spotlight_coverage
            sorted = @targets.values.sort_by { |t| -t.salience }
            sorted.each { |t| t.last_attended_at = Time.now.utc }
            { scanning: true, targets_swept: sorted.size }
          end

          def check_peripheral
            outside = @targets.values.reject(&:in_spotlight)
            detected = outside.select(&:salient?).first(Constants::MAX_PERIPHERAL)
            @peripheral = detected.map(&:id)
            detected.each { |t| t.in_periphery = true }
            (outside - detected).each { |t| t.in_periphery = false }
            { detected: @peripheral.size, peripheral_ids: @peripheral }
          end

          def check_capture
            candidate = @targets.values
                                .reject(&:in_spotlight)
                                .select(&:compelling?)
                                .max_by(&:salience)
            return { captured: false } unless candidate

            clear_spotlight_flags
            @spotlight.capture!(candidate.id)
            candidate.in_spotlight = true
            candidate.capture_count += 1
            candidate.last_attended_at = Time.now.utc
            mark_spotlight_coverage
            { captured: true, target_id: candidate.id, salience: candidate.salience }
          end

          def release_focus
            clear_spotlight_flags
            @spotlight.release!
            { released: true }
          end

          def targets_in_spotlight
            @targets.values.select(&:in_spotlight)
          end

          def peripheral_alerts
            @peripheral.filter_map { |id| @targets[id] }
          end

          def most_salient(limit: 5)
            @targets.values.sort_by { |t| -t.salience }.first(limit)
          end

          def spotlight_report
            {
              spotlight:        @spotlight.to_h,
              in_spotlight:     targets_in_spotlight.map(&:to_h),
              in_periphery:     peripheral_alerts.map(&:to_h),
              most_salient:     most_salient.map(&:to_h),
              total_targets:    @targets.size,
              peripheral_count: @peripheral.size
            }
          end

          def to_h
            {
              spotlight:         @spotlight.to_h,
              target_count:      @targets.size,
              peripheral_count:  @peripheral.size,
              spotlight_targets: targets_in_spotlight.map(&:to_h)
            }
          end

          private

          def clear_spotlight_flags
            @targets.each_value { |t| t.in_spotlight = false }
          end

          def covered_target_ids
            center_id = @spotlight.center_target_id
            return [] unless center_id
            return [center_id] if @spotlight.breadth <= 0.2

            count = breadth_to_count(@spotlight.breadth)
            sorted_by_salience = @targets.values.sort_by { |t| -t.salience }
            candidates = sorted_by_salience.first(count)
            result = [center_id]
            candidates.each { |t| result << t.id unless result.include?(t.id) }
            result.first(count)
          end

          def breadth_to_count(breadth)
            return 1  if breadth <= 0.2
            return 3  if breadth <= 0.4
            return 7  if breadth <= 0.6
            return 15 if breadth <= 0.8

            [30, @targets.size].min
          end

          def mark_spotlight_coverage
            covered = covered_target_ids.to_set
            @targets.each_value do |t|
              t.in_spotlight = covered.include?(t.id)
            end
          end
        end
      end
    end
  end
end

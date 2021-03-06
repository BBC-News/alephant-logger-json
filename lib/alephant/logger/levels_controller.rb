module Alephant
  module Logger
    class LevelsController
      # Ruby 1.x syntax used to support JRuby 1.7.x
      # rubocop:disable Style/SymbolArray
      LEVELS = [:debug, :info, :warn, :error].freeze
      # rubocop:enable Style/SymbolArray

      class << self
        def should_log?(message_level, desired_level)
          message_level_index = level_index(message_level)

          return false unless message_level_index

          message_level_index >= desired_level_index(desired_level)
        end

        private

        def desired_level_index(desired_level)
          case desired_level
          when Symbol then level_index_with_default(desired_level)
          when String then level_index_with_default(desired_level.to_sym)
          when Integer then desired_level
          else
            raise(
              ArgumentError,
              'wrong type of argument: expected Integer, Symbol or String. '\
              "got #{desired_level.class}"
            )
          end
        end

        def level_index_with_default(desired_level)
          level_index(desired_level) || 0
        end

        def level_index(level)
          LEVELS.index(level)
        end
      end
    end
  end
end

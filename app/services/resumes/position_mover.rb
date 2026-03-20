module Resumes
  class PositionMover
    def initialize(record:, direction: nil, position: nil)
      @record = record
      @direction = direction.to_s
      @position = position
    end

    def call
      siblings = sibling_scope.to_a
      current_index = siblings.index(record)
      return record unless current_index

      target_index = explicit_position_index(siblings.length, current_index)

      return record if target_index.negative? || target_index >= siblings.length || target_index == current_index

      moved_record = siblings.delete_at(current_index)
      siblings.insert(target_index, moved_record)

      record.class.transaction do
        siblings.each_with_index do |item, index|
          item.update_column(:position, index)
        end
      end

      record.reload
    end

    private
      attr_reader :direction, :position, :record

      def explicit_position_index(length, current_index)
        return position.to_i.clamp(0, length - 1) if position.present?

        case direction
        when "up"
          current_index - 1
        when "down"
          current_index + 1
        else
          current_index
        end
      end

      def sibling_scope
        if record.is_a?(Section)
          record.resume.sections.order(:position, :created_at)
        else
          record.section.entries.order(:position, :created_at)
        end
      end
  end
end

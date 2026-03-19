module Resumes
  class PositionMover
    def initialize(record:, direction:)
      @record = record
      @direction = direction.to_s
    end

    def call
      siblings = sibling_scope.to_a
      current_index = siblings.index(record)
      return record unless current_index

      target_index = case direction
                     when "up"
                       current_index - 1
                     when "down"
                       current_index + 1
                     else
                       current_index
                     end

      return record if target_index.negative? || target_index >= siblings.length

      siblings[current_index], siblings[target_index] = siblings[target_index], siblings[current_index]

      record.class.transaction do
        siblings.each_with_index do |item, index|
          item.update_column(:position, index)
        end
      end

      record.reload
    end

    private
      attr_reader :direction, :record

      def sibling_scope
        if record.is_a?(Section)
          record.resume.sections.order(:position, :created_at)
        else
          record.section.entries.order(:position, :created_at)
        end
      end
  end
end

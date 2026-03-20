module Resumes
  class ExportStatusBroadcaster
    include ActionView::RecordIdentifier

    def initialize(resume:)
      @resume = resume
    end

    def call
      broadcast_status(:editor)
      broadcast_status(:preview)
      broadcast_status(:show)
      broadcast_actions(:show)
      broadcast_actions(:finalize)
    end

    private
      attr_reader :resume

      def broadcast_status(context)
        Turbo::StreamsChannel.broadcast_replace_to(
          [resume, :export],
          target: dom_id(resume, "#{context}_export_status"),
          partial: "resumes/export_status_panel",
          locals: { resume: resume, context: context }
        )
      end

      def broadcast_actions(context)
        Turbo::StreamsChannel.broadcast_replace_to(
          [resume, :export],
          target: dom_id(resume, "#{context}_export_actions"),
          partial: "resumes/export_actions",
          locals: { resume: resume, context: context }
        )
      end
  end
end

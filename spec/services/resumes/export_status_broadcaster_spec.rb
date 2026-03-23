require "rails_helper"

RSpec.describe Resumes::ExportStatusBroadcaster do
  let(:resume) { create(:resume) }

  describe "#call" do
    it "broadcasts status replacements for editor, preview, and show contexts" do
      %i[editor preview show].each do |context|
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
          [ resume, :export ],
          target: "#{ActionView::RecordIdentifier.dom_id(resume, "#{context}_export_status")}",
          partial: "resumes/export_status_panel",
          locals: { resume: resume, context: context }
        )
      end

      %i[show finalize].each do |context|
        expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
          [ resume, :export ],
          target: "#{ActionView::RecordIdentifier.dom_id(resume, "#{context}_export_actions")}",
          partial: "resumes/export_actions",
          locals: { resume: resume, context: context }
        )
      end

      described_class.new(resume: resume).call
    end

    it "broadcasts action replacements for show and finalize contexts" do
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)

      described_class.new(resume: resume).call

      %i[show finalize].each do |context|
        expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
          [ resume, :export ],
          hash_including(
            target: ActionView::RecordIdentifier.dom_id(resume, "#{context}_export_actions"),
            partial: "resumes/export_actions"
          )
        )
      end
    end

    it "uses the resume-scoped export stream name" do
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)

      described_class.new(resume: resume).call

      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to)
        .with([ resume, :export ], anything).exactly(5).times
    end
  end
end

require 'rails_helper'

RSpec.describe Resumes::ExportActionsState do
  let(:resume) { create(:resume) }
  let(:view_context) { instance_double('view_context') }

  subject(:export_actions_state) { described_class.new(resume:, context:, view_context:) }

  before do
    allow(view_context).to receive(:export_resume_path) do |resume_record, **params|
      path = "/resumes/#{resume_record.id}/export"
      params.present? ? "#{path}?step=#{params[:step]}" : path
    end
    allow(view_context).to receive(:download_resume_path).with(resume).and_return("/resumes/#{resume.id}/download")
    allow(view_context).to receive(:download_text_resume_path).with(resume).and_return("/resumes/#{resume.id}/download_text")
    allow(view_context).to receive(:resume_builder_step_params).with('finalize').and_return(step: 'finalize')
  end

  context 'when rendered on the show page without a generated PDF' do
    let(:context) { :show }

    it 'offers an export action' do
      expect(export_actions_state.actions).to eq([
        {
          label: 'Export PDF',
          path: "/resumes/#{resume.id}/export",
          method: :post,
          style: :secondary
        },
        {
          label: 'Download TXT',
          path: "/resumes/#{resume.id}/download_text",
          style: :secondary,
          options: { data: { turbo: false } }
        }
      ])
    end
  end

  context 'when rendered on the show page with a generated PDF' do
    let(:context) { :show }

    before do
      resume.pdf_export.attach(io: StringIO.new('pdf data'), filename: 'resume.pdf', content_type: 'application/pdf')
    end

    it 'offers a download action' do
      expect(export_actions_state.actions).to eq([
        {
          label: 'Download PDF',
          path: "/resumes/#{resume.id}/download",
          style: :secondary,
          options: { data: { turbo: false } }
        },
        {
          label: 'Download TXT',
          path: "/resumes/#{resume.id}/download_text",
          style: :secondary,
          options: { data: { turbo: false } }
        }
      ])
    end
  end

  context 'when rendered on the finalize step with a generated PDF' do
    let(:context) { :finalize }

    before do
      resume.pdf_export.attach(io: StringIO.new('pdf data'), filename: 'resume.pdf', content_type: 'application/pdf')
    end

    it 'offers export and download actions' do
      expect(export_actions_state.actions).to eq([
        {
          label: 'Export PDF',
          path: "/resumes/#{resume.id}/export?step=finalize",
          method: :post,
          style: :secondary
        },
        {
          label: 'Download PDF',
          path: "/resumes/#{resume.id}/download",
          style: :primary,
          options: { data: { turbo: false } }
        },
        {
          label: 'Download TXT',
          path: "/resumes/#{resume.id}/download_text",
          style: :secondary,
          options: { data: { turbo: false } }
        }
      ])
    end
  end
end

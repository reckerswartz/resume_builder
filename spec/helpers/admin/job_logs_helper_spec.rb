require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Admin::JobLogsHelper. For example:
#
# describe Admin::JobLogsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Admin::JobLogsHelper, type: :helper do
  describe '#job_duration_label' do
    it 'formats a duration in seconds' do
      expect(helper.job_duration_label(1.25)).to eq('1.25 seconds')
    end

    it 'returns N/A when no duration is present' do
      expect(helper.job_duration_label(nil)).to eq('N/A')
    end
  end

  describe '#formatted_debug_payload' do
    it 'serializes hashes with string keys' do
      payload = helper.formatted_debug_payload(resume_id: 12, nested: { status: 'ok' })

      expect(payload).to include('"resume_id": 12')
      expect(payload).to include('"status": "ok"')
    end
  end
end

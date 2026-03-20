require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    allow_unauthenticated_access only: :index

    def index
      raise StandardError, 'Request failed'
    end
  end

  before do
    routes.draw { get 'index' => 'anonymous#index' }
  end

  describe 'request error tracking' do
    it 'captures unhandled request errors with request context' do
      expect do
        expect { get :index }.to raise_error(StandardError, 'Request failed')
      end.to change(ErrorLog, :count).by(1)

      error_log = ErrorLog.order(:created_at).last

      expect(error_log).to be_request
      expect(error_log.reference_id).to start_with('ERR-')
      expect(error_log.context).to include(
        'controller' => 'anonymous',
        'action' => 'index',
        'method' => 'GET'
      )
      expect(error_log.context['path']).to eq('/index')
    end
  end
end

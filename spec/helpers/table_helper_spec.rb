require 'rails_helper'

RSpec.describe TableHelper, type: :helper do
  describe '#current_table_params' do
    it 'filters the requested query keys and drops blank values' do
      allow(helper).to receive(:request).and_return(
        instance_double(ActionDispatch::Request, query_parameters: {
          'query' => 'designer',
          'status' => '',
          'page' => '2'
        })
      )

      expect(helper.current_table_params(:query, :status, :missing)).to eq(
        'query' => 'designer'
      )
    end
  end

  describe '#table_sort_params' do
    it 'toggles the current direction and clears the page param' do
      expect(
        helper.table_sort_params(
          column: 'name',
          current_sort: 'name',
          current_direction: 'asc',
          params: { 'query' => 'designer', 'page' => '3' }
        )
      ).to eq(
        'query' => 'designer',
        'sort' => 'name',
        'direction' => 'desc'
      )
    end
  end

  describe '#table_sort_indicator' do
    it 'returns the ascending arrow for the active ascending sort' do
      expect(helper.table_sort_indicator('name', current_sort: 'name', current_direction: 'asc')).to include('↑')
    end

    it 'returns nil when the column is not the active sort' do
      expect(helper.table_sort_indicator('name', current_sort: 'updated_at', current_direction: 'asc')).to be_nil
    end
  end

  describe '#table_page_window' do
    it 'bounds the page window to the valid range' do
      expect(helper.table_page_window(current_page: 1, total_pages: 3)).to eq([ 1, 2 ])
      expect(helper.table_page_window(current_page: 3, total_pages: 3)).to eq([ 2, 3 ])
    end
  end

  describe '#table_query_path' do
    it 'returns the base path when all params are blank' do
      expect(helper.table_query_path('/admin/job_logs', { 'query' => '', 'page' => nil })).to eq('/admin/job_logs')
    end

    it 'appends a compacted query string when params are present' do
      expect(helper.table_query_path('/admin/job_logs', { 'query' => 'designer', 'page' => 2 })).to eq('/admin/job_logs?page=2&query=designer')
    end
  end
end

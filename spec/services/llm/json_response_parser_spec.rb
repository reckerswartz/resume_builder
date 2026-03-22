require 'rails_helper'

RSpec.describe Llm::JsonResponseParser do
  subject(:parser) { described_class.new }

  describe '#object_from' do
    it 'parses valid JSON into a string-keyed hash' do
      result = parser.object_from('{"resume":{"title":"Engineer"}}')

      expect(result).to eq({ "resume" => { "title" => "Engineer" } })
    end

    it 'extracts embedded JSON from surrounding text' do
      response = "Here is the result:\n{\"name\":\"Alice\"}\nDone."

      expect(parser.object_from(response)).to eq({ "name" => "Alice" })
    end

    it 'returns an empty hash for completely unparseable text' do
      expect(parser.object_from("no json here")).to eq({})
    end

    it 'returns an empty hash for nil input' do
      expect(parser.object_from(nil)).to eq({})
    end

    it 'returns an empty hash for an empty string' do
      expect(parser.object_from("")).to eq({})
    end

    it 'deep-stringifies symbol keys' do
      result = parser.object_from('{"data":{"key":"value"}}')

      expect(result.keys).to all(be_a(String))
      expect(result["data"].keys).to all(be_a(String))
    end
  end

  describe '#array_from' do
    it 'extracts an array by key from valid JSON' do
      response = '{"highlights":["Built APIs","Led team"]}'

      expect(parser.array_from(response, key: "highlights")).to eq([ "Built APIs", "Led team" ])
    end

    it 'accepts a symbol key' do
      response = '{"items":["one","two"]}'

      expect(parser.array_from(response, key: :items)).to eq([ "one", "two" ])
    end

    it 'strips blank entries from the array' do
      response = '{"items":["valid","","  ","also valid"]}'

      expect(parser.array_from(response, key: "items")).to eq([ "valid", "also valid" ])
    end

    it 'falls back to line-based parsing when the key is missing' do
      response = "- Built APIs\n- Led team\n* Shipped features"

      result = parser.array_from(response, key: "highlights")

      expect(result).to eq([ "Built APIs", "Led team", "Shipped features" ])
    end

    it 'falls back to line-based parsing for unparseable text' do
      response = "Line one\nLine two"

      result = parser.array_from(response, key: "items")

      expect(result).to eq([ "Line one", "Line two" ])
    end

    it 'strips bullet markers from fallback lines' do
      response = "• First\n- Second\n* Third"

      result = parser.array_from(response, key: "items")

      expect(result).to eq([ "First", "Second", "Third" ])
    end

    it 'returns an empty array for nil input with a missing key' do
      expect(parser.array_from(nil, key: "items")).to eq([])
    end
  end
end

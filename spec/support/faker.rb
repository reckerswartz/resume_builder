require "faker"

RSpec.configure do |config|
  config.before(:suite) do
    Faker::Config.random = Random.new(config.seed)
    Faker::UniqueGenerator.clear
  end

  config.before do
    Faker::UniqueGenerator.clear
  end
end

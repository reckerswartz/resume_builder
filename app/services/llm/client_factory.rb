module Llm
  class ClientFactory
    def self.build(provider)
      case provider.adapter
      when "ollama"
        Providers::OllamaClient.new(provider: provider)
      when "nvidia_build"
        Providers::NvidiaBuildClient.new(provider: provider)
      else
        raise ArgumentError, "Unsupported LLM provider adapter: #{provider.adapter}"
      end
    end
  end
end

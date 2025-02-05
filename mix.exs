defmodule DistributedChat.MixProject do
  use Mix.Project

  def project do
    [
      app: :distributed_chat,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DistributedChat.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.13"},
      {:tesla_curl, "~> 1.3.1", only: [:dev, :test]}
    ]
  end
end

defmodule Telegram.Mixfile do
  use Mix.Project

  def project do
    [app: :telegram,
     version: "0.0.2",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "Simple module for parsing Telegram Bot API request",
     package: package,
     deps: deps]
  end

  def package do
    [
      maintainers: ["Colin Harris"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/col/telegram"}
    ]
  end

  def application do
    [applications: [:logger, :poison]]
  end

  defp deps do
    [
      {:poison, "~> 2.0"}
    ]
  end
end

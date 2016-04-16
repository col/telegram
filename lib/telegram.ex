defmodule Telegram do
  defmodule Chat do
    defstruct [:id, :title, :type]
  end

  defmodule User do
    defstruct [:id, :first_name, :last_name]
  end

  defmodule Request do
    defstruct [chat: %Telegram.Chat{}, from: %Telegram.User{}, date: nil, message_id: nil, text: nil]

    def parse(body) when is_binary(body) do
      Poison.decode!(body, as: %Telegram.Request{})
    end

    def encode(request) do
      Poison.encode!(request)
    end
  end
end

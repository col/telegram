defmodule Telegram do
  defmodule Chat do
    defstruct [:id, :title, :type]
  end

  defmodule User do
    defstruct [:id, :first_name, :last_name]
  end

  defmodule Entity do
    defstruct [:type, :offset, :length]
  end

  defmodule Message do
    defstruct [chat: %Telegram.Chat{}, from: %Telegram.User{}, entities: [%Telegram.Entity{}], date: nil, message_id: nil, text: nil]
  end

  defmodule Request do
    defstruct [update_id: nil, message: %Telegram.Message{}]

    def parse(body) when is_binary(body) do
      Poison.decode!(body, as: %Telegram.Request{})
    end

    def encode(request) do
      Poison.encode!(request)
    end
  end
end

defmodule Telegram do
  defmodule Chat do
    defstruct [:id, :title, :type]
  end

  defmodule User do
    defstruct [:id, :first_name, :last_name]
  end

  defmodule Entity do
    defstruct [:type, :offset, :length]

    def find(entities, type) do
      Enum.find(entities, fn(e) -> e.type == type end)
    end
  end

  defmodule Message do
    defstruct [
      chat: %Telegram.Chat{},
      from: %Telegram.User{},
      entities: [%Telegram.Entity{}],
      date: nil,
      message_id: nil,
      text: nil,
      command: nil,
      params: nil,
    ]

    def entity_value(message, entity) do
      String.slice(message.text, entity.offset, entity.length)
    end

    def process_entities(message) do
      command_entity = Telegram.Entity.find(message.entities, "bot_command")
      parse_bot_command(message, command_entity)
    end

    def parse_bot_command(message, nil), do: message
    def parse_bot_command(message, entity) do
      params = message.text
        |> String.slice(
            entity.offset + entity.length,
            String.length(message.text)-entity.offset
           )
        |> String.split
      message
        |> Map.put(:command, Telegram.Message.entity_value(message, entity))
        |> Map.put(:params, params)
    end
  end

  defmodule Update do
    defstruct [update_id: nil, message: %Telegram.Message{}]

    def parse(body) when is_binary(body) do
      update = Poison.decode!(body, as: %Telegram.Update{})
      %{update | message: Telegram.Message.process_entities(update.message)}
    end

    def encode(update) do
      Poison.encode!(update)
    end
  end
end

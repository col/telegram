defmodule Telegram do
  defmodule Chat do
    defstruct [:id, :title, :type]

    def new(id, title, type) do
      %Chat{id: id, title: title, type: type}
    end
  end

  defmodule User do
    defstruct [:id, :first_name, :last_name]

    def new(id, first_name, last_name) do
      %User{id: id, first_name: first_name, last_name: last_name}
    end
  end

  defmodule Entity do
    defstruct [:type, :offset, :length]

    def new(type, offset, length) do
      %Entity{type: type, offset: offset, length: length}
    end

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
      params: [],
    ]

    def set_command(message, command) do
      message
        |> Map.put(:text, command)
        |> Map.put(:command, command)
        |> set_entity(%Telegram.Entity{
              type: "bot_command",
              offset: 0,
              length: String.length(command)
           })
    end

    def set_text(message, text) do
      Map.put(message, :text, text)
    end

    def set_entity(message, entity) do
      entities = [entity|Enum.reject(message.entities, fn(e) -> e.type == entity.type end)]
      Map.put(message, :entities, entities)
    end

    def entity_value(_, nil), do: nil
    def entity_value(message, type) when is_binary(type) do
      entity = Entity.find(message.entities, type)
      entity_value(message, entity)
    end
    def entity_value(message, entity) do
      String.slice(message.text, entity.offset, entity.length)
       |> String.split("@")
       |> List.first
    end

    def process_entities(message) do
      # TODO: Make this more generic so that it supports the other entity types
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

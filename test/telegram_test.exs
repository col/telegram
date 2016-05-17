defmodule TelegramTest do
  use ExUnit.Case
  alias Telegram.{Update, Message, Chat, User, Entity}
  doctest Telegram

  @sample_update %Update{
    update_id: 131900178,
    message: %Message{
      chat: %Chat{
        id: 123,
        title: "Test",
        type: "group"
      },
      from: %User{
        id: 456,
        first_name: "Col",
        last_name: "Harris"
      },
      entities: [
        %Entity{
          type: "bot_command",
          offset: 0,
          length: 8
        }
      ],
      date: 1460556888,
      message_id: 789,
      text: "/command some params",
      command: "/command",
      params: ["some", "params"]
    }
  }

  test "parse bot message" do
    {:ok, json} = File.read("test/data/bot_message.json")
    update = Update.parse(json)
    assert %{update_id: 131900178, message: message} = update
    assert %Message{
      chat: chat,
      from: from,
      entities: entities,
      date: 1460556888,
      message_id: 789,
      text: "/command some params",
      command: "/command",
      params: ["some", "params"]
    } = message
    assert %Chat{id: 123, title: "Test", type: "group"} = chat
    assert %User{id: 456, first_name: "Col", last_name: "Harris"} = from
    assert [%Entity{type: "bot_command", offset: 0, length: 8}] = entities
  end

  test "parse text message" do
    {:ok, json} = File.read("test/data/text_message.json")
    update = Update.parse(json)
    assert %{update_id: 131900178, message: message} = update
    assert %Message{
      chat: chat,
      from: from,
      entities: [],
      date: 1460556888,
      message_id: 789,
      text: "Hello",
      command: nil,
      params: nil
    } = message
    assert %Chat{id: 123, title: "Test", type: "group"} = chat
    assert %User{id: 456, first_name: "Col", last_name: "Harris"} = from
  end

  test "encode update" do
    json = Update.encode(@sample_update)
    update = Update.parse(json)
    assert update == @sample_update
  end

  test "Message.set_text" do
    message = %Message{} |> Message.set_text("New Text")
    assert "New Text" = message.text
  end

  test "Message.set_command" do
    message = %Message{} |> Message.set_command("/command")
    assert message.text == "/command"
    assert message.command == "/command"

    command_entity = Telegram.Entity.find(message.entities, "bot_command")
    assert command_entity == %Telegram.Entity{type: "bot_command", offset: 0, length: 8}
  end

  test "Message.set_entity" do
    message = %Message{}
      |> Message.set_text("/example_command")
      |> Message.set_entity(%Entity{type: "bot_command", offset: 0, length: 16})

    assert Message.entity_value(message, "bot_command") == "/example_command"
  end

  test "Message.entity_value" do
    message = %Message{
      text: "/example_command",
      entities: [%Entity{type: "bot_command", offset: 0, length: 16}]
    }
    assert Message.entity_value(message, "bot_command") == "/example_command"
  end

  test "Message.process_entities" do
    message = %Message{}
      |> Message.set_text("/example_command param1 param2")
      |> Message.set_entity(%Entity{type: "bot_command", offset: 0, length: 16})
      |> Message.process_entities

    assert message.command == "/example_command"
    assert message.params == ["param1", "param2"]
  end

end

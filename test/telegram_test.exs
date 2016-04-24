defmodule TelegramTest do
  use ExUnit.Case
  doctest Telegram

  @sample_update %Telegram.Update{
    update_id: 131900178,
    message: %Telegram.Message{
      chat: %Telegram.Chat{
        id: 123,
        title: "Test",
        type: "group"
      },
      from: %Telegram.User{
        id: 456,
        first_name: "Col",
        last_name: "Harris"
      },
      entities: [
        %Telegram.Entity{
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
    update = Telegram.Update.parse(json)
    assert %{update_id: 131900178, message: message} = update
    assert %Telegram.Message{
      chat: chat,
      from: from,
      entities: entities,
      date: 1460556888,
      message_id: 789,
      text: "/command some params",
      command: "/command",
      params: ["some", "params"]
    } = message
    assert %Telegram.Chat{id: 123, title: "Test", type: "group"} = chat
    assert %Telegram.User{id: 456, first_name: "Col", last_name: "Harris"} = from
    assert [%Telegram.Entity{type: "bot_command", offset: 0, length: 8}] = entities
  end

  test "parse text message" do
    {:ok, json} = File.read("test/data/text_message.json")
    update = Telegram.Update.parse(json)
    assert %{update_id: 131900178, message: message} = update
    assert %Telegram.Message{
      chat: chat,
      from: from,
      entities: [],
      date: 1460556888,
      message_id: 789,
      text: "Hello",
      command: nil,
      params: nil
    } = message
    assert %Telegram.Chat{id: 123, title: "Test", type: "group"} = chat
    assert %Telegram.User{id: 456, first_name: "Col", last_name: "Harris"} = from
  end

  test "encode update" do
    json = Telegram.Update.encode(@sample_update)
    update = Telegram.Update.parse(json)
    assert update == @sample_update
  end
end

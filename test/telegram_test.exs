defmodule TelegramTest do
  use ExUnit.Case
  doctest Telegram

  @sample_request %Telegram.Request{
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
      text: "/command"
    }
  }

  test "parse request" do
    {:ok, request_body} = File.read("test/data/request.json")
    result = Telegram.Request.parse(request_body)
    assert @sample_request == result
  end

  test "encode request" do
    result = Telegram.Request.encode(@sample_request)
    expected_result = File.read!("test/data/request.json")
      |> String.split()
      |> Enum.join("")
    assert result == expected_result
  end
end

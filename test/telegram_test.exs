defmodule TelegramTest do
  use ExUnit.Case
  doctest Telegram

  test "parse response" do
    {:ok, request_body} = File.read("test/data/request.json")
    result = Telegram.Request.parse(request_body)

    assert %Telegram.Request{
      chat: %Telegram.Chat{
        id: 123,
        title: "Test Chat",
        type: "group"
      },
      from: %Telegram.User{
        id: 456,
        first_name: "Col",
        last_name: "Harris"
      },
      date: 1460556888,
      message_id: 789,
      text: "/echo Hello"
    } = result
  end
end

defmodule MyBBS.OpenAI do
  def stream_chat(messages) do
    OpenAI.chat_completion(
      [
        model: "gpt-4o-mini",
        messages: messages,
        stream: true
      ],
      %OpenAI.Config{http_options: [recv_timeout: :infinity, stream_to: self(), async: :once]}
    )
  end
end

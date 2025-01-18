defmodule ConcurrentApp.Router do
  use Plug.Router
  require Logger

  plug(:match)
  plug(:dispatch)

  # Handles POST requests to insert a single item
  post "/items" do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)
    case Jason.decode(body) do
      {:ok, %{"item" => item}} ->
        ConcurrentApp.DB.insert_item(item)
        send_resp(conn, 201, Jason.encode!(%{"msg" => "ok"}))

      _ ->
        send_resp(conn, 400, Jason.encode!(%{"error" => "Invalid JSON payload"}))
    end
  end

  # Handles GET requests to fetch all items
  get "/items" do
    case ConcurrentApp.DB.get_all_items() do
      {:ok, items} ->
        send_resp(conn, 200, Jason.encode!(items))

      {:error, reason} ->
        Logger.error("Failed to fetch items: #{inspect(reason)}")
        send_resp(conn, 500, Jason.encode!(%{"error" => "Internal Server Error"}))
    end
  end

  match _ do
    send_resp(conn, 404, Jason.encode!(%{"error" => "Not Found"}))
  end
end

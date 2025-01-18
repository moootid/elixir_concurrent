defmodule ConcurrentApp.DB do
  use GenServer

  @moduledoc """
  Database interaction module with support for high-concurrency operations.
  """

  alias Task.Supervisor

  # Starts the GenServer
  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Initializes the Postgrex connection
  def init(_) do
    {:ok, conn} =
      Postgrex.start_link(
        hostname: "db",
        username: "postgres",
        password: "password",
        database: "example_db",
        pool_size: 100,
        max_overflow: 50
      )

    {:ok, %{conn: conn}}
  end

  # Public function to insert a single item
  def insert_item(item) do
    GenServer.cast(__MODULE__, {:insert_item, item})
  end

  # Public function to insert multiple items in batch
  def insert_items(items) when is_list(items) do
    GenServer.cast(__MODULE__, {:insert_items, items})
  end

  # Public function to fetch all items
  def get_all_items do
    GenServer.call(__MODULE__, :get_all_items, 10_000)
  end

  # Handles asynchronous insert of a single item
  def handle_cast({:insert_item, item}, state) do
    query = "INSERT INTO items (item) VALUES ($1)"
    Supervisor.start_child(Task.Supervisor, fn ->
      Postgrex.query!(state.conn, query, [item])
    end)
    {:noreply, state}
  end

  # Handles asynchronous batch insert
  def handle_cast({:insert_items, items}, state) do
    query = "INSERT INTO items (item) VALUES " <>
            Enum.map(1..length(items), fn i -> "($#{i})" end) |> Enum.join(", ")
    Supervisor.start_child(Task.Supervisor, fn ->
      Postgrex.query!(state.conn, query, items)
    end)
    {:noreply, state}
  end

  # Handles fetching all items
  def handle_call(:get_all_items, _from, state) do
    query = "SELECT id, item FROM items"
    case Postgrex.query(state.conn, query, []) do
      {:ok, %Postgrex.Result{rows: rows}} ->
        items = Enum.map(rows, fn [id, item] -> %{"id" => id, "item" => item} end)
        {:reply, {:ok, items}, state}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end
end

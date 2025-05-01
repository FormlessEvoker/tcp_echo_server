defmodule TCPEchoServer.Connection do
  @moduledoc """
  This module handles a TCP connection to a single client for the echo server.
  """

  defstruct [:socket, buffer: <<>>]

  use GenServer
  require Logger

  @spec start_link(:gen_tcp.socket()) :: GenServer.on_start()
  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket)
  end

  @impl true
  def init(socket) do
    {:ok, %__MODULE__{socket: socket}}
  end

  @impl true
  def handle_info(message, state)

  def handle_info({:tcp, socket, line}, %__MODULE__{socket: _socket} = state) do
    :ok = :inet.setopts(socket, active: :once)
    # state = update_in(state.buffer, &(&1 <> data))
    # state = handle_new_data(state)
    :ok = :gen_tcp.send(state.socket, line)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, socket}, %__MODULE__{socket: socket} = state) do
    {:stop, :normal, state}
  end

  def handle_info({:tcp_error, socket, reason}, %__MODULE__{socket: socket} = state) do
    Logger.error("TCP connection error: #{inspect(reason)}")
    {:stop, :normal, state}
  end

  # This would be used if we wanted to handle fragmented data
  # But in the current implementation, we are using :line packetization
  # and therefore this function is not needed.
  # However, it was valuable to understand how to handle fragmented data
  # and how to process it in the state. So I'm leaving it here.
  #
  # defp handle_new_data(state) do
  #   case String.split(state.buffer, "\n", parts: 2) do
  #     [line, rest] ->
  #       :ok = :gen_tcp.send(state.socket, line <> "\n")
  #       state = put_in(state.buffer, rest)
  #       handle_new_data(state)

  #     _ ->
  #       # No complete line yet, just return the state
  #       state
  #   end
  # end
end

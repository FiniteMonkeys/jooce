defmodule Jooce.Monitor.Flight do
  use GenServer

  ##
  ## API
  ##

  def start(conn, vessel_id, name \\ __MODULE__) do
    GenServer.start(__MODULE__, %{conn: conn, vessel_id: vessel_id}, name: name)
  end

  def start_link(conn, vessel_id, name \\ __MODULE__) do
    GenServer.start_link(__MODULE__, %{conn: conn, vessel_id: vessel_id}, name: name)
  end

  def add_handler(pid, handler, args) do
    GenServer.call(pid, {:add_handler, handler, args})
  end

  def add_mon_handler(pid, handler, args) do
    GenServer.call(pid, {:add_mon_handler, handler, args})
  end

  def remove_handler(pid, handler, args) do
    GenServer.call(pid, {:remove_handler, handler, args})
  end

  ## altitude

  def mean_altitude(pid) do
    GenServer.call(pid, {:altitude, :mean})
  end

  def surface_altitude(pid) do
    GenServer.call(pid, {:altitude, :surface})
  end

  def bedrock_altitude(pid) do
    GenServer.call(pid, {:altitude, :bedrock})
  end

  ##
  ## callbacks
  ##

  def init(%{conn: conn, vessel_id: vessel_id}) do
    {:ok, flight_id, _} = Jooce.SpaceCenter.vessel_get_flight(conn, vessel_id)
    {:ok, event_mgr} = GenEvent.start_link([])

    schedule_work()

    {:ok, %{conn: conn, flight_id: flight_id, event_mgr: event_mgr}}
  end

  def handle_call({:add_handler, handler, args}, _from, state) do
    {:reply, GenEvent.add_handler(state.event_mgr, handler, args), state}
  end

  def handle_call({:add_mon_handler, handler, args}, _from, state) do
    {:reply, GenEvent.add_mon_handler(state.event_mgr, handler, args), state}
  end

  def handle_call({:remove_handler, handler, args}, _from, state) do
    {:reply, GenEvent.remove_handler(state.event_mgr, handler, args), state}
  end

  def handle_call({:altitude, :mean}, _from, state) do
    {:reply, mean_altitude(state.conn, state.flight_id), state}
  end

  def handle_call({:altitude, :surface}, _from, state) do
    {:reply, surface_altitude(state.conn, state.flight_id), state}
  end

  def handle_call({:altitude, :bedrock}, _from, state) do
    {:reply, bedrock_altitude(state.conn, state.flight_id), state}
  end

  # def handle_cast do
  #
  # end

  def handle_info(:tick, state) do
    GenEvent.ack_notify(state.event_mgr, {:altitude, :mean, mean_altitude(state.conn, state.flight_id)})
    GenEvent.ack_notify(state.event_mgr, {:altitude, :surface, surface_altitude(state.conn, state.flight_id)})
    GenEvent.ack_notify(state.event_mgr, {:altitude, :bedrock, bedrock_altitude(state.conn, state.flight_id)})

    schedule_work()
    {:noreply, state}
  end

  ##
  ## private API
  ##

  defp schedule_work() do
    Process.send_after(self(), :tick, 100)
  end

  defp mean_altitude(conn, flight_id) do
    {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(conn, flight_id)
    altitude
  end

  defp surface_altitude(conn, flight_id) do
    {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_surface_altitude(conn, flight_id)
    altitude
  end

  defp bedrock_altitude(conn, flight_id) do
    {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_bedrock_altitude(conn, flight_id)
    altitude
  end
end

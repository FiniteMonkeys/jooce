defmodule Jooce.Controller.Flight do
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

  ## altitude

  def mean_altitude(pid) do
    GenServer.call(pid, {:altitude, :mean})
  end

  def surface_altitude(pid) do
    GenServer.call(pid, {:altitude, :surface})
  end

  ##
  ## callbacks
  ##

  def init(%{conn: conn, vessel_id: vessel_id}) do
    {:ok, flight_id, _} = Jooce.SpaceCenter.vessel_get_flight(conn, vessel_id)
    {:ok, %{conn: conn, flight_id: flight_id}}
  end

  def handle_call({:altitude, :mean}, _from, state) do
    {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_mean_altitude(state.conn, state.flight_id)
    {:reply, altitude, state}
  end

  def handle_call({:altitude, :surface}, _from, state) do
    {:ok, altitude, _} = Jooce.SpaceCenter.flight_get_surface_altitude(state.conn, state.flight_id)
    {:reply, altitude, state}
  end

  # def handle_cast do
  #
  # end

  # def handle_info do
  #
  # end
end

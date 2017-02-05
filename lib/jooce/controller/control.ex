defmodule Jooce.Controller.Control do
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

  ## throttle

  def throttle(pid, value) do
    GenServer.cast(pid, {:throttle, value})
  end

  ## stage

  def stage(pid) do
    GenServer.cast(pid, :stage)
  end

  ##
  ## callbacks
  ##

  def init(%{conn: conn, vessel_id: vessel_id}) do
    {:ok, control_id, _} = Jooce.SpaceCenter.vessel_get_control(conn, vessel_id)
    {:ok, %{conn: conn, control_id: control_id}}
  end

  def handle_cast({:throttle, value}, state) do
    {:ok, _, _} = Jooce.SpaceCenter.control_set_throttle(state.conn, state.control_id, value)
    {:noreply, state}
  end

  def handle_cast(:stage, state) do
    {:ok, _, _} = Jooce.SpaceCenter.control_activate_next_stage(state.conn, state.control_id)
    {:noreply, state}
  end

  # def handle_call do
  #
  # end

  # def handle_info do
  #
  # end
end
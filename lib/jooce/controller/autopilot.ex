defmodule Jooce.Controller.Autopilot do
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

  ## autopilot enable/disable

  def on(pid) do
    GenServer.cast(pid, :on)
  end

  def off(pid) do
    GenServer.cast(pid, :off)
  end

  ## SAS enable/disable

  def sas_on(pid) do
    GenServer.cast(pid, :sas_on)
  end

  def sas_off(pid) do
    GenServer.cast(pid, :sas_off)
  end

  def sas_mode(pid, mode) do
    GenServer.cast(pid, {:sas_mode, mode})
  end

  ## attitude

  def heading(pid, value) do
    GenServer.cast(pid, {:heading, value})
  end

  def pitch(pid, value) do
    GenServer.cast(pid, {:pitch, value})
  end

  def roll(pid, value) do
    GenServer.cast(pid, {:roll, value})
  end

  ##
  ## callbacks
  ##

  def init(%{conn: conn, vessel_id: vessel_id}) do
    {:ok, autopilot_id, _} = Jooce.SpaceCenter.vessel_get_autopilot(conn, vessel_id)
    {:ok, %{conn: conn, autopilot_id: autopilot_id}}
  end

  def handle_cast(:on, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_engage(state.conn, state.autopilot_id)
    {:noreply, state}
  end

  def handle_cast(:off, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_disengage(state.conn, state.autopilot_id)
    {:noreply, state}
  end

  def handle_cast(:sas_on, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, true)
    {:noreply, state}
  end

  def handle_cast(:sas_off, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, false)
    {:noreply, state}
  end

  def handle_cast({:sas_mode, :prograde}, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 2)
    {:noreply, state}
  end

  def handle_cast({:sas_mode, :retrograde}, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 3)
    {:noreply, state}
  end

  def handle_cast({:heading, value}, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_heading(state.conn, state.autopilot_id, value)
    {:noreply, state}
  end

  def handle_cast({:pitch, value}, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(state.conn, state.autopilot_id, value)
    {:noreply, state}
  end

  def handle_cast({:roll, value}, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_roll(state.conn, state.autopilot_id, value)
    {:noreply, state}
  end

  # def handle_call do
  #
  # end

  # def handle_info do
  #
  # end
end

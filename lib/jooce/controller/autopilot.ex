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
    GenServer.call(pid, :on)
  end

  def off(pid) do
    GenServer.call(pid, :off)
  end

  ## SAS enable/disable

  def sas_on(pid) do
    GenServer.call(pid, :sas_on)
  end

  def sas_off(pid) do
    GenServer.call(pid, :sas_off)
  end

  def sas_mode(pid, mode) do
    GenServer.call(pid, {:sas_mode, mode})
  end

  ## attitude

  def pitch_and_heading(pid, pitch, heading) do
    GenServer.call(pid, {:pitch_and_heading, pitch, heading})
  end

  def heading(pid, value) do
    GenServer.call(pid, {:heading, value})
  end

  def pitch(pid, value) do
    GenServer.call(pid, {:pitch, value})
  end

  def roll(pid, value) do
    GenServer.call(pid, {:roll, value})
  end

  ##
  ## callbacks
  ##

  def init(%{conn: conn, vessel_id: vessel_id}) do
    {:ok, autopilot_id, _} = Jooce.SpaceCenter.vessel_get_autopilot(conn, vessel_id)
    {:ok, %{conn: conn, autopilot_id: autopilot_id}}
  end

  def handle_call(:on, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_engage(state.conn, state.autopilot_id)
    {:reply, :ok, state}
  end

  def handle_call(:off, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_disengage(state.conn, state.autopilot_id)
    {:reply, :ok, state}
  end

  def handle_call(:sas_on, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, true)
    {:reply, :ok, state}
  end

  def handle_call(:sas_off, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas(state.conn, state.autopilot_id, false)
    {:reply, :ok, state}
  end

  def handle_call({:sas_mode, :prograde}, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 2)
    {:reply, :ok, state}
  end

  def handle_call({:sas_mode, :retrograde}, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_sas_mode(state.conn, state.autopilot_id, 3)
    {:reply, :ok, state}
  end

  def handle_call({:pitch_and_heading, pitch, heading}, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch_and_heading(state.conn, state.autopilot_id, pitch, heading)
    {:reply, :ok, state}
  end

  def handle_call({:heading, value}, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_heading(state.conn, state.autopilot_id, value)
    {:reply, :ok, state}
  end

  def handle_call({:pitch, value}, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_pitch(state.conn, state.autopilot_id, value)
    {:reply, :ok, state}
  end

  def handle_call({:roll, value}, _from, state) do
    {:ok, _, _} = Jooce.SpaceCenter.autopilot_set_target_roll(state.conn, state.autopilot_id, value)
    {:reply, :ok, state}
  end

  # def handle_cast do
  #
  # end

  # def handle_info do
  #
  # end
end

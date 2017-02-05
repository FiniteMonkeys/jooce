defmodule Jooce.Monitor.Resources do
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

  ## fuel

  def liquid_fuel(pid) do
    GenServer.call(pid, {:amount, :liquid_fuel})
  end

  ##
  ## callbacks
  ##

  def init(%{conn: conn, vessel_id: vessel_id}) do
    {:ok, resources_id, _} = Jooce.SpaceCenter.vessel_get_resources(conn, vessel_id)
    {:ok, event_mgr} = GenEvent.start_link([])

    schedule_work()

    {:ok, %{conn: conn, resources_id: resources_id, event_mgr: event_mgr}}
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

  def handle_call({:amount, :liquid_fuel}, _from, state) do
    {:reply, liquid_fuel(state.conn, state.resources_id), state}
  end

  # def handle_cast do
  #
  # end

  def handle_info(:tick, state) do
    GenEvent.ack_notify(state.event_mgr, {:amount, :liquid_fuel, liquid_fuel(state.conn, state.resources_id)})

    schedule_work()
    {:noreply, state}
  end

  ##
  ## private API
  ##

  defp schedule_work() do
    Process.send_after(self(), :tick, 100)
  end

  defp liquid_fuel(conn, resources_id) do
    {:ok, amount, _} = Jooce.SpaceCenter.resources_amount(conn, resources_id, "LiquidFuel")
    amount
  end
end

defmodule Jooce.Controller.Resources do
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

  def liquid_fuel(pid) do
    GenServer.call(pid, {:amount, :liquid_fuel})
  end

  ##
  ## callbacks
  ##

  def init(%{conn: conn, vessel_id: vessel_id}) do
    {:ok, resources_id, _} = Jooce.SpaceCenter.vessel_get_resources(conn, vessel_id)
    {:ok, %{conn: conn, resources_id: resources_id}}
  end

  def handle_call({:amount, :liquid_fuel}, _from, state) do
    {:ok, amount, _} = Jooce.SpaceCenter.resources_amount(state.conn, state.resources_id, "LiquidFuel")
    {:reply, amount, state}
  end

  # def handle_cast do
  #
  # end

  # def handle_info do
  #
  # end
end

defmodule FacilitySupervisor do
  @moduledoc """
  Supervises `FacilityCompactor` processes for each facility.

  `FacilitySupervisor` is responsible for managing the lifecycle of `FacilityCompactor` processes,
  where each `FacilityCompactor` handles sensor readings for a specific facility.

  This supervisor is implemented as a `DynamicSupervisor` to allow runtime creation of child processes.
  """
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(facility_id) do
    DynamicSupervisor.start_child(__MODULE__, {FacilityCompactor, facility_id})
  end

  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)
end

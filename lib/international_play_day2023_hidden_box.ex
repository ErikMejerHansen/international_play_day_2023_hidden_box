defmodule BoxesWithinBoxes do
  @behaviour :gen_statem

  def unlock(pid, arg) do
    :gen_statem.call(pid, {:unlock, arg})
  end

  def hint(pid) do
    :gen_statem.call(pid, :hint)
  end

  def start_link do
    :gen_statem.start_link(__MODULE__, [], [])
  end

  @impl :gen_statem
  def init(_opts) do
    # return :ok and the initial state (:off) and some empty data
    {:ok, :first_box, %{}}
  end

  @impl :gen_statem
  def callback_mode(), do: :state_functions

  def first_box({:call, from}, :hint, _data) do
    {:keep_state_and_data,
     [
       {:reply, from,
        "This is my first hint: A key is not of much worth if it is not _functional_"}
     ]}
  end

  def first_box({:call, from}, {:unlock, arg}, data) when is_function(arg) do
    {:next_state, :second_box, data, [{:reply, from, :unlocked}]}
  end

  def first_box({:call, from}, {:unlock, _arg}, _data) do
    {:keep_state_and_data,
     [{:reply, from, "This key cannot turn this lock. The key seems non-functional"}]}
  end
end

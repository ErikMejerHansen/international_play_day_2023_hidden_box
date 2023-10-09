defmodule BoxesWithinBoxes do
  @behaviour :gen_statem

  @non_functional_key_message "That key cannot turn this lock. The key seems non-functional"

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
    {:keep_state_and_data, [{:reply, from, @non_functional_key_message}]}
  end

  def second_box({:call, from}, :hint, _data) do
    {:keep_state_and_data,
     [
       {:reply, from,
        "The Jester pulls out a key from a pocket hidden somewhere in the folds of his jacket. A sliver key polished to a mirror shine. “See how it reflects the world back? Reflects back anything you give it unchanged. Completely devoid its own identity this key is."}
     ]}
  end

  def second_box({:call, from}, {:unlock, arg}, data) when is_function(arg) do
    random_number = :rand.uniform()

    if arg.(random_number) === random_number do
      {:next_state, :third_box, data, [{:reply, from, :unlocked}]}
    else
      {:keep_state_and_data,
       [
         {:reply, from,
          "The key seems functional, but does not seem to reflect in quite the right way"}
       ]}
    end
  end

  def second_box({:call, from}, {:unlock, _arg}, _data) do
    {:keep_state_and_data, [{:reply, from, @non_functional_key_message}]}
  end

  def third_box({:call, from}, :hint, _data) do
    {:keep_state_and_data,
     [
       {:reply, from, Base.encode64("fn -> :obscuring_is_not_a_good_way_of_keeping_secrets end")}
     ]}
  end

  def third_box({:call, from}, {:unlock, arg}, data) when is_function(arg) do
    if arg.() == :obscuring_is_not_a_good_way_of_keeping_secrets do
      {:next_state, :fourth_box, data, [{:reply, from, :unlocked}]}
    else
      {:keep_state_and_data,
       [
         {:reply, from,
          "The key turns and turns in the lock. Even turning it 64-times isn’t enough to unlock the key. "}
       ]}
    end
  end

  def third_box({:call, from}, {:unlock, _arg}, _data) do
    {:keep_state_and_data, [{:reply, from, @non_functional_key_message}]}
  end

  def fourth_box({:call, from}, :hint, _data) do
    priv_dir = :code.priv_dir(:international_play_day_2023_hidden_box)
    path_to_ghostbusters_theme = Path.join(priv_dir, "Ghostbusters.mid")
    {:ok, ghostbusters_theme} = File.read(path_to_ghostbusters_theme)

    {:keep_state_and_data,
     [
       {:reply, from, ghostbusters_theme}
     ]}
  end

  def fourth_box({:call, from}, {:unlock, arg}, data) when is_function(arg) do
    who_you_gonna_call = arg.()

    if who_you_gonna_call == "Ghostbusters" do
      IO.puts("📞?👻⛔️")
      {:next_state, :fifth_box, data, [{:reply, from, :unlocked}]}
    else
      {:keep_state_and_data,
       [
         {:reply, from, "I tried calling #{who_you_gonna_call}, but no one answered."}
       ]}
    end
  end

  def fourth_box({:call, from}, {:unlock, _arg}, _data) do
    {:keep_state_and_data, [{:reply, from, @non_functional_key_message}]}
  end

  def fifth_box({:call, from}, :hint, _data) do
    priv_dir = :code.priv_dir(:international_play_day_2023_hidden_box)
    path_to_puzzle = Path.join(priv_dir, "puzzle.png")
    {:ok, puzzle} = File.read(path_to_puzzle)

    {:keep_state_and_data,
     [
       {:reply, from, puzzle}
     ]}
  end

  def fifth_box({:call, from}, {:unlock, arg}, data) when is_function(arg) do
    if arg.() == 42 do
      {:next_state, :done, data,
       [
         {:reply, from,
          "The final box unlocks and within it you find your prize: https://www.youtube.com/watch?v=dQw4w9WgXcQ"}
       ]}
    else
      {:keep_state_and_data,
       [
         {:reply, from, "Nice key! Although not one suited for this lock"}
       ]}
    end
  end

  def fifth_box({:call, from}, {:unlock, _arg}, _data) do
    {:keep_state_and_data, [{:reply, from, @non_functional_key_message}]}
  end

  def done({:call, from}, _, _) do
    {:keep_state_and_data,
     [{:reply, from, "Nothing more to see here. Enjoy your gift and I hope you had fun."}]}
  end
end

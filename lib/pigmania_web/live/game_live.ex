defmodule PigmaniaWeb.GameLive do
  use Phoenix.LiveView
  alias Pigmania.Player
  use Phoenix.HTML
  require PigMania.Points

  @individual_points %{
    "sider" => 1,
    "hoofer" => 5,
    "razorback" => 5,
    "snouter" => 10,
    "jowler" => 15
  }

  @points PigMania.Points.build_points_table(@individual_points) |> IO.inspect()

  def render(assigns) do
    ~L"""
      <%= case @game_state do %>
      <%= :pregame -> %>
          <span>Players: <%= Enum.join(@players, ", ") %></span>

          <%= f = form_for :player, "#", [phx_submit: :save] %>
          <%= label f, :name %>
          <%= text_input f, :name %>
          <%= error_tag f, :name %>

          <%= submit "Add user" %>
          </form>


        <div>
          <button phx-click="start_game" phx-throttle="1000">Start Game</button>
        </div>
      <% :playing -> %>
        <div>Current turn: <%= @current_player %></div>
        <div>Turn points: <%= @turn_points %></div>

        <div>
        <%= for {player, score} <- Enum.sort_by(@scoreboard, fn {_k, v} -> v end) |> Enum.reverse() do %>
          <div><%= player %>: <%= score %></div>
        <% end %>
        </div>

        <%= if @is_last_turn do %>
          <h2>Last turn!</h2>
        <% end %>

        <hr />


    <%= if @mixed_combo do %>


      <%= if @pig_one == nil do %>
        <h3>Pig one?</h3>
      <% else %>
        <h3>Pig two?</h3>
      <% end %>


      <button phx-click="mc-hoofer">hoofer</button>
      <button phx-click="mc-razorback">razorback</button>
      <button phx-click="mc-snouter">snouter</button>
      <button phx-click="mc-jowler">leaning jowler</button>

    <% else %>

      <div>
        <button phx-click="pig-out">pig out</button>
        <button phx-click="makin-bacon">makin' bacon</button>
        <button phx-click="pig-mixed-combo">mixed combo</button>
      </div>

      <hr />

      <div>
        <button phx-click="pig-2x-sider">sider</button>
        <button phx-click="pig-hoofer">hoofer</button>
        <button phx-click="pig-razorback">razorback</button>
        <button phx-click="pig-snouter">snouter</button>
        <button phx-click="pig-jowler">leaning jowler</button>
      </div>

        <hr />

      <div>
        <button phx-click="pig-2x-hoofer">2x hoofer</button>
        <button phx-click="pig-2x-razorback">2x razorback</button>
        <button phx-click="pig-2x-snouter">2x snouter</button>
        <button phx-click="pig-2x-jowler">2x leaning jowler</button>
      </div>

    <% end %>



    <% :over -> %>
      <h2><%= Enum.sort_by(@scoreboard, fn {_player, score} -> score end) |> Enum.reverse() |> Enum.map(fn {player, _score} -> player end)|> List.first() %> wins!</h2>

      <div>
        <%= for {player, score} <- Enum.sort_by(@scoreboard, fn {_k, v} -> v end) |> Enum.reverse() do %>
          <div><%= player %>: <%= score %></div>
        <% end %>
      </div>

      <hr />

      <div>
        <button phx-click="new-game">new game</button>
      </div>

      <% end %>
    """
  end

  def handle_event(
        "new-game",
        _data,
        socket
      ) do
    {:ok, socket} = initial_socket(socket)
    {:noreply, socket}
  end

  def handle_event(
        "makin-bacon",
        _data,
        %{
          assigns: %{
            players: players,
            scoreboard: scoreboard,
            last_turn_count: last_turn_count,
            game_state: game_state
          }
        } = socket
      ) do
    [current_player | _] = players = rotate(players)

    is_last_turn? = Enum.any?(scoreboard, fn {_player, points} -> points >= 100 end)

    last_turn_inc =
      if is_last_turn? do
        1
      else
        0
      end

    last_turn_count = last_turn_count + last_turn_inc

    game_state =
      if last_turn_count == Enum.count(players) do
        :over
      else
        game_state
      end

    {:noreply,
     assign(socket,
       turn_points: 0,
       players: players,
       current_player: current_player,
       pig_one: nil,
       game_state: game_state
     )}
  end

  def handle_event(
        "pig-out",
        _data,
        %{
          assigns: %{
            turn_points: turn_points,
            scoreboard: scoreboard,
            players: players,
            current_player: current_player,
            last_turn_count: last_turn_count,
            game_state: game_state
          }
        } = socket
      ) do
    scoreboard =
      Map.update!(scoreboard, current_player, fn old_score -> old_score + turn_points end)

    [current_player | _] = players = rotate(players)

    is_last_turn? = Enum.any?(scoreboard, fn {_player, points} -> points >= 100 end)

    last_turn_inc =
      if is_last_turn? do
        1
      else
        0
      end

    last_turn_count = last_turn_count + last_turn_inc

    game_state =
      if last_turn_count == Enum.count(players) do
        :over
      else
        game_state
      end

    {:noreply,
     assign(socket,
       turn_points: 0,
       players: players,
       current_player: current_player,
       scoreboard: scoreboard,
       pig_one: nil,
       last_turn_count: last_turn_count,
       is_last_turn: is_last_turn?,
       game_state: game_state
     )}
  end

  def handle_event(
        "pig-2x-" <> pig_kind,
        _data,
        %{
          assigns: %{
            turn_points: turn_points
          }
        } = socket
      ) do
    points = Map.fetch!(@points, {pig_kind, pig_kind})

    {:noreply, assign(socket, turn_points: points + turn_points)}
  end

  def handle_event(
        "pig-mixed-combo",
        _data,
        socket
      ) do
    {:noreply, assign(socket, mixed_combo: true)}
  end

  def handle_event(
        "pig-" <> event,
        _data,
        %{
          assigns: %{
            turn_points: turn_points
          }
        } = socket
      ) do
    points = Map.fetch!(@points, {event, "sider"})
    {:noreply, assign(socket, turn_points: points + turn_points)}
  end

  def handle_event(
        "mc-" <> event,
        _data,
        %{
          assigns: %{
            turn_points: turn_points,
            pig_one: pig_one
          }
        } = socket
      ) do
    points = Map.get(@points, {pig_one, event}, :need_second_pig)

    if points == :need_second_pig do
      {:noreply, assign(socket, pig_one: event)}
    else
      {:noreply,
       assign(socket, turn_points: points + turn_points, pig_one: nil, mixed_combo: false)}
    end
  end

  def handle_event(
        "save",
        %{"player" => %{"name" => player_name}},
        %{assigns: %{players: players, scoreboard: scoreboard}} = socket
      ) do
    if String.length(player_name) > 0 do
      players = players ++ [player_name]
      scoreboard = Map.put(scoreboard, player_name, 0)
      {:noreply, assign(socket, players: players, scoreboard: scoreboard)}
    else
      {:noreply, socket}
    end
  end

  def handle_event(
        "start_game",
        %{},
        %{assigns: %{players: [first_player | _] = players}} = socket
      ) do
    if Enum.count(players) > 0 do
      {:noreply, assign(socket, game_state: :playing, current_player: first_player)}
    else
      {:noreply, socket}
    end
  end

  def initial_socket(socket) do
    {:ok,
     assign(
       socket,
       game_state: :pregame,
       players: [],
       current_player: nil,
       turn_points: 0,
       scoreboard: %{},
       mixed_combo: false,
       pig_one: nil,
       is_last_turn: false,
       last_turn_count: 0
     )}
  end

  def mount(_data, socket) do
    initial_socket(socket)
  end

  def rotate([]), do: []

  def rotate([item]) do
    [item]
  end

  def rotate([first | rest]) do
    rest ++ [first]
  end

  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, translate_error(error),
        class: "help-block",
        data: [phx_error_for: input_id(form, field)]
      )
    end)
  end

  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext "errors", "is invalid"
    #
    #     # Translate the number of files with plural rules
    #     dngettext "errors", "1 file", "%{count} files", count
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(DemoWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(DemoWeb.Gettext, "errors", msg, opts)
    end
  end
end

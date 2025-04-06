# The purpose of this file is to define and document the different types used to communicate between the users and the game server.

defmodule MindsterGames.Games.Types.ServerToUser do
  @typedoc """
  Union type for all requests.

  All requests follow the basic tuple structure `{ atom(), map() | nil }`.
  """
  @type request() ::
          wait_request()
          | select_request()
          | number_range_request()

  @typedoc """
  A wait request indicates to the user that they are waiting for somebody or something

  Options:
  - `title` prompt the user sees above the number range input
  """
  @type wait_request() ::
          {:wait, %{optional(:title) => String.t()}}

  @typedoc """
  Select request displays a series of buttons for the user to click one of

  Options:
  - `title` prompt the user sees above the number range input
  - `options` a list of tuples containing an `id` and the `text` to display to the user
  """
  @type select_request() ::
          {:select,
           %{
             optional(:title) => String.t(),
             options: list({String.t(), String.t()})
           }}

  @typedoc """
  Number range request displays a range input to the user

  Options:
  - `title` prompt the user sees above the number range input
  - `min` minimum value for the number range input
  - `max` maximum value for the number range input
  - `initial` initial value for the number range input
  """
  @type number_range_request() ::
          {:number_range,
           %{
             optional(:title) => String.t(),
             optional(:min) => integer(),
             optional(:max) => integer(),
             optional(:initial) => integer()
           }}
end

defmodule MindsterGames.Games.Types.UserToServer do
  @typedoc """
  Union type for all inputs.

  All inputs follow the basic tuple structure `{ atom(), any() }`.
  """
  @type input() ::
          select_input()
          | number_range_input()

  @typedoc """
  The answer to a `select_request()` with the second element of the tuple being the `id` of the selected option
  """
  @type select_input() :: {:select, binary()}

  @typedoc """
  The answer to a `number_range_request()` with the second element of the tuple being the selected integer value
  """
  @type number_range_input() :: {:number_range, integer()}
end

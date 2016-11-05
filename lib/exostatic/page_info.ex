defmodule Exostatic.PageInfo do
  @moduledoc """
  This module defines PageInfo struct.
  """

  @derive [Poison.Encoder]
  defstruct [:name, :type, :title, :menu, :menu_text, :menu_icon]
end

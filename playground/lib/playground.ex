defmodule Playground do
  @moduledoc """
  Documentation for `Playground`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Playground.hello()
      :world

  """
  def inc(x) do
    x + 1
  end

  def dec(x) do
    x - 1
  end

  def multi(x) do
    Playground.inc(x)
    |> Playground.inc()
    |> Playground.inc()
    |> Playground.dec()
  end

  def hello do
    :world
  end
end

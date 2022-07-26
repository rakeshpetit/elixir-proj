defmodule Identicon do
  @moduledoc """
    This module enables to generate Identicons from a string.
  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  @doc """
    This method generates the pixel map from a string.

    ## Examples
      iex> image = Identicon.hash_input("developer") |> Identicon.pick_color |> Identicon.build_grid |> Identicon.filter_odd_squares |> Identicon.build_pixel_map
      iex> image.pixel_map
      [{{0, 0}, {50, 50}}, {{50, 0},
      {100, 50}}, {{150, 0}, {200, 50}},
      {{200,0}, {250, 50}}, {{100, 100},
      {150, 150}}, {{100, 150}, {150, 200}},
      {{50, 200}, {100, 250}}, {{100, 200},
      {150, 250}}, {{150,200}, {200, 250}}]
  """
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
    This method filters the odd squares from the pixel map.

    ## Examples
      iex> image = Identicon.hash_input("developer") |> Identicon.pick_color |> Identicon.build_grid |> Identicon.filter_odd_squares
      iex> image.grid
      [{94, 0},{142, 1},{142, 3},{94, 4},{116, 12},{44, 17},{54, 21},{124,
      22},{54, 23}]
  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {code, _index} ->
        rem(code, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  @doc """
    This method builds the grid to be used as 5x5 pixel map.

    ## Examples
      iex> image = Identicon.hash_input("developer") |> Identicon.pick_color |> Identicon.build_grid
      iex> image.grid
      [{94, 0}, {142, 1}, {221, 2}, {142, 3}, {94, 4}, {133, 5}, {29, 6}, {47,
      7}, {29, 8}, {133, 9}, {223, 10}, {189, 11}, {116, 12}, {189, 13}, {223,
      14}, {21, 15}, {35, 16}, {44, 17}, {35, 18}, {21, 19}, {103, 20}, {54,
      21}, {124, 22}, {54, 23}, {103, 24}]
  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row(row) do
    [first, second | _tail] = row

    row ++ [second, first]
  end

  @doc """
    This method hashes the input string.

    ## Examples
      iex> image = Identicon.hash_input("developer") |> Identicon.pick_color
      iex> image.color
      {94, 142, 221}
  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
    This method hashes the input string.

    ## Examples
      iex> image = Identicon.hash_input("developer")
      iex> image.hex
      [94, 142, 221, 133, 29, 47, 223, 189, 116, 21, 35, 44, 103, 54, 124, 195]
  """
  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %Identicon.Image{hex: hex}
  end
end

defmodule UkraineNbuqrEx.Amount.Validator do
  alias UkraineNbuqrEx.Amount
  import UkraineNbuqrEx.Commons, only: [ok: 1]

  @moduledoc """
  Amount.Validator validates amount structs
  Correct amount must be less than 999_999_999.99 and greater than 0
  """

  @doc """
  validate/1 validates amount struct

  ## Examples

  ```elixir
      iex> UkraineNbuqrEx.Amount.Validator.validate(%UkraineNbuqrEx.Amount{units: "100", cents: "5"})
      {:ok, %UkraineNbuqrEx.Amount{units: "100", cents: "5"}}

      iex> UkraineNbuqrEx.Amount.Validator.validate(%UkraineNbuqrEx.Amount{units: "999999999", cents: "99"})
      {:ok, %UkraineNbuqrEx.Amount{units: "999999999", cents: "99"}}

      iex> UkraineNbuqrEx.Amount.Validator.validate(%UkraineNbuqrEx.Amount{units: "0", cents: "01"})
      {:ok, %UkraineNbuqrEx.Amount{units: "0", cents: "01"}}

      iex> UkraineNbuqrEx.Amount.Validator.validate(%UkraineNbuqrEx.Amount{units: "1000000000", cents: nil})
      {:error, "Amount greather then 999999999.99"}

      iex> UkraineNbuqrEx.Amount.Validator.validate(%UkraineNbuqrEx.Amount{units: "1000000000", cents: "1"})
      {:error, "Amount greather then 999999999.99"}

      iex> UkraineNbuqrEx.Amount.Validator.validate(%UkraineNbuqrEx.Amount{units: "0", cents: nil})
      {:error, "Zero amount"}
  ```
  """

  @spec validate(amount :: Amount.t() | {:error, String.t()}) :: Amount.t() | {:error, String.t()}
  def validate({:error, _message} = error), do: error
  def validate({:ok, amount}), do: validate(amount)

  def validate(%Amount{units: units, cents: cents} = amount) do
    case {units, cents, String.length(units)} do
      {_units, _cents, units_length} when units_length > 9 ->
        {:error, "Amount greather then 999999999.99"}

      {"0", nil, _units_length} ->
        {:error, "Zero amount"}

      _ ->
        ok(amount)
    end
  end
end

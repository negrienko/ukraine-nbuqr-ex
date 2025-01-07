defmodule UkraineNbuqrEx.Amount do
  @moduledoc """
  The UkraineNbuqrEx.Amount module handles parsing and formatting of monetary amounts
  for Ukrainian hryvnia (UAH) in the context of NBU QR codes.

  The module provides functionality to:
  - Parse string amounts into a structured format
  - Validate monetary amounts according to NBU specifications
  - Format amounts back to strings in the required NBU QR code format
  """

  alias UkraineNbuqrEx.Amount.Validator

  defstruct units: "0", cents: nil

  @typedoc """
  Amounts are represented as a struct with two fields:
  - `units`: The whole number part of the amount (hryvnias)
  - `cents`: The decimal part of the amount (kopiykas), optional
  """
  @type t :: %__MODULE__{
          units: String.t(),
          cents: String.t() | nil
        }

  @currency "UAH"
  @decimal_separator "."
  @regex ~r/(?<units>\d+)([,.]?(?<cents>\d{0,2}))/

  @doc """
  `validate/1` validates amount structure according to NBU requirements.

  Validation rules include:
  - Units must be a non-negative integer not exceeding 999,999,999
  - If cents are present, they must be between 0 and 99
  - Overall amount format must conform to NBU QR code specifications

  Delegate to `UkraineNbuqrEx.Amount.Validator.validate/1`

  ## Parameters
    - amount: A struct containing the parsed amount with units and optional cents

  ## Returns
    - `{:ok, amount}` if validation passes
    - `{:error, message}` if validation fails

  ## Examples

  ```elixir
      iex> UkraineNbuqrEx.Amount.validate(%UkraineNbuqrEx.Amount{units: "123", cents: "45"})
      {:ok, %UkraineNbuqrEx.Amount{units: "123", cents: "45"}}

      iex> UkraineNbuqrEx.Amount.validate(%UkraineNbuqrEx.Amount{units: "999999999", cents: nil})
      {:ok, %UkraineNbuqrEx.Amount{units: "999999999", cents: nil}}

      iex> UkraineNbuqrEx.Amount.validate(%UkraineNbuqrEx.Amount{units: "1000000000", cents: nil})
      {:error, "Amount greather then 999999999.99"}
  ```
  """
  @spec validate(amount :: t() | {:ok, t()} | {:error, String.t()}) ::
          {:ok, t()} | {:error, String.t()}
  defdelegate validate(amount), to: Validator

  @doc """
  `normalize/1` format amount by parsing and converting amount back to string

  ## Examples

  ```elixir
      iex> UkraineNbuqrEx.Amount.normalize("0123.40")
      "UAH123.4"

      iex> UkraineNbuqrEx.Amount.normalize("123")
      "UAH123"
  ```
  """
  @spec normalize(value :: String.t()) :: String.t() | {:error, String.t()}
  def normalize(value) do
    value
    |> parse()
    |> to_str()
  end

  @doc """
  `parse/1` cleans, splits, and validates the amount. It returns a struct with units and cents. If the amount is invalid, it returns an error tuple

  ## Examples

  ```elixir
      iex> UkraineNbuqrEx.Amount.parse("123.45")
      {:ok, %UkraineNbuqrEx.Amount{units: "123", cents: "45"}}
  ```
  """
  @spec parse(String.t()) :: {:ok, t()} | {:error, String.t()}
  def parse(value) do
    value
    |> clean()
    |> split()
    |> atomize()
    |> parse_units()
    |> parse_cents()
    |> then(
      &case &1 do
        value when is_map(value) -> struct(__MODULE__, value)
        {:error, _error} = error -> error
      end
    )
    |> validate()
  end

  @doc """
  `to_str/1` converts Amount struct to string representation in Ukrainian hryvnas formatted compatible with NBU QR code specification (with cents only if it exists and correct decimal separator)
  """
  @spec to_str(t() | {:ok, t()}) :: String.t()
  def to_str({:ok, amount}), do: join(amount)
  def to_str({:error, _message} = error), do: error
  def to_str(amount), do: join(amount)

  # Helper functions:
  #    - `clean/1`: Removes whitespace from input
  #    - `atomize/1`: Converts map with string keys to atom keys
  #    - `split/1`: Splits amount into units and cents using regex
  #    - `validate/1`: Validates the parsed amount
  #    - `parse_cents/1`: Formats cents part
  #    - `parse_units/1`: Formats units part
  #    - `join/1`: Joins parts into final string format
  defp clean(value), do: String.replace(value, ~r/\s/, "")

  defp atomize(%{"units" => units, "cents" => cents}), do: %{units: units, cents: cents}
  defp atomize(nil), do: {:error, "Invalid amount"}

  defp split(value), do: Regex.named_captures(@regex, value)

  defp join({:ok, data}), do: join(data)
  defp join({:error, _message} = error), do: error
  defp join(%{units: units, cents: nil}), do: @currency <> units
  defp join(%{units: units, cents: cents}), do: @currency <> units <> @decimal_separator <> cents

  defguardp is_zero_cents(cents) when cents in ["00", "0", ""]
  defguardp is_zero_units(units) when units in ["0", ""]

  defp parse_cents({:error, _message} = error), do: error

  defp parse_cents(%{cents: cents} = amount) when is_zero_cents(cents),
    do: Map.put(amount, :cents, nil)

  defp parse_cents(%{cents: cents} = amount),
    do: Map.put(amount, :cents, String.replace_trailing(cents, "0", ""))

  defp normalize_zero_unit(units) when is_zero_units(units), do: "0"
  defp normalize_zero_unit(units), do: units

  defp parse_units({:error, _message} = error), do: error

  defp parse_units(%{units: units} = amount) do
    units
    |> String.replace_leading("0", "")
    |> normalize_zero_unit()
    |> then(&Map.put(amount, :units, &1))
  end
end

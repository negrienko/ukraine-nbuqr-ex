defmodule UkraineNbuqrEx.QrData.Builder do
  @moduledoc """
  A module for building National Bank of Ukraine (NBU) payment Quick Response (QR) code data structures.
  """

  alias IbanEx.Parser, as: IbanParser
  alias IbanEx.Formatter, as: IbanFormatter
  alias UkraineTaxidEx, as: Taxid
  alias UkraineNbuqrEx.{Amount, QrData}
  import UkraineNbuqrEx.Commons, only: [ok: 1]

  @length_restrictions %{
    recipient: 70,
    amount: 15,
    tax_id: 10,
    iban: 34,
    purpose: 140
  }

  @doc """
  Builds a QR data struct from the given parameters.

  This builder validates and formats payment information according to NBU QR code specifications.
  It enforces required fields and length restrictions for various payment details.

  ## Length Restrictions

  The following maximum length restrictions are enforced:
  - recipient: 70 characters
  - amount: 15 characters
  - tax_id: 10 characters
  - iban: 34 characters
  - purpose: 140 characters

  ## Usage

  ```elixir
      iex> params = [
      ...>   iban: "UA213223130000026007233566001",
      ...>   tax_id: "12345678",
      ...>   amount: "123.45",
      ...>   recipient: "Company Name",
      ...>   purpose: "Payment for services"
      ...> ]
      ...> UkraineNbuqrEx.QrData.Builder.build(params)

      {:ok, %UkraineNbuqrEx.QrData{recipient: "Company Name", iban: "UA213223130000026007233566001", amount: "UAH123.45", tax_id: "12345678", purpose: "Payment for services"}} = UkraineNbuqrEx.QrData.Builder.build(params)
  ```

  ## Required Parameters

  All of the following parameters are required:
  - `:iban` - Ukrainian IBAN (must start with "UA")
  - `:tax_id` - Valid Ukrainian tax identification number
  - `:amount` - Payment amount (will be normalized)
  - `:recipient` - Name of the payment recipient
  - `:purpose` - Purpose of payment

  The builder will return an error if any required parameter is missing or invalid.

  ## Validation

  - IBAN is validated to ensure it's a valid Ukrainian IBAN
  - Tax ID is validated using the UkraineTaxidEx library
  - Amount is validated and normalized to ensure proper format
  - All text fields are truncated to their maximum allowed lengths

  """
  @spec build(params :: Keyword.t()) :: QrData.t()
  def build(params) do
    {params, %{}}
    |> process_option(:iban, &iban/1)
    |> process_option(:tax_id, &tax_id/1)
    |> process_option(:amount, &amount/1)
    |> process_option(:recipient)
    |> process_option(:purpose)
    |> case do
      {:error, error} -> {:error, error}
      {_options, map} -> {:ok, struct(QrData, map)}
    end
  end

  defp iban(iban) do
    case IbanParser.parse(iban) do
      {:ok, %IbanEx.Iban{country_code: "UA"} = iban} -> iban |> IbanFormatter.compact() |> ok()
      _ -> {:error, "Invalid IBAN"}
    end
  end

  defp tax_id(tax_id) do
    case Taxid.parse(tax_id) do
      {:ok, %{code: code}, _tax_id_type} -> ok(code)
      _ -> {:error, "Invalid Tax ID"}
    end
  end

  defp amount(amount) do
    amount
    |> Amount.normalize()
    |> ok()
  end

  defp process_option(options_and_data, name, processor \\ &ok/1)

  defp process_option({:error, _error} = negative, _name, _processor), do: negative

  defp process_option({options, data}, name, processor) do
    options
    |> Keyword.get(name)
    |> case do
      nil -> {:error, "Option #{name} is required"}
      value -> do_process_option({options, data}, name, processor, value)
    end
  end

  defp do_process_option({options, data}, name, processor, value) do
    value
    |> processor.()
    |> limiter(name)
    |> case do
      {:ok, result} -> {options, Map.put_new(data, name, result)}
      error -> error
    end
  end

  defp limiter({:error, _error} = error, _name), do: error
  defp limiter({:ok, value}, name), do: limiter(value, name)

  defp limiter(value, name) when is_binary(value) do
    length = Map.get(@length_restrictions, name, 0)

    value
    |> String.slice(0, length)
    |> ok()
  end
end

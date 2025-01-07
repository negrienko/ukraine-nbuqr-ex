defmodule UkraineNbuqrEx.QrData do
  @moduledoc """
  Defines a struct representing the open data part of National Bank of Ukraine (NBU) payment Quick Response (QR) Code.

  ## Struct Fields

    * `:recipient` - The name of the payment recipient
    * `:iban` - International Bank Account Number
    * `:amount` - Payment amount
    * `:tax_id` - Tax identification number
    * `:purpose` - Purpose of payment/transaction

  ## Example

  ```elixir
      %UkraineNbuqrEx.QrData{
        recipient: "Company Name Ltd",
        iban: "UA213223130000026007233566001",
        amount: "1000.00",
        tax_id: "12345678",
        purpose: "Payment for services"
      }
  ```

  All fields are required when creating a new QrData struct.
  """

  @typedoc "NBU QR Data structure containing payment information"
  @type t :: %__MODULE__{
          recipient: String.t(),
          iban: String.t(),
          amount: String.t(),
          tax_id: String.t(),
          purpose: String.t()
        }

  @enforce_keys [:recipient, :iban, :amount, :tax_id, :purpose]

  defstruct [
    :recipient,
    :iban,
    :amount,
    :tax_id,
    :purpose
  ]
end

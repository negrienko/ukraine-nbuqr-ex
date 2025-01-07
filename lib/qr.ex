defmodule UkraineNbuqrEx.Qr do
  @moduledoc """
  This module is designed to generate Payment QR codes according to the National Bank of Ukraine (NBU) QR code standard.
  """

  alias UkraineNbuqrEx.Qr.{Config, Encoding, Version}
  alias UkraineNbuqrEx.QrData
  import UkraineNbuqrEx.Commons, only: [ok: 1]

  @default_options [
    background_color: :transparent
  ]

  @type output_data :: {:error, String.t()} | {:ok, String.t()}
  @type input_data :: output_data | String.t()

  @doc """
  `to_string/2`  converts QR data struct to string representation of open data of invoice
  Combines QR data struct (service label, version, encoding, function, recipient, IBAN, amount, tax ID, purpose) into a string representation  with newline separators.

  Takes optional formatting options:
    - **encoding** specifies encoding (defaults to value from Config.encoding())
    - **version** specifies version (defaults to value from Config.version())
  """
  @spec to_string(data :: QrData.t(), options :: Keyword.t()) :: output_data
  def to_string(data, options \\ @default_options)

  def to_string(data, options) do
    encoding = Encoding.encoding(Keyword.get(options, :encoding, Config.encoding()))
    version = Version.normalize(Keyword.get(options, :version, Config.version()))

    [
      Config.service_label(),
      version,
      encoding,
      Config.function(),
      "",
      data.recipient,
      data.iban,
      data.amount,
      data.tax_id,
      "",
      "",
      data.purpose
    ]
    |> Enum.join("\n")
    |> ok()
  end

  @doc """
  `encode/1` encodes the invoice string to Base64 format uses URL-safe Base64 encoding without padding
  """
  @spec encode(data :: input_data()) :: output_data
  def encode({:error, _error} = negative), do: negative
  def encode({:ok, data}), do: encode(data)

  def encode(data) do
    data
    |> Base.url_encode64(padding: false)
    |> ok()
  end

  @doc """
  Generates a complete QR link with encoded invoice data
  """
  @spec to_link(encoded :: input_data()) :: output_data
  def to_link({:error, _error} = negative), do: negative
  def to_link({:ok, encoded}), do: to_link(encoded)

  def to_link(encoded) do
    ok(Config.base_url() <> encoded)
  end

  @doc """
  `to_qr/2` generates a QR from the given data and options.

  **format** option specifies the function for formatiing QR code.
  The default is &Config.svg/2. Complete list of format functions returns by Config.formats:
    - **&Config.svg/2** generates an SVG image
    - **&Config.png/2** generates a PNG image
    - **&Config.ascii/2** generates a text representation of the QR code

  Available options for all formats:
    - **color** in hexadecimal format. The default is #000
    - **background_color** in hexadecimal format or :transparent. The default is #FFF.
    - **width** the width of the QR code in pixel. Without the width attribute, the QR code size will be dynamically generated based on the input string.

  Options avaliable for SVG format:
    - **shape** only square or circle. The default is square
    - **viewbox** when set to true, the SVG element will specify its height and width using viewBox, instead of explicit height and width tags.

  Default options are
  ```elixir
    [color: "#000", shape: "square", background_color: "#FFF"]
  ```

  """
  @spec to_qr(link :: input_data(), options :: Keyword.t()) :: output_data
  def to_qr(data, options \\ @default_options)
  def to_qr({:error, _error} = negative, _options), do: negative
  def to_qr({:ok, link}, options), do: to_qr(link, options)

  def to_qr(link, options) do
    format = Keyword.get(options, :format, &Config.default_format/2)

    link
    |> EQRCode.encode()
    |> format.(options)
    |> ok()
  end

  @doc """
  Generates a QR code from the given data and options.
  As opttions it accepts the same options as to_qr/2 and to_string/2 functions.
  """
  @spec create(data :: QrData.t(), options :: Keyword.t()) :: output_data
  def create(data, options \\ @default_options)

  def create(data, options) do
    data
    |> __MODULE__.to_string(options)
    |> encode()
    |> to_link()
    |> to_qr(options)
  end
end

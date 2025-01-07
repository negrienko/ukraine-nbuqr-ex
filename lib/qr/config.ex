defmodule UkraineNbuqrEx.Qr.Config do
  @moduledoc """
  Configuration constants for QR code generation
  """

  alias UkraineNbuqrEx.Qr.{Encoding, Version}

  @doc "base_url/0 returns base URL for QR Code generation"
  def base_url, do: "https://bank.gov.ua/qr/"

  @doc "service_label/0 returns default service label for QR Code is ”BCD“"
  def service_label, do: "BCD"

  @doc "function/0 returns default function of QR Code is ”UCT“ (Ukrainian Credit Transfer)"
  def function, do: "UCT"

  @doc "default_format/0 returns function that generetes QR Code in default format SVG (delegetes to EQRCode module)"
  defdelegate svg(data, options), to: EQRCode

  defdelegate png(data, options), to: EQRCode

  def ascii(data, _options), do: EQRCode.render(data)

  def default_format(data, options), do: svg(data, options)

  def formats, do: [&__MODULE__.svg/2, &__MODULE__.png/2, &__MODULE__.ascii/2]

  @doc "encoding/0 returns default encoding for QR Code is 1 (UTF-8) (delegetes to Encoding module)"
  defdelegate encoding, to: Encoding, as: :default

  @doc "version/0 returns default version for QR Code is 1 (delegetes to Version module)"
  defdelegate version, to: Version, as: :default
end

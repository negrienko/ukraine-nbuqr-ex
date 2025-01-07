defmodule UkraineNbuqrEx.Qr.Version do
  @typedoc """
  QR Data Version. By default use the 1 version.
  """
  @type t() :: String.t()
  @default_version 1
  @versions [1, 2]

  @spec default() :: t()
  def default(), do: normalize!()

  @spec normalize(version :: pos_integer() | String.t()) :: t() | nil
  def normalize(version \\ @default_version)
  def normalize(version) when is_binary(version), do: normalize(String.to_integer(version))
  def normalize(version) when version not in @versions, do: nil
  def normalize(version) when version in @versions, do: normalize!(version)

  @spec normalize!(version :: pos_integer()) :: t()
  def normalize!(version \\ @default_version)
  def normalize!(version) when is_binary(version), do: normalize!(String.to_integer(version))

  def normalize!(version) when version not in @versions do
    raise ArgumentError,
          "Invalid version: #{version}. Supported versions: #{Enum.join(@versions, ", ")}"
  end

  def normalize!(version) when version in @versions do
    version
    |> Integer.to_string()
    |> String.pad_leading(3, "0")
  end
end

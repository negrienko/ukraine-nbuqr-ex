defmodule UkraineNbuqrEx.Qr.Encoding do
  @typedoc """
  QR Data Encoding
  1 - UTF-8 (default)
  2 - WIN 1251
  """
  @type t() :: 1 | 2
  @default_encoding 1

  @encodings %{
    1 => "UTF-8",
    2 => "windows-1251"
  }

  @labels %{
    "1" => 1,
    "utf8" => 1,
    "unicode-1-1-utf-8" => 1,
    "unicode11utf8" => 1,
    "unicode20utf8" => 1,
    "utf-8" => 1,
    "x-unicode20utf8" => 1,
    "2" => 2,
    "windows-1251" => 2,
    "cp1251" => 2,
    "win" => 2,
    "win1251" => 2,
    "windows" => 2,
    "windows1251" => 2,
    "win-1251" => 2,
    "x-cp1251" => 2
  }

  @spec default() :: t()
  def default(), do: @default_encoding

  @spec label(encoding :: t()) :: String.t() | {:error, String.t()}
  def label(encoding), do: Map.get(@encodings, encoding, {:error, "Unknown encoding"})

  def encodings(), do: @encodings

  @doc "label/1 returns encoding by label or {:error, “Unknown encoding”} if label is unknown encoding numbers also may be used as labels"
  @spec label(label :: String.t() | pos_integer()) :: t() | {:error, String.t()}
  def encoding(label) when is_binary(label) or is_integer(label) do
    value = String.downcase("#{label}")
    Map.get(@labels, value, {:error, "Unknown encoding"})
  end
end

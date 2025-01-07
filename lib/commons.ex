defmodule UkraineNbuqrEx.Commons do
  def negative({:error, _error} = negative), do: negative
  def positive({:ok, data} = _positive, function), do: function.(data)

  def ok({:error, _message} = error), do: error
  def ok({:ok, _data} = ok), do: ok
  def ok(data), do: {:ok, data}
end

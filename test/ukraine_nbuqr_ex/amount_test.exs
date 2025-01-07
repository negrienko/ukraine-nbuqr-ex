defmodule UkraineNbuqrEx.AmountTest do
  use ExUnit.Case
  doctest UkraineNbuqrEx.Amount

  alias UkraineNbuqrEx.Amount

  describe "normalize/1" do
    test "normalizes valid amount" do
      assert "UAH100.5" = Amount.normalize("100.50")
    end

    test "normalizes amount with spaces" do
      assert "UAH100.5" = Amount.normalize("100 . 50")
    end

    test "normalizes amount with leading zeros" do
      assert "UAH100" = Amount.normalize("000100")
    end

    test "normalizes amount with trailing zeros in cents" do
      assert "UAH100.5" = Amount.normalize("100.50")
    end

    test "normalizes amount with comma separator" do
      assert "UAH100.5" = Amount.normalize("100,50")
    end

    test "normalizes zero amount get invalid result" do
      assert {:error, "Zero amount"} = Amount.normalize("0")
      assert {:error, "Zero amount"} = Amount.normalize("0.00")
      assert {:error, "Zero amount"} = Amount.normalize("000")
    end
  end

  describe "parse/1" do
    test "parses valid amount" do
      assert {:ok, %Amount{units: "100", cents: "5"}} = Amount.parse("100.50")
    end

    test "parses amount without cents" do
      assert {:ok, %Amount{units: "100", cents: nil}} = Amount.parse("100")
    end

    test "parses amount with leading zeros" do
      assert {:ok, %Amount{units: "100", cents: nil}} = Amount.parse("000100")
    end

    test "parses zero amount" do
      assert {:error, "Zero amount"} = Amount.parse("0")
    end

    test "parses amount with comma separator" do
      assert {:ok, %Amount{units: "100", cents: "5"}} = Amount.parse("100,50")
    end
  end

  describe "to_str/1" do
    test "converts Amount to string with decimal" do
      amount = %Amount{units: "100", cents: "50"}
      assert "UAH100.50" = Amount.to_str(amount)
    end

    test "converts Amount to string without decimal" do
      amount = %Amount{units: "100", cents: nil}
      assert "UAH100" = Amount.to_str(amount)
    end

    test "converts zero Amount to string" do
      amount = %Amount{units: "0", cents: nil}
      assert "UAH0" = Amount.to_str(amount)
    end
  end
end

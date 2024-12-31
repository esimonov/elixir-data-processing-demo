defmodule DataServer.HTTPAPI.HelpersTest do
  use ExUnit.Case, async: true
  alias DataServer.HTTPAPI.Helpers

  describe "validate_limit/1" do
    test "returns default limit when input is 0" do
      assert Helpers.validate_limit("0") == {:ok, 10}
    end

    test "returns default limit when input is empty string" do
      assert Helpers.validate_limit("") == {:ok, 10}
    end

    test "returns parsed limit when input is within the max limit" do
      assert Helpers.validate_limit("5") == {:ok, 5}
    end

    test "caps limit at the max limit" do
      assert Helpers.validate_limit("50") == {:ok, 20}
    end

    test "returns error for negative limit" do
      assert Helpers.validate_limit("-5") == {:error, "Invalid limit: must be a positive integer"}
    end

    test "returns error for non-integer limit" do
      assert Helpers.validate_limit("abc") ==
               {:error, "Invalid limit: must be a positive integer"}
    end

    test "returns error for nil limit" do
      assert Helpers.validate_limit(nil) ==
               {:error, "Invalid limit: must be a non-negative integer"}
    end

    test "allows custom default and max limits" do
      assert Helpers.validate_limit("0", default_limit: 15) == {:ok, 15}
      assert Helpers.validate_limit("30", max_limit: 25) == {:ok, 25}
    end
  end

  describe "validate_offset/1" do
    test "returns parsed offset when input is valid" do
      assert Helpers.validate_offset("10") == {:ok, 10}
    end

    test "returns 0 for empty string" do
      assert Helpers.validate_offset("") ==
               {:ok, 0}
    end

    test "returns error for negative offset" do
      assert Helpers.validate_offset("-1") ==
               {:error, "Invalid offset: must be a non-negative integer"}
    end

    test "returns error for non-integer offset" do
      assert Helpers.validate_offset("abc") ==
               {:error, "Invalid offset: must be a non-negative integer"}
    end

    test "returns error for nil offset" do
      assert Helpers.validate_offset(nil) ==
               {:error, "Invalid offset: must be a non-negative integer"}
    end
  end
end

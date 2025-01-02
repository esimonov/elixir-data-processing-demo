defmodule DataServer.HTTPAPI.PaginationTest do
  use ExUnit.Case, async: true
  alias DataServer.HTTPAPI.Pagination

  describe "validate_limit/1" do
    test "returns default limit when input is 0" do
      assert Pagination.validate_limit("0") == {:ok, 10}
    end

    test "returns default limit when input is nil" do
      assert Pagination.validate_limit(nil) == {:ok, 10}
    end

    test "returns default limit when input is empty string" do
      assert Pagination.validate_limit("") == {:ok, 10}
    end

    test "returns parsed limit when input is within the max limit" do
      assert Pagination.validate_limit("5") == {:ok, 5}
    end

    test "caps limit at the max limit" do
      assert Pagination.validate_limit("50") == {:ok, 20}
    end

    test "returns error for negative limit" do
      assert Pagination.validate_limit("-5") ==
               {
                 :error,
                 :validation_error,
                 "Invalid limit: must be a non-negative integer; got '-5'"
               }
    end

    test "returns error for non-integer limit" do
      assert Pagination.validate_limit("abc") ==
               {
                 :error,
                 :validation_error,
                 "Invalid limit: must be a non-negative integer; got 'abc'"
               }
    end

    test "allows custom default and max limits" do
      assert Pagination.validate_limit("0", default_limit: 15) == {:ok, 15}
      assert Pagination.validate_limit("30", max_limit: 25) == {:ok, 25}
    end
  end

  describe "validate_offset/1" do
    test "returns parsed offset when input is valid" do
      assert Pagination.validate_offset("10") == {:ok, 10}
    end

    test "returns 0 for nil offset" do
      assert Pagination.validate_offset(nil) ==
               {:ok, 0}
    end

    test "returns 0 for empty string offset" do
      assert Pagination.validate_offset("") ==
               {:ok, 0}
    end

    test "returns error for negative offset" do
      assert Pagination.validate_offset("-1") ==
               {
                 :error,
                 :validation_error,
                 "Invalid offset: must be a non-negative integer; got '-1'"
               }
    end

    test "returns error for non-integer offset" do
      assert Pagination.validate_offset("abc") ==
               {
                 :error,
                 :validation_error,
                 "Invalid offset: must be a non-negative integer; got 'abc'"
               }
    end
  end
end

defmodule Sips.UserTest do
  use Sips.ModelCase

  alias Sips.User

  @valid_attrs %{email: "mike@example.com", password: "blah1234", password_confirmation: "blah1234"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end

defmodule Sips.UserView do
  use Sips.Web, :view
  use JaSerializer.PhoenixView

  attributes [:email]

end

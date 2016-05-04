defmodule Sips.UserView do
  use Sips.Web, :view
  use JaSerializer.PhoenixView

  attributes [:email]
  has_many :goals, link: :goals_link

  def goals_link(user, conn) do
    user_goals_url(conn, :index, user.id)
  end

end

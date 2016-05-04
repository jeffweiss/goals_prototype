defmodule Sips.GoalView do
  use Sips.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name]
  has_one :owner, link: :user_link

  def user_link(goal, conn) do
    user_url(conn, :show, goal.owner_id)
  end

end

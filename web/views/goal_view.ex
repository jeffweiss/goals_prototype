defmodule Sips.GoalView do
  use Sips.Web, :view
  use JaSerializer.PhoenixView

  location :goal_url
  attributes [:name]
  has_one :owner, link: :user_link

  def goal_url(goal, conn) do
    goal_url(conn, :show, goal)
  end

  def user_link(goal, conn) do
    user_url(conn, :show, goal.owner_id)
  end

end

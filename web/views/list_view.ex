defmodule Sips.ListView do
  use Sips.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name]
  has_one :owner, link: :user_link
  has_many :goals, link: :goal_link

  def user_link(list, conn) do
    user_url(conn, :show, list.owner_id)
  end

  def goal_link(list, conn) do
    goal_links(list.goals, conn)
  end

  defp goal_links(goals, conn) when is_list(goals) do
    for goal <- goals, do: goal_url(conn, :show, goal.id)
  end
  defp goal_links(_, _), do: []

end

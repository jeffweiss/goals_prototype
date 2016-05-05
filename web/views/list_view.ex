defmodule Sips.ListView do
  use Sips.Web, :view
  use JaSerializer.PhoenixView
  require Ecto.Query

  location :list_url
  attributes [:name]
  has_one :owner, link: :user_link
  has_many :goals, serializer: Sips.GoalView, link: :goal_link

  def goals(list, _conn) do
    Ecto.Query.from(l in Sips.List, join: g in assoc(l, :goals), where: l.id == ^list.id, select: g)
    |> Sips.Repo.all
  end

  def list_url(list, conn) do
    list_url(conn, :show, list)
  end

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

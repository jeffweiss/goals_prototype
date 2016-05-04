defmodule Sips.MeasureView do
  use Sips.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :inserted_at, :value]
  has_one :goal, link: :goal_link

  def goal_link(measure, conn) do
    goal_url(conn, :show, measure.goal_id)
  end
end

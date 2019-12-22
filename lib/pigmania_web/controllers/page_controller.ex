defmodule PigmaniaWeb.PageController do
  use PigmaniaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

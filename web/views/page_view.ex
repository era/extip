defmodule Extip.PageView do
  use Extip.Web, :view

  def csrf_token(conn) do
    Map.get(conn.req_cookies, "_csrf_token")
  end
end

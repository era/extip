defmodule Extip.PageController do
  use Extip.Web, :controller
  alias Extip.Router
  import Extip.Router.Helpers
  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end

  def thanks(conn, _params) do
    render conn, "thanks.html"
  end

  def error(conn, _), do: render(conn, "error.html")

  def create(conn, pay_struct = %{"pay" => %{"name" => name, "value" => value, "number" => number, "cvv" => cvv, "type" => type, "expires" => expires}, "_csrf_token" => _}) do
    [firstname | surname] = String.split(name, " ")
    surname = Enum.join(surname)
    [expire_month | [expire_year | _]] = String.split(expires, "/")
    payment = %Paypal.Payment{intent: "sale", payer: %{"funding_instruments" => [%{"credit_card" => %{"cvv2" => cvv, "expire_month" => expire_month, "expire_year" => expire_year, "first_name" => firstname, "last_name" => surname, "number" => number, "type" => type}}], "payment_method" => "credit_card"}, transactions: [%{"amount" => %{"currency" => "USD", "total" => value}, "description" => "Donation to 'Pay me a coffee'."}]}

    Payment.create_payment(payment)
    |> Task.await(10000000)
    |> redirect_user conn, pay_struct
  end

  defp redirect_user({:ok, result}, conn, pay_struct) do
    IO.puts inspect result
    if "approved" == result["state"] do 
      redirect conn, to: page_path(conn, :thanks)
    else
      conn 
      |> put_flash(:error, "Paypal returned: " <>result["state"] <> ". Please, check if everything is correct")
      |> error([])
    end
  end
  defp redirect_user({_, _}, conn, pay_struct) do
    conn 
    |> put_flash(:error, "There was an error with Paypal, please try again latter")
    |> error([])
  end
end




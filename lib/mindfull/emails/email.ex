defmodule Mindfull.Emails.Email do
  @moduledoc false
  import Bamboo.Email

  def welcome_email(email, body) do
    new_email(
      to: email,
      from: "contact@mindful.us",
      subject: "Welcome to Mindfull Us!",
      text_body: body,
      html_body: body
    )
  end
end

use Mix.Config

config :appsignal, :config,
  otp_app: :url_shortener,
  name: "url_shortener",
  push_api_key: "fc17fb8e-f96d-4769-b692-bd69644ad16e",
  env: Mix.env()

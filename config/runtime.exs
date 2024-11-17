import Config

config :openai,
  # find it at https://platform.openai.com/account/api-keys
  api_key: System.fetch_env!("OPENAI_API_KEY"),
  # find it at https://platform.openai.com/account/org-settings under "Organization ID"
  organization_key: System.fetch_env!("OPENAI_ORG_ID")

### Setup

Make sure you have Postgres and Redis running on the default ports. Create a "y_dev" database with the username: user and password: password123.
Run: mix deps.get in the root directory to get dependencies.
Run: mix ecto.setup to setup migration files and prepare the database.
Run: mix phx.server to start the pheonix server.
Run: mix y.seed to seed the initial data
Go to your web address to run.

Remember to have Elixir set up and running locally.

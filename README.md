## y — Anonymous Social Platform

y is a privacy-first, text-only social platform designed as a minimalist mockery of X (formerly Twitter). Built with the Phoenix framework and Elixir, it strips away corporate surveillance, media distractions, and identity requirements to focus purely on raw, uninhibited expression.

### Project Overview

The core philosophy of y is that privacy is not a feature, but the underlying architecture. The platform ensures that what is said remains more important than who says it.

### Key Features

- Zero Identity Storage: No emails, phone numbers, or real names are collected. Registration requires only a username and password.
- Text-Only "Takes": Posts are limited to 250 characters. There is no support for images, videos, or link previews to maintain a clean, distraction-free feed.
- "Agrees" instead of Likes: A simple, binary agreement system. It removes the performative "like" count and replaces it with a more direct signal of alignment.
- Anonymous Identity: Users are assigned random Bitmoji avatars. Identity is protected by design; there are no "real name" fields.
- "Retakes": Users can "retake" a post, adding their own commentary. This creates a threaded conversation structure that encourages debate and discussion.
- Seed Phrase Recovery: Account recovery is handled via a 12-word BIP39-style seed phrase, ensuring users remain in control of their accounts without PII (Personally Identifiable Information).
- Bespoke Aesthetic: A dedicated dark-mode-only interface using a deep navy/black palette (#0D0D1A) for a focused user experience.

### Technical Stack

1. Language: Elixir

2. Framework: Phoenix (LiveView for real-time updates)

3. Database: PostgreSQL

4. Cache/Real-time: Redis (used for sessions, rate limiting, and trending hashtags)

### Local Setup

#### Prerequisites

Before starting, ensure you have the following installed locally:

- Elixir & Erlang
- PostgreSQL (Running on the default port)
- Redis (Running on the default port)

#### Installation & Configuration

1. Database Configuration

Create a PostgreSQL database named y_dev. Ensure your local Postgres user has the following credentials:

- Username: user
- Password: password123

2. Fetch Dependencies

Run the following command in the root directory to install the required Phoenix and Elixir packages:

```bash
mix deps.get
```

3. Database Setup

Run the setup command to initialise your database schema and run migrations:

```bash
mix ecto.setup
```

4. Seed the Database

Populate the database with the initial required data (including the Bitmoji pool and default system settings):

```bash
mix y.seed
```

5. Start the Server

Launch the Phoenix server locally:

```bash
mix phx.server
```

Once the server has started, you can access the application by navigating to http://localhost:4000 in your web browser.

### Architecture Details

- Security: Passwords and seed phrases are hashed using Argon2id.

- Real-time Features: Leveraging Phoenix PubSub for instant notification delivery and feed updates.

- Performance: Redis is utilised for pre-computing feed chunks and managing the trending hashtag sorted sets.

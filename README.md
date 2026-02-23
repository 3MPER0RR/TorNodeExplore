**TorNodeExplore** is a Ruby script for analyzing and monitoring Tor network nodes using the Onionoo public API.
It allows you to filter Exit/Guard nodes, sort by bandwidth, filter by country, and obtain aggregate statistics.

## Features

- Retrieves all active relays in the Tor network
- Filter only **Exit nodes** (`--exit`)
- Filter only **Guard nodes** (`--guard`)
- Filter by **country** (`--country XX`)
- Show **top N relays by bandwidth** (`--top N`)
- Aggregated statistics (`--stats`)

## Requirements

- Ruby 2.x or higher (macOS 10.15 included)

## Usage

```bash
# All relays
ruby tor_nodes.rb

# Exit nodes only
ruby tor_nodes.rb --exit

# Guard nodes only
ruby tor_nodes.rb --guard

# Filter by country (e.g., Germany)
ruby tor_nodes.rb --country de

# Top 10 relays by bandwidth
ruby tor_nodes.rb --top 10

# Aggregate statistics
ruby tor_nodes.rb --stats

# Combined: Exit nodes USA, top 5, with stats
ruby tor_nodes.rb --exit --country us --top 5 --stats

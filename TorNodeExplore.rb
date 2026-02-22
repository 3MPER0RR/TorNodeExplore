#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'optparse'
require 'uri'

# --- Parametri CLI ---
options = {
  exit: false,
  guard: false,
  country: nil,
  top: nil,
  stats: false
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby tor_nodes.rb [options]"

  opts.on("--exit", "Mostra solo Exit nodes") { options[:exit] = true }
  opts.on("--guard", "Mostra solo Guard nodes") { options[:guard] = true }
  opts.on("--country CC", "Filtra per paese (2 lettere, es: US, DE)") { |c| options[:country] = c.downcase }
  opts.on("--top N", Integer, "Mostra top N relay per bandwidth") { |n| options[:top] = n }
  opts.on("--stats", "Mostra statistiche aggregate") { options[:stats] = true }
end.parse!

# --- Fetch dati Onionoo ---
uri = URI("https://onionoo.torproject.org/details?type=relay&running=true")
begin
  res = Net::HTTP.get(uri)
  data = JSON.parse(res)
rescue => e
  abort "Errore fetch Onionoo: #{e.message}"
end

relays = data["relays"] || []

# --- FILTRI ---
relays.select! { |r| r["flags"].include?("Exit") } if options[:exit]
relays.select! { |r| r["flags"].include?("Guard") } if options[:guard]
relays.select! { |r| r["country"]&.downcase == options[:country] } if options[:country]

# --- TOP BANDWIDTH ---
if options[:top] && options[:top] > 0
  relays.sort_by! { |r| -(r["advertised_bandwidth"] || 0) }
  relays = relays.first(options[:top]) if relays.size > options[:top]
end

# --- OUTPUT BASE ---
puts "%-20s %-18s %-6s %-12s %-8s" % ["Nickname", "IP", "CC", "Bandwidth", "Uptime"]
relays.each do |r|
  ip = r["or_addresses"]&.first&.split(":")&.first || "N/A"
  puts "%-20s %-18s %-6s %-12s %-8.2f" % [
    r["nickname"] || "N/A",
    ip,
    (r["country"] || "--").upcase,
    r["advertised_bandwidth"] || 0,
    r["uptime"] || 0
  ]
end

# --- STATISTICHE ---
if options[:stats]
  total = relays.size
  exit_count = relays.count { |r| r["flags"].include?("Exit") }
  guard_count = relays.count { |r| r["flags"].include?("Guard") }
  country_count = Hash.new(0)
  relays.each { |r| country_count[r["country"] || "??"] += 1 }

  puts "\n--- STATISTICHE ---"
  puts "Totale relay: #{total}"
  puts "Exit nodes: #{exit_count}"
  puts "Guard nodes: #{guard_count}"

  puts "\nRelay per paese:"
  country_count.sort_by { |_, v| -v }.each do |cc, c|
    puts "%-5s %d" % [cc.upcase, c]
  end
end
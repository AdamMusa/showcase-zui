# frozen_string_literal: true

module Showcase
  # Every entry is a complete, standalone Zui application checked into demos/.
  # The showcase launches them with `zui run demos/<slug>/main.rb`.
  # Plain hashes keep the catalog usable from both CRuby and the embedded mruby runtime.
  DEMOS = [
    {
      slug: "smart_home_energy",
      title: "Habitat One",
      tagline: "Smart home energy twin",
      blurb: "An image-backed living room that really reacts: toggle lights, drag the dimmer, " \
             "or pick Morning, Focus, Away and Night and brightness, saturation, wattage and " \
             "whole-home load all move together.",
      accent: MINT,
      hero: "assets/smart-living-room.png",
      glyph: :house,
      exercises: %w[image colorize gauge stacked_bar_chart toggle slider item_delegate]
    },
    {
      slug: "tesla_drive_dashboard",
      title: "Tesla Drive Lab",
      tagline: "Electric vehicle center display",
      blurb: "A three-column cockpit with a vehicle and speed cluster, climate and seat controls, " \
             "battery and route telemetry, a Ruby-drawn canvas map and local cockpit audio.",
      accent: CYAN,
      hero: "assets/electric-grand-tourer.png",
      glyph: :power,
      exercises: %w[canvas image audio radial_gauge slider toggle_switch animation]
    },
    {
      slug: "futuristic_dashboard",
      title: "Nebula Command",
      tagline: "Orbital operations dashboard",
      blurb: "Scheduled telemetry, GPU particles and effects, SVG assets, charts, gauges and an " \
             "image-backed result dialog — the flagship Zui desktop composition.",
      accent: VIOLET,
      hero: "preview.png",
      glyph: :globe,
      exercises: %w[particle_system line_chart gauge alert_dialog multi_effect item_delegate]
    },
    {
      slug: "cardiac_health_monitor",
      title: "Pulse Atlas",
      tagline: "Cardiac wellness visualization",
      blurb: "A full-panel heart render with live ECG-style charting, radial gauges, a recovery " \
             "heatmap, particles and breathing controls. A UI showcase, not medical advice.",
      accent: ROSE,
      hero: "assets/luminous-heart.png",
      glyph: :heart,
      exercises: %w[line_chart radial_gauge heatmap particle_system image dialog]
    },
    {
      slug: "orbital_weather_console",
      title: "Stratos",
      tagline: "Orbital weather command center",
      blurb: "Visible, infrared and moisture layers drive real GPU brightness, saturation and " \
             "colorization over a generated storm image, with a scan that pauses and resumes.",
      accent: CYAN,
      hero: "assets/orbital-storm.png",
      glyph: :wifi,
      exercises: %w[colorize multi_effect radar_chart area_chart heatmap particle_system]
    },
    {
      slug: "quantum_market_terminal",
      title: "Quantum Market",
      tagline: "Multi-asset paper trading",
      blurb: "Deterministic ticks move prices, candles, portfolio value and unrealized P&L. Buy " \
             "and sell orders execute against simulated cash, reject invalid input and track fills.",
      accent: GOLD,
      hero: nil,
      glyph: :star,
      exercises: %w[candlestick_chart table_view spin_box dialog transaction]
    },
    {
      slug: "cinematic_music_studio",
      title: "Nocturne",
      tagline: "Spatial music and mastering",
      blurb: "A native Qt Multimedia transport with real seeking, play and pause, cyclic track " \
             "changes, end-of-track advance and remote album artwork.",
      accent: VIOLET,
      hero: "assets/nocturne-cover.svg",
      glyph: :music,
      exercises: %w[media_player slider drag_area list_view image sparkline]
    },
    {
      slug: "nova_pour",
      title: "Nova Pour",
      tagline: "Restaurant drink ordering",
      blurb: "Nine photorealistic drink photos, category filtering, a reactive cart, confirmation " \
             "dialogs and live bar telemetry that advances every order from mixing to ready.",
      accent: AMBER,
      hero: "preview.png",
      glyph: :check,
      exercises: %w[grid_view image chip dialog list_view badge]
    },
    {
      slug: "lumen_forge",
      title: "Lumen Forge",
      tagline: "Live GPU shader laboratory",
      blurb: "Substantial Shadertoy works compiled for Qt 6's GPU pipeline — procedural ocean, " \
             "star nest, hex plasma, synthwave city — with reactive uniforms driven from Ruby.",
      accent: MINT,
      hero: nil,
      glyph: :code,
      exercises: %w[shader_effect slider line_chart timer uniform_animator]
    },
    {
      slug: "avatar_runner",
      title: "Avatar Runner",
      tagline: "Native endless runner",
      blurb: "A retained canvas scene with application-owned physics, collision detection, " \
             "scoring, keyboard focus, pointer input and atomic reactive patches.",
      accent: GOLD,
      hero: nil,
      glyph: :play,
      exercises: %w[canvas key_catcher tap_area timer transaction]
    },
    {
      slug: "mobile_kitchen_sink",
      title: "Mobile Kitchen Sink",
      tagline: "Mobile runtime acceptance app",
      blurb: "Permissions, camera preview and capture, motion sensors, touch, maps, charts, " \
             "speech, web, files and the virtual keyboard — every failure surfaced in Diagnostics.",
      accent: CYAN,
      hero: "assets/icon.png",
      glyph: :phone,
      exercises: %w[capture_session accelerometer map text_to_speech web_view virtual_keyboard]
    },
    {
      slug: "mobile_counter",
      title: "Mobile Counter",
      tagline: "Embedded mruby on iOS",
      blurb: "A touch-first sample for Zui's native mobile runtime: precompiled bytecode and the " \
             "in-process mruby VM inside the application bundle, with no child process.",
      accent: ROSE,
      hero: "assets/ruby.png",
      glyph: :plus,
      exercises: %w[safe_area button text transaction]
    }
  ].freeze

  DEMO_SLUGS = DEMOS.map { |demo| demo[:slug] }.freeze
end

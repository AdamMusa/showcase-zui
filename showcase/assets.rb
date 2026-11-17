# frozen_string_literal: true

module Showcase
  # Media demos reuse the artwork, audio and shaders that already ship with the
  # bundled demo applications. Paths resolve against the directory holding
  # main.rb, which is how the Zui renderer resolves every relative asset.
  ASSETS = {
    room: "demos/smart_home_energy/assets/smart-living-room.png",
    home: "demos/smart_home_energy/assets/home-twin.svg",
    heart: "demos/cardiac_health_monitor/assets/luminous-heart.png",
    storm: "demos/orbital_weather_console/assets/orbital-storm.png",
    core: "demos/futuristic_dashboard/assets/neural-core.svg",
    particle: "demos/futuristic_dashboard/assets/particle.svg",
    ruby: "demos/futuristic_dashboard/assets/ruby.png",
    cover: "demos/cinematic_music_studio/assets/nocturne-cover.svg",
    car: "demos/tesla_drive_dashboard/assets/electric-grand-tourer.png",
    car_front: "demos/tesla_drive_dashboard/assets/vehicle-front.png",
    car_side: "demos/tesla_drive_dashboard/assets/vehicle-side.png",
    cockpit_audio: "demos/tesla_drive_dashboard/assets/cockpit-loop.ogg",
    track_audio: "demos/cinematic_music_studio/assets/midnight-drift.ogg",
    shader: "demos/lumen_forge/assets/shaders/hex-plasma.frag.qsb",
    animated: "demos/nova_pour/assets/future-pour-bar.webp",
    lottie: "assets/showcase-spin.json",
    pdf: "assets/showcase-note.pdf"
  }.freeze

  DRINK_IMAGES = %w[
    coca-cola diet-coke ginger-ale house-lemonade iced-tea orange-juice sparkling-water sprite
  ].map { |name| ["demos/nova_pour/assets/#{name}.png", name.tr("-", " ")] }.freeze

  def self.asset(key) = ASSETS.fetch(key)
end

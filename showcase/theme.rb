# frozen_string_literal: true

module Showcase
  # Absolute path of the repository root, used to launch the bundled demo apps.
  # Relative asset paths stay relative: the renderer resolves those against the
  # directory that holds main.rb.
  REPO_ROOT = begin
    File.expand_path("..", File.dirname(__FILE__))
  rescue StandardError
    "."
  end

  # Surfaces
  INK          = "#06090f"
  PANEL        = "#0d1420"
  PANEL_ALT    = "#121c2c"
  PANEL_DEEP   = "#0a111b"
  TINT         = "#152a42"
  BORDER       = "#1f3047"
  BORDER_SOFT  = "#17243a"

  # Type
  WHITE        = "#eaf2ff"
  MUTED        = "#8699b4"
  FAINT        = "#5b6c86"

  # Accents
  CYAN         = "#58d7ff"
  MINT         = "#5df2b4"
  VIOLET       = "#a98cff"
  GOLD         = "#ffcd6b"
  ROSE         = "#ff7d97"
  AMBER        = "#ffa95c"

  ACCENTS = [CYAN, MINT, VIOLET, GOLD, ROSE, AMBER].freeze

  # Window metrics. Zui applications size natively in device-independent pixels,
  # so the showcase lays out on an explicit grid instead of a fluid web box model.
  WINDOW_W    = 1440
  WINDOW_H    = 920
  SIDEBAR_W   = 272
  CONTENT_W   = WINDOW_W - SIDEBAR_W
  TOPBAR_H    = 88
  PAGE_H      = WINDOW_H - TOPBAR_H
  CARD_W      = 356
  CARD_BODY_W = CARD_W - 40
  WIDE_W      = CARD_W * 2 + 16
  FULL_W      = CARD_W * 3 + 32

  module Palette
    SWATCHES = [
      ["Ink", Showcase::INK, "application background"],
      ["Panel", Showcase::PANEL, "cards and rails"],
      ["Panel alt", Showcase::PANEL_ALT, "nested surfaces"],
      ["Border", Showcase::BORDER, "hairlines"],
      ["Cyan", Showcase::CYAN, "primary accent"],
      ["Mint", Showcase::MINT, "success / live"],
      ["Violet", Showcase::VIOLET, "structure"],
      ["Gold", Showcase::GOLD, "attention"],
      ["Rose", Showcase::ROSE, "destructive"],
      ["Amber", Showcase::AMBER, "warning"]
    ].freeze
  end
end

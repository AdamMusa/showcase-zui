# frozen_string_literal: true

module Showcase
  # Absolute path of the repository root, used to launch the bundled demo apps.
  # Relative asset paths stay relative: the renderer resolves those against the
  # directory that holds main.rb.
  # The native client rejects any property value holding more than 256 entries
# (Service.qml, boundedValue), and it rejects the whole patch, not just the
# value — a page that sends a longer list simply never appears. Collections
# stay under this ceiling, with room to spare.
MAX_COLLECTION_ITEMS = 240
CATALOG_PAGE_SIZE = 200

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
  # A window taller than the screen is silently clipped by the window manager,
  # and the application has no way to find that out: an `app` surface is not an
  # `application_window`, so nothing delivers its resize event to Ruby. The
  # default therefore has to fit a laptop screen rather than assume one.
  WINDOW_H    = 780
  # The desktop shell insets the root control by the window's `padding` option.
  # The shell chrome here is edge to edge — a rail down the left, a bar across
  # the top — so the showcase takes the whole window and does its own insetting
  # inside each page.
  WINDOW_PAD  = 0
  USABLE_W    = WINDOW_W - WINDOW_PAD * 2
  USABLE_H    = WINDOW_H - WINDOW_PAD * 2
  SIDEBAR_W   = 272
  CONTENT_W   = USABLE_W - SIDEBAR_W
  TOPBAR_H    = 88
  PAGE_H      = USABLE_H - TOPBAR_H
  SIDEBAR_FOOTER_H = 92
  # The rail holds sixteen fixed-height entries; whatever is left over scrolls.
  NAV_H       = USABLE_H - TOPBAR_H - SIDEBAR_FOOTER_H - 2
  # Three cards and their two gutters fill the content column exactly.
  CARD_W      = (CONTENT_W - 36 - 32) / 3
  CARD_PAD    = 18
  CARD_BODY_W = CARD_W - CARD_PAD * 2
  # Cards sit in rows of three. A row of cards whose heights follow their own
  # content is a ragged edge, not a grid: the shortest card in the row opens a
  # void underneath it the height of the tallest one. Every card in a grid row
  # is therefore given the same height, holds its content at the top, and
  # scrolls its own body when it has more to show than the row allows.
  CARD_HEAD_H = 44
  CARD_H      = 420
  CARD_H_S    = 300
  CARD_H_L    = 520
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

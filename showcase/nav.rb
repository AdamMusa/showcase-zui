# frozen_string_literal: true

module Showcase
  # The showcase is one native window with a persistent rail and a stack_layout
  # of pages. Order here is the order in the rail and in the stack.
  PAGES = [
    { key: :overview, label: "Overview", glyph: :house, accent: CYAN,
      title: "Zui Showcase",
      subtitle: "Every built-in component, live, in pure Ruby" },
    { key: :foundation, label: "Foundation", glyph: :menu, accent: VIOLET,
      title: "Foundation & layout",
      subtitle: "Containers, layouts, split views, loaders and flickables" },
    { key: :content, label: "Content", glyph: :image, accent: CYAN,
      title: "Display & content",
      subtitle: "Text, rich text, markdown, icons, imagery, avatars and badges" },
    { key: :buttons, label: "Buttons", glyph: :check, accent: MINT,
      title: "Buttons & actions",
      subtitle: "Every push, tool, round, delay and icon button plus actions" },
    { key: :inputs, label: "Inputs", glyph: :edit, accent: GOLD,
      title: "Inputs & pickers",
      subtitle: "Fields, sliders, dials, spin boxes and native pickers" },
    { key: :navigation, label: "Navigation", glyph: :link, accent: VIOLET,
      title: "Navigation & structure",
      subtitle: "Tabs, rails, drawers, stacks, breadcrumbs and pagination" },
    { key: :feedback, label: "Feedback", glyph: :bell, accent: ROSE,
      title: "Menus, dialogs & feedback",
      subtitle: "Popups, dialogs, sheets, toasts, banners and progress" },
    { key: :data, label: "Data", glyph: :folder, accent: CYAN,
      title: "Data & collections",
      subtitle: "Lists, grids, tables, trees, delegates and calendars" },
    { key: :charts, label: "Charts", glyph: :star, accent: MINT,
      title: "Charts & visualization",
      subtitle: "Sixteen native chart and gauge components, reactively bound" },
    { key: :drawing, label: "Drawing", glyph: :code, accent: AMBER,
      title: "Drawing & interaction",
      subtitle: "Canvas, shapes, shaders, particles and pointer handlers" },
    { key: :motion, label: "Motion", glyph: :play, accent: VIOLET,
      title: "Motion in Ruby",
      subtitle: "Animations, animators, groups, springs, states and timers" },
    { key: :effects, label: "Effects", glyph: :star, accent: CYAN,
      title: "GPU effects",
      subtitle: "Blur, colorize, glow, shadows and masks over real pixels" },
    { key: :media, label: "Media", glyph: :music, accent: ROSE,
      title: "Multimedia & capture",
      subtitle: "Players, video output, capture sessions and audio devices" },
    { key: :system, label: "System", glyph: :gear, accent: GOLD,
      title: "Models, system & devices",
      subtitle: "Models, settings, clipboard, sensors, maps, speech and web" },
    { key: :apps, label: "Demo apps", glyph: :power, accent: MINT,
      title: "Demo applications",
      subtitle: "Twelve complete Zui apps, bundled and launchable from here" },
    { key: :catalog, label: "Catalog", glyph: :search, accent: CYAN,
      title: "Component catalog",
      subtitle: "The live registry: every component, property and event" },
    { key: :about, label: "About", glyph: :info, accent: MUTED,
      title: "About this showcase",
      subtitle: "How it is built, how to run it and how to extend it" }
  ].freeze

  PAGE_KEYS = PAGES.map { |page| page[:key] }.freeze

  def self.page_index(key) = PAGE_KEYS.index(key).to_i
end

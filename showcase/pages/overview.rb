# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_overview
      sc_page do
        sc_overview_hero
        sc_row do
          sc_overview_story
          sc_overview_pulse
          sc_overview_jump
        end
        sc_row do
          sc_overview_code
          sc_overview_platforms
          sc_overview_coverage
        end
      end
    end

    def sc_overview_hero
      card width: FULL_W, padding: 26, spacing: 18, color: PANEL, border_color: BORDER,
           accent: CYAN do
        gradient colors: [CYAN, VIOLET, MINT], type: :linear, width: FULL_W - 52, height: 3,
                 start_x: 0, start_y: 0, end_x: FULL_W - 52, end_y: 0
        row spacing: 10 do
          badge "ZUI #{Zui::VERSION}", background: TINT, foreground: CYAN, font_size: 10,
                padding: 8, size: 24
          badge "PURE RUBY", background: "#14362b", foreground: MINT, font_size: 10,
                padding: 8, size: 24
          badge "NATIVE QT", background: "#2a1f45", foreground: VIOLET, font_size: 10,
                padding: 8, size: 24
        end
        text "Every component Zui ships, running natively.", size: 34, bold: true, color: WHITE,
             width: 780, wrap: true
        sc_caption("This window is one Zui application written entirely in Ruby. There is no " \
                   "HTML, no CSS, no JavaScript and no application-owned QML — the rail, the " \
                   "cards, the charts and the twelve bundled demo apps are all the framework's " \
                   "own components under reactive Ruby state.", width: 840, size: 13)
        row spacing: 26 do
          sc_stat("COMPONENTS", REGISTRY_COUNT, CYAN, width: 130, size: 27)
          sc_stat("CATEGORIES", CATEGORY_ORDER.size, VIOLET, width: 130, size: 27)
          sc_stat("PROPERTIES", TOTAL_PROPERTIES, MINT, width: 130, size: 27)
          sc_stat("EVENTS", TOTAL_EVENTS, GOLD, width: 130, size: 27)
          sc_stat("DEMO APPS", DEMOS.size, ROSE, width: 130, size: 27)
          column spacing: 8, width: 260 do
            catalog = button "Browse the catalog", icon: :search, width: 250, height: 42,
                             foreground: INK, background: CYAN, accent: CYAN, font_size: 13 do
              sc_goto(Showcase.page_index(:catalog))
            end
            bind(catalog, :tooltip) { "#{sc_catalog_rows.size} components match the filter" }
            button "Open the demo apps", icon: :power, width: 250, height: 42, bordered: true,
                   foreground: WHITE, background: PANEL_ALT, accent: MINT, font_size: 13 do
              sc_goto(Showcase.page_index(:apps))
            end
          end
        end
      end
    end

    def sc_overview_story
      sc_card("One language, no escape hatch", "Ruby owns the interface and the logic",
              glyph: :ruby, accent: ROSE,
              tags: %w[application_window container card text button]) do
        sc_caption("A Zui application declares components, state, bindings, events, commands " \
                   "and timers in Ruby. The native client owns the Qt event loop and applies " \
                   "bounded reactive patches, so the interface stays native while the source " \
                   "stays in one language.")
        sc_panel do
          sc_kv("Renderer", "Qt Quick / Controls", accent: CYAN, width: 288)
          sc_kv("Protocol", "versioned JSON patches", accent: MINT, width: 288)
          sc_kv("Desktop", "private child process", accent: VIOLET, width: 288)
          sc_kv("Mobile", "in-process mruby bridge", accent: GOLD, width: 288)
        end
      end
    end

    def sc_overview_pulse
      sc_card("Reactive by default", "One scheduled tick, three bound components",
              glyph: :wifi, accent: MINT, tags: %w[line_chart progress_ring timer]) do
        chart = line_chart [], width: CARD_BODY_W, height: 112, color: MINT,
                           fill_color: "#12352a", grid_color: BORDER_SOFT, line_width: 2,
                           minimum: 0, maximum: 100, show_grid: true, show_points: false
        bind(chart, :values) { state.pulse }
        row spacing: 14 do
          ring = progress_ring 0, size: 76, thickness: 8, track_color: PANEL_ALT, color: CYAN,
                               foreground: WHITE, show_label: true, label_format: "{percent}%",
                               animated: true, font_size: 13
          bind(ring, :value) { state.pulse.last.to_f }
          column spacing: 6, width: 212 do
            throughput = sc_stat("THROUGHPUT", "0", MINT, width: 212)
            bind(throughput, :text) { "#{state.pulse.last.to_i} req/s" }
            ticks = sc_stat("TICKS", "0", MUTED, width: 212)
            bind(ticks, :text) { state.tick.to_i.to_s }
            toggle_node = toggle "Live telemetry", description: "Pause the scheduler",
                                 checked: true, accent: MINT, foreground: WHITE,
                                 title_size: 12, description_size: 10 do |event|
              state.live = event["value"] != false
              sc_log(state.live ? "Telemetry resumed" : "Telemetry paused")
            end
            bind(toggle_node, :checked) { state.live == true }
          end
        end
      end
    end

    def sc_overview_jump
      sc_card("Jump anywhere", "#{PAGES.size} pages, one stack_layout", glyph: :link, accent: VIOLET,
              tags: %w[item_delegate stack_layout navigation_rail]) do
        column spacing: 4, width: CARD_BODY_W do
          PAGES.each_with_index do |page, index|
            next if page[:key] == :overview

            entry = item_delegate page[:label], value: index, icon: page[:glyph],
                                  description: page[:subtitle], width: CARD_BODY_W, height: 44,
                                  radius: 10, padding: 10, spacing: 10, icon_size: 15,
                                  font_size: 12, description_size: 9, show_indicator: true,
                                  background: PANEL_ALT, selected_background: TINT,
                                  foreground: WHITE, selected_foreground: WHITE, muted: FAINT,
                                  accent: page[:accent], border_color: BORDER_SOFT,
                                  border_width: 1 do
              sc_goto(index)
            end
            bind(entry, :icon_color) { state.page.to_i == index ? page[:accent] : FAINT }
          end
        end
      end
    end

    def sc_overview_code
      sc_card("The whole program shape", "Declare state, declare a window, bind",
              glyph: :code, accent: GOLD, tags: %w[selectable_text markdown]) do
        sc_code(<<~RUBY)
          Zui::Application.new(ui: UI) do
            state :pulse, [12, 24, 38]

            app :main, title: "Showcase",
                       width: 1440, height: 920 do
              chart = line_chart state.pulse,
                                 color: "#5df2b4"
              bind(chart, :values) { state.pulse }
            end

            every(1.0) do
              state.pulse = state.pulse.drop(1) +
                            [rand(20..90)]
            end
          end
        RUBY
      end
    end

    def sc_overview_platforms
      sc_card("Runs where you ship", "One source tree, five platforms", glyph: :apple,
              accent: CYAN, tags: %w[system_info network_status standard_paths]) do
        [["Linux", "Qt Quick on X11 and Wayland", MINT, :terminal],
         ["macOS", "signed .app and .dmg", CYAN, :apple],
         ["Windows", "self-contained run.cmd", VIOLET, :power],
         ["iOS", "embedded mruby, no child process", ROSE, :apple],
         ["Android", "Gradle and CMake templates", GOLD, :android]].each do |name, note, tone, glyph|
          row spacing: 10, width: CARD_BODY_W do
            sc_tile(glyph, accent: tone, size: 30, radius: 9, glyph_size: 13)
            column spacing: 1, width: CARD_BODY_W - 42 do
              sc_value(name, color: WHITE, size: 12)
              sc_caption(note, width: CARD_BODY_W - 42, size: 10)
            end
          end
        end
      end
    end

    def sc_overview_coverage
      sc_card("Catalog coverage", "What this showcase puts on screen", glyph: :check,
              accent: MINT, tags: %w[progress gauge legend]) do
        row spacing: 12 do
          live = sc_stat("LIVE ON SCREEN", "0", MINT, width: 150, size: 25)
          bind(live, :text) { state.live_count.to_i.to_s }
          sc_stat("REGISTERED", REGISTRY_COUNT, CYAN, width: 150, size: 25)
        end
        bar = progress 0, minimum: 0, maximum: REGISTRY_COUNT, width: CARD_BODY_W, height: 8,
                       color: MINT
        bind(bar, :value) { state.live_count.to_i }
        sc_caption("Counted from the real node tree when the window is built: every component " \
                   "the showcase renders is marked \"yes\" in the catalog table. The rest are " \
                   "listed with their full property and event contracts.")
        legend [{ "label" => "Rendered live", "color" => MINT },
                { "label" => "Catalogued", "color" => FAINT }],
               orientation: :horizontal, spacing: 14, marker_size: 9, width: CARD_BODY_W,
               background: PANEL, foreground: WHITE, muted: FAINT, font_size: 10
      end
    end
  end
end

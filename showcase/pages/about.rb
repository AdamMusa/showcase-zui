# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_about
      sc_page do
        sc_about_hero
        sc_row do
          sc_about_running
          sc_about_structure
          sc_about_palette
        end
        sc_row do
          sc_about_architecture
          sc_about_coverage
          sc_about_credits
        end
      end
    end

    def sc_about_hero
      card width: FULL_W, padding: 24, spacing: 16, color: PANEL, border_color: BORDER,
           accent: CYAN do
        row spacing: 20 do
          column spacing: 10, width: 700 do
            text "About this showcase", size: 26, bold: true, color: WHITE, wrap: false
            sc_caption("showcase-zui is a single Zui application whose only job is to show " \
                       "what the framework ships. Every page is built from the same public " \
                       "Ruby DSL an application developer uses, and the component catalog is " \
                       "read from the framework's own registry at startup — so it cannot " \
                       "drift from the version it runs against.", width: 700, size: 13)
          end
          column spacing: 10, width: 340 do
            sc_kv("Framework", "Zui #{Zui::VERSION}", accent: CYAN, key_width: 120, width: 340)
            sc_kv("Registered components", REGISTRY_COUNT.to_s, accent: MINT, key_width: 120,
                  width: 340)
            sc_kv("Categories", CATEGORY_ORDER.size.to_s, accent: VIOLET, key_width: 120,
                  width: 340)
            sc_kv("Pages", PAGES.size.to_s, accent: GOLD, key_width: 120, width: 340)
            sc_kv("Bundled demo apps", DEMOS.size.to_s, accent: ROSE, key_width: 120,
                  width: 340)
          end
        end
      end
    end

    def sc_about_running
      sc_card("Running it", "Three commands from a clean checkout", glyph: :terminal,
              accent: MINT, tags: %w[selectable_text]) do
        sc_eyebrow("INSTALL THE RUNTIME ONCE")
        sc_code("gem install zui\nzui doctor --fix")
        sc_eyebrow("RUN THE SHOWCASE")
        sc_code("zui run main.rb")
        sc_eyebrow("RUN A BUNDLED DEMO")
        sc_code("zui run demos/smart_home_energy/main.rb")
        sc_eyebrow("PACKAGE IT")
        sc_code("zui bundle            # standalone, mruby\nzui bundle --full     # private CRuby\nzui bundle --dist     # native installer")
        sc_caption("The showcase prefers a local Zui checkout beside this repository so it " \
                   "always renders the newest catalog; set ZUI_PATH to point somewhere else.",
                   size: 10)
      end
    end

    def sc_about_structure
      sc_card("How it is laid out", "One page per category, one method per card",
              glyph: :folder, accent: VIOLET, tags: %w[markdown]) do
        [["main.rb", "Entry point: requires app.rb and runs it", CYAN],
         ["app.rb", "State declarations and the application window", MINT],
         ["showcase/theme.rb", "Colour and metric tokens", VIOLET],
         ["showcase/nav.rb", "The page list that drives the rail and the stack", GOLD],
         ["showcase/support.rb", "Card, panel and typography helpers", MUTED],
         ["showcase/chrome.rb", "Sidebar, top bar and the page stack", CYAN],
         ["showcase/catalog.rb", "Registry-driven catalog and schema inspector", MINT],
         ["showcase/pages/*.rb", "One file per category page", VIOLET],
         ["demos/*", "Twelve standalone Zui applications", ROSE]].each do |path, note, tone|
          row spacing: 10, width: CARD_BODY_W do
            rectangle width: 8, height: 8, radius: 4, color: tone
            column spacing: 0, width: CARD_BODY_W - 20 do
              sc_value(path, color: WHITE, size: 11)
              sc_caption(note, width: CARD_BODY_W - 20, size: 10)
            end
          end
        end
      end
    end

    def sc_about_palette
      sc_card("Palette", "Ten tokens, no gradients at rest", glyph: :image, accent: GOLD,
              tags: %w[rectangle divider]) do
        Palette::SWATCHES.each { |name, value, note| sc_swatch(name, value, note) }
      end
    end

    def sc_about_architecture
      sc_card("What runs where", "Ruby owns the app, Qt owns the pixels", glyph: :gear,
              accent: CYAN, tags: %w[text divider]) do
        [["Ruby application", "components · state · bindings · events · timers", MINT],
         ["Versioned JSON protocol", "render trees and bounded patch batches", CYAN],
         ["Native client", "transport · schema validation · error boundary", VIOLET],
         ["Platform renderer", "ControlNode · theme · the component catalog", GOLD],
         ["Qt", "Quick · Controls · Multimedia · Shapes · GPU effects", ROSE]].each_with_index do |(title, note, tone), index|
          row spacing: 10, width: CARD_BODY_W do
            rectangle width: 26, height: 26, radius: 8, color: PANEL_ALT, border_color: tone,
                      border_width: 1 do
              text((index + 1).to_s, size: 11, bold: true, color: tone, wrap: false)
            end
            column spacing: 0, width: CARD_BODY_W - 38 do
              sc_value(title, color: WHITE, size: 12)
              sc_caption(note, width: CARD_BODY_W - 38, size: 10)
            end
          end
        end
        sc_rule
        sc_caption("On desktop the protocol crosses a private process boundary. On iOS and " \
                   "Android the same protocol is carried in-process by an mruby bridge, which " \
                   "is why the mobile demos share this code unchanged.")
      end
    end

    def sc_about_coverage
      sc_card("Honesty about coverage", "What is live and what is catalogued", glyph: :check,
              accent: MINT, tags: %w[progress legend table_view]) do
        live = sc_stat("RENDERED LIVE", "0", MINT, width: CARD_BODY_W, size: 26)
        bind(live, :text) do
          "#{state.live_count.to_i} of #{REGISTRY_COUNT}"
        end
        bar = progress 0, minimum: 0, maximum: REGISTRY_COUNT, width: CARD_BODY_W, height: 8,
                       color: MINT
        bind(bar, :value) { state.live_count.to_i }
        sc_caption("That number is counted from the real node tree after the window is built, " \
                   "not from a hand-maintained list. The components it does not include are " \
                   "the ones that need an asset this repository does not ship, an optional Qt " \
                   "module, or a surface above the page — every one of them is named on its " \
                   "category page and listed with its full contract in the catalog.")
        row spacing: 8 do
          button "Open the catalog", icon: :search, width: 170, height: 38, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: CYAN, font_size: 11 do
            sc_goto(Showcase.page_index(:catalog))
          end
          button "Demo apps", icon: :power, width: 140, height: 38, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: MINT, font_size: 11 do
            sc_goto(Showcase.page_index(:apps))
          end
        end
      end
    end

    def sc_about_credits
      sc_card("Licence and credits", "MIT, with assets from the demos", glyph: :info,
              accent: MUTED, tags: %w[rich_text label]) do
        sc_kv("Showcase licence", "MIT", accent: WHITE, key_width: 130)
        sc_kv("Framework", "Zui, MIT", accent: WHITE, key_width: 130)
        sc_rule
        sc_caption("The imagery, audio and shaders on the Content, Media, Motion and Drawing " \
                   "pages are the assets that ship with the bundled demo applications. Each " \
                   "demo keeps its own README and provenance notes; nothing was copied in " \
                   "from elsewhere for this showcase.")
        sc_eyebrow("DEMOS WITH PROVENANCE NOTES")
        sc_tags(%w[nova_pour tesla_drive_dashboard cinematic_music_studio], width: CARD_BODY_W)
        sc_rule
        sc_caption("Nova Pour and Lumen Forge are the refined versions of the restaurant " \
                   "drinks and shader studio examples; the originals are byte-identical, so " \
                   "only the refined ones are bundled here.", size: 10)
      end
    end
  end
end

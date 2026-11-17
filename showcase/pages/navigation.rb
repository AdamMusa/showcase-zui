# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_navigation
      sc_page do
        sc_row do
          sc_nav_tabs
          sc_nav_rail_card
          sc_nav_trail
        end
        sc_row do
          sc_nav_disclosure
          sc_nav_views
          sc_nav_containers
        end
        sc_nav_drawer_card
      end
    end

    def sc_nav_tabs
      sc_card("Tabs", "A tab bar with real pages", glyph: :menu, accent: CYAN,
              tags: %w[tabs tab_bar tab_button page_indicator]) do
        sc_eyebrow("TABS · labels + child pages")
        tabbed = tabs %w[Signals Fleet Archive], current_index: 0, position: :top,
                      tab_height: 38, width: CARD_BODY_W, height: 150, background: PANEL_ALT,
                      content_background: PANEL_DEEP, foreground: WHITE, muted: FAINT,
                      accent: CYAN, border_color: BORDER_SOFT, radius: 12, font_size: 12 do
          [["Signals", "18 relays synchronised", MINT],
           ["Fleet", "7 vehicles charging", CYAN],
           ["Archive", "412 records retained", VIOLET]].each do |title, detail, tone|
            rectangle width: CARD_BODY_W - 4, height: 104, radius: 10, color: PANEL_DEEP,
                      padding: 14 do
              column spacing: 4 do
                text title, size: 15, bold: true, color: tone, wrap: false
                text detail, size: 11, color: MUTED, wrap: false
              end
            end
          end
        end
        bind(tabbed, :current_index) { state.tab_index.to_i }
        on(tabbed, :change) { |event| state.tab_index = event["value"].to_i }
        sc_eyebrow("TAB_BAR · standalone")
        strip = tab_bar %w[Day Week Month Year], current_index: 1, tab_width: 78, height: 38,
                        background: PANEL_ALT, foreground: MUTED, muted: FAINT, accent: GOLD,
                        border_color: BORDER_SOFT, radius: 10, font_size: 11
        bind(strip, :current_index) { state.range_index.to_i }
        on(strip, :change) do |event|
          transaction do
            state.range_index = event["value"].to_i
            state.activity = "Range #{%w[Day Week Month Year][event["value"].to_i]}"
          end
        end
        sc_eyebrow("TAB_BUTTON · composed by hand")
        row spacing: 6 do
          %w[Grid List].each_with_index do |name, index|
            tab = tab_button name, width: 84, height: 34, background: PANEL_ALT,
                              checked_background: TINT, foreground: MUTED,
                              checked_foreground: CYAN, accent: CYAN,
                              border_color: BORDER_SOFT, border_width: 1, radius: 9,
                              font_size: 11 do
              state.view_mode = name
            end
            bind(tab, :checked) { state.view_mode.to_s == name }
          end
        end
        sc_eyebrow("PAGE_INDICATOR")
        dots = page_indicator 4, current_index: 1, interactive: true, spacing: 8, dot_size: 8,
                              background: PANEL, foreground: FAINT, accent: CYAN,
                              width: CARD_BODY_W, height: 24
        bind(dots, :current_index) { state.range_index.to_i }
        on(dots, :change) { |event| state.range_index = event["value"].to_i }
      end
    end

    def sc_nav_rail_card
      sc_card("Navigation rail", "The same component the shell could use", glyph: :link,
              accent: VIOLET, tags: %w[navigation_rail item_delegate]) do
        rail = navigation_rail [{ "label" => "Overview", "icon" => "house" },
                                { "label" => "Signals", "icon" => "wifi" },
                                { "label" => "Fleet", "icon" => "power" },
                                { "label" => "Archive", "icon" => "folder" },
                                { "label" => "Settings", "icon" => "gear" }],
                               current_index: 0, extended: true, item_height: 44, spacing: 4,
                               padding: 8, width: CARD_BODY_W, height: 252,
                               background: PANEL_ALT, foreground: MUTED, muted: FAINT,
                               accent: VIOLET, selected_background: TINT,
                               border_color: BORDER_SOFT, radius: 12, font_size: 12,
                               icon_size: 16
        bind(rail, :current_index) { state.rail_index.to_i }
        on(rail, :select) do |event|
          transaction do
            state.rail_index = event["value"].to_i
            state.activity = "Rail → #{event["label"]}"
          end
        end
        selected = sc_kv("Destination", "Overview", accent: VIOLET, key_width: 110)
        bind(selected, :text) do
          %w[Overview Signals Fleet Archive Settings][state.rail_index.to_i].to_s
        end
        toggle_extended = toggle "Extended labels", description: "Collapse to icons only",
                                 checked: true, accent: VIOLET, foreground: WHITE,
                                 title_size: 12, description_size: 10 do |event|
          state.rail_extended = event["value"] != false
        end
        bind(toggle_extended, :checked) { state.rail_extended == true }
        bind(rail, :extended) { state.rail_extended == true }
      end
    end

    def sc_nav_trail
      sc_card("Trails and paging", "Where you are and how many pages there are",
              glyph: :arrow_right, accent: MINT, tags: %w[breadcrumb pagination tool_bar]) do
        sc_eyebrow("BREADCRUMB")
        trail = breadcrumb [{ "label" => "Home", "icon" => "house" },
                            { "label" => "Catalog" },
                            { "label" => "Charts" },
                            { "label" => "candlestick_chart" }],
                           current_index: 3, separator: "/", spacing: 6, padding: 8,
                           item_height: 30, width: CARD_BODY_W, height: 44,
                           background: PANEL_ALT, foreground: MUTED, muted: FAINT,
                           accent: MINT, border_color: BORDER_SOFT, radius: 10, font_size: 11,
                           icon_size: 13
        on(trail, :select) { |event| sc_log("Breadcrumb → #{event["label"] || event["value"]}") }
        sc_eyebrow("PAGINATION")
        pager = pagination 12, page: 1, sibling_count: 1, show_first_last: true,
                           show_previous_next: true, spacing: 4, padding: 6, item_size: 30,
                           width: CARD_BODY_W, height: 44, background: PANEL_ALT,
                           foreground: MUTED, muted: FAINT, accent: MINT,
                           selected_background: TINT, border_color: BORDER_SOFT, radius: 10,
                           font_size: 11
        bind(pager, :page) { state.page_number.to_i }
        on(pager, :change) do |event|
          transaction do
            state.page_number = event["value"].to_i
            state.activity = "Page #{event["value"]} of 12"
          end
        end
        current = sc_kv("Page", "1 / 12", accent: MINT, key_width: 110)
        bind(current, :text) { "#{state.page_number.to_i} / 12" }
        sc_eyebrow("TOOL_BAR · TOOL_SEPARATOR")
        tool_bar position: :header, padding: 8, spacing: 8, width: CARD_BODY_W, height: 48,
                 background: PANEL_DEEP, foreground: WHITE, border_color: BORDER_SOFT,
                 radius: 10 do
          row spacing: 8 do
            %i[arrow_left arrow_right refresh].each do |glyph|
              tool_button "", icon: glyph, width: 36, height: 32, foreground: MUTED,
                          background: PANEL_DEEP, accent: MINT, icon_size: 14 do
                sc_log("tool_bar :#{glyph}")
              end
            end
            tool_separator orientation: :vertical, thickness: 1, length: 24, color: BORDER
            text "tool_bar", size: 11, color: FAINT, wrap: false
          end
        end
      end
    end

    def sc_nav_disclosure
      sc_card("Disclosure", "Expansion panels and accordions", glyph: :chevron_down,
              accent: GOLD, tags: %w[expansion_panel accordion]) do
        sc_eyebrow("EXPANSION_PANEL")
        panel = expansion_panel "Reactive patches", subtitle: "How updates reach the renderer",
                                expanded: true, animated: true, duration: 220,
                                header_height: 52, padding: 14, spacing: 10,
                                width: CARD_BODY_W, background: PANEL_ALT,
                                header_background: PANEL_DEEP, expanded_background: PANEL_ALT,
                                foreground: WHITE, muted: FAINT, accent: GOLD,
                                border_color: BORDER_SOFT, radius: 12, title_size: 13,
                                subtitle_size: 10 do
          sc_caption("Only the properties whose evaluated value changed are sent, and a " \
                     "transaction block publishes them as one atomic batch.",
                     width: CARD_BODY_W - 28, size: 11)
        end
        bind(panel, :expanded) { state.panel_open == true }
        on(panel, :toggle) { |event| state.panel_open = event["value"] != false }
        sc_eyebrow("ACCORDION · single open section")
        accordion ["Desktop", "Mobile", "Distribution"],
                  subtitles: ["Private child process", "In-process mruby", "Tree-shaken bundles"],
                  expanded_indices: [0], multiple: false, animated: true, duration: 200,
                  header_height: 46, padding: 12, spacing: 8, width: CARD_BODY_W,
                  background: PANEL_ALT, header_background: PANEL_DEEP,
                  expanded_background: PANEL_ALT, foreground: WHITE, muted: FAINT,
                  accent: CYAN, border_color: BORDER_SOFT, radius: 12, title_size: 12,
                  subtitle_size: 10 do
          [["The host owns the Qt event loop and talks to Ruby over a versioned JSON protocol.",
            MINT],
           ["The same protocol runs in-process through an mruby bridge on iOS and Android.",
            CYAN],
           ["`zui bundle` tree-shakes the component catalog down to what the app references.",
            VIOLET]].each do |copy, tone|
            sc_caption(copy, width: CARD_BODY_W - 24, size: 11, color: tone)
          end
        end
      end
    end

    def sc_nav_views
      sc_card("Stack and swipe views", "Push, pop and swipe between pages", glyph: :arrow_right,
              accent: CYAN, tags: %w[stack_view swipe_view page]) do
        sc_eyebrow("STACK_VIEW")
        stacked = stack_view width: CARD_BODY_W, height: 120, animated: true,
                             background: PANEL_ALT, border_color: BORDER_SOFT, radius: 12,
                             clip: true do
          [["Step 1", "Choose a component", CYAN],
           ["Step 2", "Read its contract", MINT],
           ["Step 3", "Bind it to state", VIOLET]].each do |title, detail, tone|
            page title: title, show_header: false, padding: 14, spacing: 6,
                 width: CARD_BODY_W, height: 120, background: PANEL_ALT, foreground: WHITE,
                 muted: FAINT, border_color: PANEL_ALT, radius: 12 do
              text title, size: 16, bold: true, color: tone, wrap: false
              text detail, size: 11, color: MUTED, wrap: false
            end
          end
        end
        bind(stacked, :current_index) { state.step_index.to_i }
        row spacing: 8 do
          button "Back", icon: :arrow_left, width: 110, height: 36, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: CYAN, font_size: 11 do
            state.step_index = [state.step_index.to_i - 1, 0].max
          end
          button "Next", icon: :arrow_right, width: 110, height: 36, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: CYAN, font_size: 11 do
            state.step_index = [state.step_index.to_i + 1, 2].min
          end
          progress_ring 0, size: 36, thickness: 5, track_color: PANEL_ALT, color: CYAN,
                        show_label: false
        end
        sc_eyebrow("SWIPE_VIEW · drag horizontally")
        swiped = swipe_view width: CARD_BODY_W, height: 96, orientation: :horizontal,
                            interactive: true, background: PANEL_ALT,
                            border_color: BORDER_SOFT, radius: 12, clip: true do
          ACCENTS.first(4).each_with_index do |tone, index|
            rectangle width: CARD_BODY_W, height: 96, radius: 12, color: PANEL_ALT do
              column spacing: 4 do
                text "Slide #{index + 1}", size: 15, bold: true, color: tone, wrap: false
                text "swipe_view page", size: 10, color: FAINT, wrap: false
              end
            end
          end
        end
        on(swiped, :change) { |event| sc_log("swipe_view → #{event["value"].to_i + 1}") }
      end
    end

    def sc_nav_containers
      sc_card("Structural containers", "Page, pane, frame and group box", glyph: :folder,
              accent: VIOLET, tags: %w[page pane frame group_box]) do
        page title: "Page component", header_text: "with a header and footer",
             footer_text: "footer_text", show_header: true, show_footer: true,
             header_height: 44, footer_height: 32, padding: 12, spacing: 8,
             width: CARD_BODY_W, height: 150, background: PANEL_ALT,
             header_background: PANEL_DEEP, footer_background: PANEL_DEEP, foreground: WHITE,
             muted: FAINT, border_color: BORDER_SOFT, radius: 12, title_size: 13,
             footer_size: 10 do
          sc_caption("A page owns its own header and footer bands, so a navigation stack can " \
                     "push and pop complete screens.", width: CARD_BODY_W - 28, size: 11)
        end
        group_box "GROUP_BOX", padding: 12, spacing: 8, width: CARD_BODY_W,
                  background: PANEL_ALT, foreground: WHITE, muted: FAINT,
                  border_color: BORDER_SOFT, border_width: 1, radius: 12, title_size: 11 do
          row spacing: 8 do
            checkbox "Telemetry", checked: true, accent: VIOLET, foreground: WHITE,
                     font_size: 11, indicator_size: 16
            checkbox "Crash reports", checked: false, accent: VIOLET, foreground: WHITE,
                     font_size: 11, indicator_size: 16
          end
        end
      end
    end

    def sc_nav_drawer_card
      card width: FULL_W, padding: 20, spacing: 14, color: PANEL, border_color: BORDER,
           accent: ROSE do
        sc_head(:menu, "Drawer", "A native edge drawer over the whole window.", accent: ROSE,
                width: FULL_W - 40)
        row spacing: 12 do
          button "Open the drawer", icon: :menu, width: 200, height: 42, foreground: INK,
                 background: ROSE, accent: ROSE, font_size: 12 do
            transaction do
              state.drawer_open = true
              state.activity = "Drawer opened"
            end
          end
          sc_caption("The drawer below is declared once at page level. Its `opened` property " \
                     "is bound to Ruby state, so any control anywhere can open it.",
                     width: 520, size: 11)
        end
        shelf = drawer opened: false, edge: :left, modal: true, dim: true, interactive: true,
                       drag_margin: 24, padding: 20, spacing: 14, width: 320,
                       height: WINDOW_H, background: PANEL, foreground: WHITE,
                       border_color: BORDER, radius: 0 do
          column spacing: 14, width: 280 do
            sc_head(:menu, "Drawer content", "Any component tree belongs here", accent: ROSE,
                    width: 280)
            %w[Profile Devices Automations Energy Diagnostics].each do |name|
              item_delegate name, icon: :chevron_right, width: 280, height: 42, radius: 10,
                            padding: 10, spacing: 10, icon_size: 14, font_size: 12,
                            background: PANEL_ALT, selected_background: TINT,
                            foreground: WHITE, selected_foreground: WHITE, muted: FAINT,
                            accent: ROSE, border_color: BORDER_SOFT, border_width: 1 do
                sc_log("Drawer item: #{name}")
              end
            end
            button "Close", icon: :xmark, width: 280, height: 40, bordered: true,
                   foreground: WHITE, background: PANEL_ALT, accent: ROSE, font_size: 12 do
              state.drawer_open = false
            end
          end
        end
        bind(shelf, :opened) { state.drawer_open == true }
        on(shelf, :close) { state.drawer_open = false }
      end
    end
  end
end

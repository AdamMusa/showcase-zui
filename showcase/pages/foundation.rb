# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_foundation
      sc_page do
        sc_row do
          sc_found_flow_boxes
          sc_found_layouts
          sc_found_flow
        end
        sc_row do
          sc_found_split
          sc_found_stacks
          sc_found_scroll
        end
        sc_row do
          sc_found_loader
          sc_found_flipable
          sc_found_surfaces
        end
        sc_found_surface_note
      end
    end

    def sc_swatch_block(label, color, width: 64, height: 46)
      rectangle width: width, height: height, radius: 10, color: color do
        text label, size: 10, bold: true, color: INK, wrap: false
      end
    end

    def sc_found_flow_boxes
      sc_card("Rows, columns, grids", "The three primitives everything else sits on",
              glyph: :menu, accent: VIOLET,
              tags: %w[row column grid spacer center container]) do
        sc_eyebrow("ROW · spacing 8")
        row spacing: 8 do
          sc_swatch_block("1", CYAN)
          sc_swatch_block("2", MINT)
          sc_swatch_block("3", VIOLET)
          sc_swatch_block("4", GOLD)
        end
        sc_eyebrow("GRID · 3 columns")
        grid columns: 3, row_spacing: 8, column_spacing: 8 do
          6.times do |index|
            sc_swatch_block((index + 1).to_s, ACCENTS[index % ACCENTS.size], width: 96, height: 38)
          end
        end
        sc_eyebrow("CENTER · padding 12")
        rectangle width: CARD_BODY_W, height: 62, radius: 12, color: PANEL_ALT do
          center padding: 12 do
            text "centered content", size: 12, color: MUTED, wrap: false
          end
        end
      end
    end

    def sc_found_layouts
      sc_card("Qt layout items", "Real QtQuick.Layouts with fill and preferred sizing",
              glyph: :gear, accent: CYAN,
              tags: %w[row_layout column_layout grid_layout layout_item_proxy]) do
        sc_eyebrow("ROW_LAYOUT · fill_width")
        row_layout spacing: 8, width: CARD_BODY_W do
          rectangle height: 40, radius: 10, color: TINT, fill_width: true do
            text "fill_width", size: 11, color: CYAN, wrap: false
          end
          rectangle width: 72, height: 40, radius: 10, color: PANEL_ALT do
            text "fixed", size: 11, color: MUTED, wrap: false
          end
        end
        sc_eyebrow("GRID_LAYOUT · 2 columns")
        grid_layout columns: 2, row_spacing: 8, column_spacing: 8, width: CARD_BODY_W do
          [["Alpha", CYAN], ["Beta", MINT], ["Gamma", VIOLET], ["Delta", GOLD]].each do |name, tone|
            rectangle height: 38, radius: 10, color: PANEL_ALT, border_color: tone,
                       border_width: 1, fill_width: true do
              text name, size: 11, color: tone, wrap: false
            end
          end
        end
        sc_eyebrow("LAYOUT_ITEM_PROXY · remote sizing")
        proxied = rectangle width: CARD_BODY_W, height: 34, radius: 10, color: TINT do
          text "this item is placed by a proxy", size: 11, color: CYAN, wrap: false
        end
        column_layout spacing: 8, width: CARD_BODY_W do
          layout_item_proxy proxied, preferred_width: CARD_BODY_W, preferred_height: 34,
                            fill_width: true
        end
      end
    end

    def sc_found_flow
      sc_card("Flow, wrap and clipping", "Content that reflows instead of overflowing",
              glyph: :arrow_right, accent: MINT,
              tags: %w[flow wrap aspect_ratio constrained_box fitted_box]) do
        sc_eyebrow("WRAP · flowing chips")
        wrap width: CARD_BODY_W, spacing: 6 do
          %w[container card scroll grid flow wrap center stack loader].each_with_index do |name, index|
            chip name, height: 26, font_size: 10, radius: 8, horizontal_padding: 9,
                 background: PANEL_ALT, selected_background: PANEL_ALT,
                 foreground: ACCENTS[index % ACCENTS.size],
                 selected_foreground: ACCENTS[index % ACCENTS.size],
                 accent: ACCENTS[index % ACCENTS.size]
          end
        end
        sc_eyebrow("FLOW · fixed width, computed height")
        flow width: CARD_BODY_W, spacing: 6, orientation: :horizontal do
          %w[28 26 37 20 20 23 16 21 32 7 12 10].each_with_index do |count, index|
            rectangle width: 46, height: 28, radius: 8, color: PANEL_ALT,
                      border_color: ACCENTS[index % ACCENTS.size], border_width: 1 do
              text count, size: 10, color: ACCENTS[index % ACCENTS.size], wrap: false
            end
          end
        end
        sc_eyebrow("ASPECT_RATIO · 16:9 · FITTED_BOX")
        row spacing: 10 do
          aspect_ratio ratio: 1.777, width: 152, clip: true do
            image Showcase.asset(:storm), width: 152, height: 86, fill_mode: :preserve_aspect_crop
          end
          fitted_box width: 152, height: 86, fit: :contain, clip: true do
            image Showcase.asset(:core), width: 120, height: 80,
                  fill_mode: :preserve_aspect_fit
          end
        end
        sc_eyebrow("CONSTRAINED_BOX · max 200 x 56")
        constrained_box max_width: 200, max_height: 56, clip: true do
          rectangle width: 320, height: 56, radius: 10, color: PANEL_ALT do
            text "320pt wide, clamped to 200", size: 10, color: MUTED, wrap: false
          end
        end
      end
    end

    def sc_found_split
      sc_card("Split view", "Draggable native panes", glyph: :menu, accent: GOLD,
              tags: %w[split_view pane frame]) do
        splitter = split_view orientation: :horizontal, width: CARD_BODY_W, height: 188 do
          pane padding: 12, background: PANEL_ALT, border_color: BORDER_SOFT, border_width: 1,
               radius: 12, width: 150 do
            column spacing: 6 do
              sc_eyebrow("PANE")
              text "Drag the handle", size: 11, color: WHITE, width: 120, wrap: true
            end
          end
          frame padding: 12, background: PANEL_DEEP, border_color: BORDER, border_width: 1,
                radius: 12, width: 150 do
            column spacing: 6 do
              sc_eyebrow("FRAME")
              sizes = text "resize to measure", size: 11, color: MINT, width: 120, wrap: true
              bind(sizes, :text) { state.split_sizes.to_s }
            end
          end
        end
        on(splitter, :resize) do |event|
          sizes = Array(event["sizes"]).map { |value| value.to_f.round }
          transaction do
            state.split_sizes = sizes.join(" · ")
            state.activity = "Split view resized to #{sizes.join("/")}"
          end
        end
      end
    end

    def sc_found_stacks
      sc_card("Stacks", "Overlap with stack, page with stack_layout", glyph: :folder,
              accent: VIOLET, tags: %w[stack stack_layout border_overlay]) do
        sc_eyebrow("STACK · z-ordered overlap")
        stack width: CARD_BODY_W, height: 96 do
          rectangle width: 240, height: 96, radius: 14, color: "#17284a"
          rectangle width: 180, height: 76, radius: 12, color: "#1f3c6b"
          rectangle width: 120, height: 56, radius: 10, color: CYAN do
            text "front", size: 11, bold: true, color: INK, wrap: false
          end
        end
        sc_eyebrow("STACK_LAYOUT · one child at a time")
        row spacing: 6 do
          %w[One Two Three].each_with_index do |name, index|
            tab = button name, width: 96, height: 32, font_size: 11, bordered: true,
                         foreground: WHITE, background: PANEL_ALT, accent: VIOLET do
              transaction do
                state.layout_index = index
                state.activity = "stack_layout → #{name}"
              end
            end
            bind(tab, :selected) { state.layout_index.to_i == index }
          end
        end
        layered = stack_layout width: CARD_BODY_W, height: 70 do
          [["One", CYAN], ["Two", MINT], ["Three", VIOLET]].each do |name, tone|
            rectangle width: CARD_BODY_W, height: 70, radius: 12, color: PANEL_ALT,
                      border_color: tone, border_width: 1 do
              text "panel #{name.downcase}", size: 13, bold: true, color: tone, wrap: false
            end
          end
        end
        bind(layered, :current_index) { state.layout_index.to_i }
      end
    end

    def sc_found_scroll
      sc_card("Scroll and flick", "ScrollView and Flickable, natively", glyph: :arrow_down,
              accent: CYAN, tags: %w[scroll flickable scroll_bar scroll_indicator]) do
        sc_eyebrow("SCROLL · 120pt viewport")
        scroll width: CARD_BODY_W, height: 120, clip: true do
          12.times do |index|
            rectangle width: CARD_BODY_W - 18, height: 30, radius: 8, color: PANEL_ALT do
              text "scrollable row #{index + 1}", size: 11, color: MUTED, wrap: false
            end
          end
        end
        sc_eyebrow("FLICKABLE · horizontal content")
        flick = flickable width: CARD_BODY_W, height: 76, content_width: 720, content_height: 76,
                          direction: :horizontal, bounds_behavior: :drag_and_overshoot,
                          interactive: true, clip: true do
          row spacing: 8 do
            9.times do |index|
              rectangle width: 72, height: 72, radius: 12, color: PANEL_ALT,
                        border_color: ACCENTS[index % ACCENTS.size], border_width: 1 do
                text((index + 1).to_s, size: 15, bold: true,
                     color: ACCENTS[index % ACCENTS.size], wrap: false)
              end
            end
          end
        end
        on(flick, :flick_end) { sc_log("Flickable settled") }
      end
    end

    def sc_found_loader
      sc_card("Loader, focus and control", "Deferred children and focus scopes", glyph: :power,
              accent: MINT, tags: %w[loader focus_scope control]) do
        sc_eyebrow("LOADER · active binding")
        loaded = loader width: CARD_BODY_W, height: 74, active: true do
          rectangle width: CARD_BODY_W, height: 74, radius: 12, color: PANEL_ALT,
                    border_color: MINT, border_width: 1 do
            column spacing: 2 do
              text "child instantiated", size: 12, bold: true, color: MINT, wrap: false
              text "loader.active = true", size: 10, color: MUTED, wrap: false
            end
          end
        end
        bind(loaded, :active) { state.loader_active == true }
        on(loaded, :loaded) { sc_log("Loader instantiated its child") }
        switcher = toggle_switch checked: true, accent: MINT, foreground: WHITE do |event|
          state.loader_active = event["value"] != false
          sc_log(state.loader_active ? "Loader activated" : "Loader deactivated")
        end
        bind(switcher, :checked) { state.loader_active == true }
        sc_eyebrow("FOCUS_SCOPE · CONTROL")
        focus_scope width: CARD_BODY_W, height: 60 do
          control width: CARD_BODY_W, height: 60, padding: 12, background: PANEL_ALT,
                  border_color: BORDER, border_width: 1, radius: 12, hover_enabled: true do
            text "a Control with padding, hover and focus", size: 11, color: MUTED,
                 width: CARD_BODY_W - 24, wrap: true
          end
        end
      end
    end

    def sc_found_flipable
      sc_card("Flipable", "Two faces, one native rotation", glyph: :refresh, accent: ROSE,
              tags: %w[flipable rectangle]) do
        flipper = flipable width: CARD_BODY_W, height: 150, axis: :y, duration: 420,
                           easing: :in_out_quad, interactive: false, flipped: false do
          rectangle width: CARD_BODY_W, height: 150, radius: 14, color: PANEL_ALT,
                    border_color: ROSE, border_width: 1 do
            column spacing: 6 do
              sc_eyebrow("FRONT", color: ROSE)
              text "flipable", size: 20, bold: true, color: WHITE, wrap: false
              text "declare both faces as children", size: 10, color: MUTED, wrap: false
            end
          end
          rectangle width: CARD_BODY_W, height: 150, radius: 14, color: "#2a1420",
                     border_color: GOLD, border_width: 1 do
            column spacing: 6 do
              sc_eyebrow("BACK", color: GOLD)
              text "axis: :y", size: 20, bold: true, color: GOLD, wrap: false
              text "duration: 420ms", size: 10, color: MUTED, wrap: false
            end
          end
        end
        bind(flipper, :flipped) { state.flipped == true }
        button "Flip the card", icon: :refresh, width: CARD_BODY_W, height: 40, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: ROSE, font_size: 12 do
          transaction do
            state.flipped = !state.flipped
            state.activity = state.flipped ? "Flipped to the back face" : "Flipped to the front"
          end
        end
      end
    end

    def sc_found_surfaces
      sc_card("Surfaces", "Cards, rectangles and border overlays", glyph: :image, accent: GOLD,
              tags: %w[card rectangle border_overlay border_image separator divider]) do
        row spacing: 10 do
          card width: 104, padding: 10, color: PANEL_ALT, border_color: CYAN, accent: CYAN do
            text "card", size: 11, bold: true, color: CYAN, wrap: false
          end
          rectangle width: 104, height: 54, radius: 16, color: PANEL_ALT, border_color: MINT,
                    border_width: 1 do
            text "radius 16", size: 10, color: MINT, wrap: false
          end
          rectangle width: 104, height: 54, radius: 10, color: PANEL_DEEP do
            border_overlay color: VIOLET, radius: 10, gradient_colors: [VIOLET, CYAN],
                           gradient_angle: 45
          end
        end
        sc_eyebrow("BORDER_IMAGE · nine-slice")
        border_image Showcase.asset(:core), width: CARD_BODY_W, height: 64, border_left: 24,
                     border_top: 24, border_right: 24, border_bottom: 24,
                     horizontal_tile: :stretch, vertical_tile: :stretch
        sc_eyebrow("SEPARATOR · DIVIDER")
        separator strength: 1
        divider orientation: :horizontal, length: CARD_BODY_W, thickness: 2, color: GOLD,
                opacity: 0.5
      end
    end

    def sc_found_surface_note
      card width: FULL_W, padding: 18, spacing: 12, color: PANEL, border_color: BORDER,
           accent: MUTED do
        sc_head(:info, "Surface-level components",
                "Four layout components exist above the page and cannot be nested inside it.",
                accent: MUTED, width: FULL_W - 36)
        wrap width: FULL_W - 36, spacing: 10 do
          [["application_window", "The window itself. `app :main` declares one per surface."],
           ["window", "Secondary native windows, declared as their own surface."],
           ["responsive_view", "Sizes to the whole window; the mobile demos use it as a root."],
           ["key_catcher", "Window-level key routing, used by the Avatar Runner demo."]].each do |name, note|
            rectangle width: 256, height: 92, radius: 12, padding: 14, color: PANEL_ALT,
                      border_color: BORDER_SOFT, border_width: 1 do
              column spacing: 4, width: 228 do
                text name, size: 12, bold: true, color: CYAN, wrap: false
                sc_caption(note, width: 228, size: 10)
              end
            end
          end
        end
      end
    end
  end
end

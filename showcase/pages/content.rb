# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_content
      sc_page do
        sc_row do
          sc_content_typography
          sc_content_markup
          sc_content_metrics
        end
        sc_content_icons
        sc_row do
          sc_content_imagery
          sc_content_identity
          sc_content_hero
        end
        sc_content_note
      end
    end

    def sc_content_typography
      sc_card("Text", "Sizes, weights, styles and wrapping", glyph: :edit, accent: CYAN,
              tags: %w[text label section_header]) do
        text "Display 28", size: 28, bold: true, color: WHITE, wrap: false
        text "Title 20", size: 20, bold: true, color: WHITE, wrap: false
        text "Body 13 — wraps inside an explicit width so native text metrics stay predictable.",
             size: 13, color: MUTED, width: CARD_BODY_W, wrap: true
        text "style: :caption", style: :caption, color: FAINT, wrap: false
        section_header "SECTION_HEADER"
        sc_eyebrow("LABEL · elide + maximum_lines")
        label "A label with elide: :right and maximum_lines: 1 truncates instead of wrapping " \
              "when the content is longer than its box.", size: 11, color: MUTED,
              width: CARD_BODY_W, wrap: false, elide: :right, maximum_lines: 1
        label "Right aligned label", size: 11, color: CYAN, width: CARD_BODY_W,
              horizontal_alignment: :right
      end
    end

    def sc_content_markup
      sc_card("Rich text and markdown", "Styled runs and links, rendered natively",
              glyph: :file, accent: VIOLET, tags: %w[rich_text markdown selectable_text]) do
        sc_eyebrow("RICH_TEXT · HTML subset")
        rich = rich_text "<b>Bold</b>, <i>italic</i>, <u>underline</u> and " \
                         "<a href=\"https://zui.alkimist.dev\">a link</a> in one run.",
                         size: 12, color: WHITE, link_color: CYAN, width: CARD_BODY_W, wrap: true
        on(rich, :link) { |event| sc_log("rich_text link: #{event["value"] || event["link"]}") }
        sc_eyebrow("MARKDOWN")
        md = markdown "### Markdown\n\n- lists\n- `inline code`\n- [links](https://zui.alkimist.dev)\n\n" \
                      "> rendered by the native text engine",
                      size: 12, color: MUTED, link_color: MINT, width: CARD_BODY_W, wrap: true
        on(md, :link) { |event| sc_log("markdown link: #{event["value"] || event["link"]}") }
        sc_eyebrow("SELECTABLE_TEXT · drag to select")
        selected = selectable_text "Select this sentence with the pointer or keyboard.",
                                   size: 12, color: WHITE, width: CARD_BODY_W, wrap: true,
                                   selection_color: TINT, selected_text_color: CYAN
        on(selected, :selection) { |event| sc_log("Selected #{event["value"].to_s[0, 32]}") }
      end
    end

    def sc_content_metrics
      sc_card("Measuring text", "text_metrics reports real font metrics", glyph: :search,
              accent: MINT, tags: %w[text_metrics tooltip optical_glyph]) do
        sample = "Measure me"
        text sample, size: 22, bold: true, color: WHITE, wrap: false
        metrics = text_metrics sample, font_size: 22, bold: true, elide: :right,
                               elide_width: 240
        readout = sc_kv("Reported width", "waiting…", accent: MINT, key_width: 120)
        on(metrics, :metrics) do |event|
          state.metrics = "#{event["width"].to_f.round(1)} x #{event["height"].to_f.round(1)} pt"
        end
        bind(readout, :text) { state.metrics.to_s }
        sc_rule
        sc_eyebrow("OPTICAL_GLYPH · optical sizing")
        row spacing: 10 do
          optical_glyph "Zui", size: 34, color: CYAN
          optical_glyph "306", size: 34, color: VIOLET
        end
        sc_eyebrow("TOOLTIP · hover the panel")
        rectangle width: CARD_BODY_W, height: 54, radius: 12, color: PANEL_ALT,
                  border_color: BORDER, border_width: 1 do
          column spacing: 2 do
            text "hover for a native tooltip", size: 11, color: MUTED, wrap: false
            tooltip "tooltip component, 400ms delay", delay: 400, timeout: 4000,
                    foreground: WHITE, background: PANEL_DEEP, border: CYAN, font_size: 11
          end
        end
      end
    end

    def sc_content_icons
      card width: FULL_W, padding: 18, spacing: 14, color: PANEL, border_color: BORDER,
           accent: GOLD do
        row spacing: 12 do
          sc_tile(:star, accent: GOLD)
          column spacing: 2, width: 420 do
            text "Icon set", size: 16, bold: true, color: WHITE, wrap: false
            sc_caption("Every one of the #{Zui::ICON_NAMES.size} named glyphs the framework " \
                       "ships, rendered by the icon component.", width: 420, size: 11)
          end
          spacer width: 360, height: 1
          chosen = sc_stat("LAST ICON", "star", GOLD, width: 150, size: 18)
          bind(chosen, :text) { state.icon_name.to_s }
        end
        wrap width: FULL_W - 36, spacing: 6 do
          Zui::ICON_NAMES.each_with_index do |name, index|
            tone = ACCENTS[index % ACCENTS.size]
            cell = rectangle width: 78, height: 62, radius: 10, color: PANEL_ALT,
                             border_color: BORDER_SOFT, border_width: 1 do
              column spacing: 3 do
                icon name, size: 17, color: tone
                text name.to_s, size: 8, color: FAINT, wrap: false
              end
            end
            on(cell, :click) do
              transaction do
                state.icon_name = name.to_s
                state.activity = "icon :#{name}"
              end
            end
            bind(cell, :border_color) { state.icon_name.to_s == name.to_s ? tone : BORDER_SOFT }
          end
        end
      end
    end

    def sc_content_imagery
      sc_card("Images", "Raster, vector and fill modes", glyph: :image, accent: CYAN,
              tags: %w[image vector_image animated_image aspect_ratio]) do
        aspect_ratio ratio: 2.107, width: CARD_BODY_W, clip: true do
          shot = image Showcase.asset(:room), width: CARD_BODY_W, height: 150,
                       fill_mode: :preserve_aspect_crop, asynchronous: true, cache: true,
                       smooth: true
          on(shot, :loaded) { sc_log("Room image loaded") }
          on(shot, :error) { sc_log("Room image failed to load") }
        end
        sc_eyebrow("FILL_MODE · three of six")
        row spacing: 8 do
          [[:preserve_aspect_fit, "fit"], [:preserve_aspect_crop, "crop"], [:tile, "tile"]].each do |mode, name|
            column spacing: 4 do
              constrained_box max_width: 104, max_height: 70, clip: true do
                image Showcase.asset(:heart), width: 104, height: 70, fill_mode: mode,
                      asynchronous: true
              end
              text name, size: 9, color: FAINT, wrap: false
            end
          end
        end
        sc_eyebrow("ANIMATED_IMAGE · WebP frames")
        aspect_ratio ratio: 3.29, width: CARD_BODY_W, clip: true do
          moving = animated_image Showcase.asset(:animated), width: CARD_BODY_W, height: 96,
                                  fill_mode: :preserve_aspect_crop, playing: true,
                                  paused: false, speed: 1.0, asynchronous: true, cache: true
          on(moving, :error) { sc_log("animated_image failed to load") }
        end
        sc_eyebrow("VECTOR_IMAGE · SVG at any scale")
        row spacing: 10 do
          vector_image Showcase.asset(:core), width: 90, height: 90,
                       fill_mode: :preserve_aspect_fit
          vector_image Showcase.asset(:cover), width: 90, height: 90,
                       fill_mode: :preserve_aspect_fit
          vector_image Showcase.asset(:home), width: 120, height: 90,
                       fill_mode: :preserve_aspect_fit
        end
      end
    end

    def sc_content_identity
      sc_card("Avatars, badges and chips", "Small components that carry state", glyph: :user,
              accent: VIOLET, tags: %w[avatar badge chip spacer separator divider]) do
        sc_eyebrow("AVATAR · image and initials")
        row spacing: 10 do
          avatar Showcase.asset(:ruby), size: 54, radius: 27, asynchronous: true
          avatar nil, name: "Ada Lovelace", size: 54, radius: 27, background: TINT,
                 foreground: CYAN, font_size: 18
          avatar nil, name: "Zui Showcase", size: 54, radius: 16, background: "#2a1f45",
                 foreground: VIOLET, font_size: 16
        end
        sc_eyebrow("BADGE · counter, maximum and dot")
        row spacing: 10 do
          badge 7, size: 28, background: CYAN, foreground: INK, font_size: 12
          badge 128, maximum: 99, size: 28, minimum_width: 44, background: ROSE,
                foreground: INK, font_size: 12
          badge nil, dot: true, size: 14, background: MINT
          live = badge 0, size: 28, minimum_width: 40, background: PANEL_ALT, foreground: GOLD,
                       font_size: 12
          bind(live, :value) { state.tick.to_i % 100 }
        end
        sc_eyebrow("CHIP · selectable and deletable")
        wrap width: CARD_BODY_W, spacing: 6 do
          [["Reactive", MINT], ["Native", CYAN], ["Ruby", ROSE]].each do |name, tone|
            tag = chip name, height: 30, font_size: 11, radius: 9, horizontal_padding: 10,
                       deletable: true, background: PANEL_ALT, selected_background: TINT,
                       foreground: MUTED, selected_foreground: tone, accent: tone do
              transaction do
                state.chip_name = name
                state.activity = "chip #{name} selected"
              end
            end
            on(tag, :delete) { sc_log("chip #{name} deleted") }
            bind(tag, :selected) { state.chip_name.to_s == name }
          end
        end
      end
    end

    def sc_content_hero
      sc_card("Panel hero", "A Zui-native display control", glyph: :star, accent: GOLD,
              tags: %w[panel_hero section_header text]) do
        rectangle width: CARD_BODY_W, height: 120, radius: 14, color: PANEL_ALT,
                  border_color: BORDER_SOFT, border_width: 1, padding: 14 do
          panel_hero "Habitat One", meta: "2.4 kW · 18 devices", detail: "Scene: Focus",
                     foreground: WHITE, icon_size: 26, icon_opacity: 0.9, meta_opacity: 0.7
        end
        sc_rule
        sc_eyebrow("TEXT STYLES IN CONTEXT")
        sc_panel do
          text "Ship time", style: :caption, color: MUTED, wrap: false
          clock = text "00:00:00", size: 26, bold: true, color: GOLD, wrap: false
          bind(clock, :text) { sc_clock }
          text "bound to the same 1s scheduler as the overview chart", size: 10, color: FAINT,
               width: 288, wrap: true
        end
      end
    end

    def sc_content_note
      card width: FULL_W, padding: 18, spacing: 12, color: PANEL, border_color: BORDER,
           accent: MUTED do
        sc_head(:info, "Components that need your own assets",
                "These render real files; the showcase ships no placeholder for them.",
                accent: MUTED, width: FULL_W - 36)
        wrap width: FULL_W - 36, spacing: 10 do
          [["model_view_3d", "A .mesh / .qml 3D asset and Qt Quick 3D"],
           ["font_loader", "A font file to register at runtime"],
           ["video", "A video file — see the Media page for the audio path"],
           ["responsive_view", "A mobile root surface; it sizes to the whole window"]].each do |name, note|
            rectangle width: 256, height: 86, radius: 12, padding: 14, color: PANEL_ALT,
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

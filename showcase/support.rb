# frozen_string_literal: true

module Showcase
  # Shared presentation helpers. Every method here runs inside the Zui builder,
  # so it may call component methods directly and `yield` back into caller scope.
  module UI
    # ---------------------------------------------------------------- activity
    def sc_log(message)
      state.activity = message.to_s
      state.activity_revision = state.activity_revision.to_i + 1
    end

    # ------------------------------------------------------------------ typeset
    def sc_eyebrow(value, color: FAINT)
      text value.to_s, style: :caption, color: color, wrap: false
    end

    def sc_caption(value, width: CARD_BODY_W, color: MUTED, size: 11)
      text value.to_s, size: size, color: color, width: width, wrap: true
    end

    def sc_heading(value, size: 20, color: WHITE, width: CARD_BODY_W)
      text value.to_s, size: size, bold: true, color: color, width: width, wrap: true
    end

    def sc_value(value, color: WHITE, size: 12)
      text value.to_s, size: size, bold: true, color: color, wrap: false
    end

    # -------------------------------------------------------------------- bits
    def sc_tile(glyph, accent: CYAN, size: 40, radius: 13, color: TINT, glyph_size: 18)
      rectangle width: size, height: size, radius: radius, color: color do
        icon glyph, size: glyph_size, color: accent
      end
    end

    def sc_head(glyph, heading, subtitle, accent: CYAN, width: CARD_BODY_W)
      row spacing: 12 do
        sc_tile(glyph, accent: accent)
        column spacing: 2, width: width - 52 do
          text heading.to_s, size: 16, bold: true, color: WHITE, wrap: false
          sc_caption(subtitle, width: width - 52, size: 11)
        end
      end
    end

    def sc_tags(names, width: CARD_BODY_W)
      return if names.nil? || names.empty?

      wrap width: width, spacing: 6 do
        names.each do |name|
          chip name.to_s, height: 22, font_size: 9, radius: 7, horizontal_padding: 8, spacing: 4,
               background: PANEL_DEEP, selected_background: PANEL_DEEP,
               foreground: FAINT, selected_foreground: FAINT, accent: BORDER
        end
      end
    end

    # Returns the value node so callers can bind it reactively.
    def sc_kv(key, value, accent: WHITE, key_width: 132, width: CARD_BODY_W)
      figure = nil
      row spacing: 8, width: width do
        text key.to_s, size: 11, color: MUTED, width: key_width, wrap: false
        figure = sc_value(value, color: accent, size: 11)
      end
      figure
    end

    # Returns the value text node so callers can bind it reactively.
    def sc_stat(label, value, accent, width: 104, size: 21)
      figure = nil
      column spacing: 1, width: width do
        figure = text value.to_s, size: size, bold: true, color: accent, wrap: false
        sc_eyebrow(label, color: MUTED)
      end
      figure
    end

    def sc_code(source, width: CARD_BODY_W)
      rectangle width: width, radius: 10, padding: 12, color: PANEL_DEEP, border_color: BORDER_SOFT,
                border_width: 1 do
        selectable_text source.to_s, size: 10, color: MINT, width: width - 24, wrap: true,
                        selection_color: TINT, selected_text_color: WHITE
      end
    end

    def sc_rule(width: CARD_BODY_W)
      divider orientation: :horizontal, length: width, thickness: 1, color: BORDER_SOFT, opacity: 0.9
    end

    def sc_swatch(name, value, note)
      row spacing: 10, width: CARD_BODY_W do
        rectangle width: 34, height: 34, radius: 10, color: value, border_color: BORDER,
                  border_width: 1
        column spacing: 1, width: CARD_BODY_W - 46 do
          row spacing: 6 do
            sc_value(name, size: 12)
            text value, size: 10, color: FAINT, wrap: false
          end
          sc_caption(note, width: CARD_BODY_W - 46, size: 10)
        end
      end
    end

    # ------------------------------------------------------------------- cards
    def sc_card(heading, subtitle, glyph: :circle_info, accent: CYAN, tags: [], width: CARD_W,
                color: PANEL, padding: 20, spacing: 14, &body)
      card width: width, padding: padding, spacing: spacing, color: color, border_color: BORDER,
           accent: accent do
        sc_head(glyph, heading, subtitle, accent: accent, width: width - padding * 2)
        instance_eval(&body) if body
        sc_tags(tags, width: width - padding * 2)
      end
    end

    def sc_panel(width: CARD_BODY_W, padding: 14, color: PANEL_ALT, spacing: 10, radius: 14,
                 border: BORDER_SOFT, &body)
      rectangle width: width, radius: radius, padding: padding, color: color,
                border_color: border, border_width: 1 do
        column spacing: spacing, width: width - padding * 2 do
          instance_eval(&body) if body
        end
      end
    end

    # Formatted from the shared scheduler tick so several pages can share a clock.
    def sc_clock
      total = state.tick.to_i
      hours = (total / 3600) % 24
      minutes = (total / 60) % 60
      seconds = total % 60
      [hours, minutes, seconds].map { |part| part < 10 ? "0#{part}" : part.to_s }.join(":")
    end

    # ------------------------------------------------------------------- pages
    # A page is a vertically scrolling stack of card rows.
    def sc_page(&body)
      scroll width: CONTENT_W, height: PAGE_H, clip: true do
        container padding: 18, spacing: 18 do
          instance_eval(&body) if body
        end
      end
    end

    def sc_row(spacing: 16, &body)
      row spacing: spacing do
        instance_eval(&body) if body
      end
    end
  end
end

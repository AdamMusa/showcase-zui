# frozen_string_literal: true

module Showcase
  module UI
    # ------------------------------------------------------------------- shell
    def showcase_root
      row spacing: 0 do
        sc_sidebar
        column spacing: 0 do
          sc_topbar
          sc_stack
        end
      end
    end

    def sc_stack
      stack_layout width: CONTENT_W, height: PAGE_H do
        property :current_index do
          state.page.to_i
        end
        PAGES.each { |page| public_send("sc_page_#{page[:key]}") }
      end
    end

    # ----------------------------------------------------------------- sidebar
    def sc_sidebar
      rectangle width: SIDEBAR_W, height: WINDOW_H, color: PANEL do
        column spacing: 0, width: SIDEBAR_W do
          sc_brand
          divider orientation: :horizontal, length: SIDEBAR_W, thickness: 1, color: BORDER_SOFT
          sc_nav_list
          divider orientation: :horizontal, length: SIDEBAR_W, thickness: 1, color: BORDER_SOFT
          sc_sidebar_footer
        end
      end
    end

    def sc_brand
      rectangle width: SIDEBAR_W, height: TOPBAR_H, padding: 18, color: PANEL do
        row spacing: 12 do
          rectangle width: 44, height: 44, radius: 14, color: TINT, border_color: CYAN,
                    border_width: 1 do
            text "Z", size: 23, bold: true, color: CYAN, wrap: false
          end
          column spacing: 1, width: 168 do
            text "ZUI SHOWCASE", size: 14, bold: true, color: WHITE, wrap: false
            sc_eyebrow("NATIVE RUBY INTERFACES", color: FAINT)
          end
        end
      end
    end

    def sc_nav_list
      rectangle width: SIDEBAR_W, padding: 12, color: PANEL do
        column spacing: 2, width: SIDEBAR_W - 24 do
          PAGES.each_with_index do |page, index|
            item = item_delegate page[:label], value: index, icon: page[:glyph],
                                 width: SIDEBAR_W - 24, height: 38, radius: 11, padding: 10,
                                 spacing: 12, icon_size: 16, font_size: 13,
                                 background: PANEL, selected_background: TINT,
                                 foreground: MUTED, selected_foreground: WHITE,
                                 muted: FAINT, accent: page[:accent], border_color: PANEL,
                                 show_indicator: false do
              sc_goto(index)
            end
            bind(item, :selected) { state.page.to_i == index }
            bind(item, :icon_color) { state.page.to_i == index ? page[:accent] : FAINT }
          end
        end
      end
    end

    def sc_sidebar_footer
      rectangle width: SIDEBAR_W, height: 92, padding: 16, color: PANEL do
        column spacing: 6, width: SIDEBAR_W - 32 do
          row spacing: 8 do
            sc_stat("COMPONENTS", REGISTRY_COUNT, CYAN, width: 108)
            live = sc_stat("ON SCREEN", "—", MINT, width: 108)
            bind(live, :text) { state.live_count.to_i.to_s }
          end
          sc_caption("#{DEMOS.size} bundled demo apps", width: SIDEBAR_W - 32, size: 10)
        end
      end
    end

    def sc_goto(index)
      transaction do
        state.page = index
        state.activity = "Opened #{PAGES[index][:label]}"
      end
    end

    # ------------------------------------------------------------------ topbar
    def sc_topbar
      rectangle width: CONTENT_W, height: TOPBAR_H, padding: 18, color: PANEL_DEEP do
        row spacing: 16 do
          column spacing: 2, width: 520 do
            title = text "", size: 20, bold: true, color: WHITE, wrap: false
            bind(title, :text) { PAGES[state.page.to_i][:title] }
            subtitle = text "", size: 11, color: MUTED, width: 520, wrap: false
            bind(subtitle, :text) { PAGES[state.page.to_i][:subtitle] }
          end
          spacer width: 148, height: 1
          sc_activity_strip
        end
      end
    end

    def sc_activity_strip
      rectangle width: 420, height: 52, radius: 14, padding: 10, color: PANEL,
                border_color: BORDER, border_width: 1 do
        row spacing: 10 do
          pulse = sc_tile(:bell, accent: MINT, size: 32, radius: 10, glyph_size: 14)
          bind(pulse, :color) { state.activity_revision.to_i.odd? ? "#14362b" : TINT }
          column spacing: 1, width: 348 do
            sc_eyebrow("LAST EVENT", color: FAINT)
            line = text "Showcase ready", size: 12, bold: true, color: MINT, width: 348,
                        wrap: false
            bind(line, :text) { state.activity.to_s }
          end
        end
      end
    end
  end
end

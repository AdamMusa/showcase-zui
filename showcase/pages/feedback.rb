# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_feedback
      sc_page do
        sc_row do
          sc_feedback_menus
          sc_feedback_dialogs
          sc_feedback_sheets
        end
        sc_row do
          sc_feedback_transient
          sc_feedback_progress
          sc_feedback_inline
        end
        sc_feedback_overlays
      end
    end

    def sc_feedback_menus
      sc_card("Menus", "Menu bars, menus and context menus", glyph: :menu, accent: VIOLET,
              tags: %w[menu_bar menu_bar_item menu menu_item menu_separator context_menu]) do
        sc_eyebrow("MENU_BAR · native menus")
        bar = menu_bar [
          { "title" => "File",
            "items" => [{ "label" => "New window", "value" => "new" },
                        { "label" => "Open demo…", "value" => "open" },
                        { "separator" => true },
                        { "label" => "Quit", "value" => "quit" }] },
          { "title" => "View",
            "items" => [{ "label" => "Catalog", "value" => "catalog" },
                        { "label" => "Charts", "value" => "charts" },
                        { "label" => "Demo apps", "value" => "apps" }] },
          { "title" => "Help",
            "items" => [{ "label" => "Documentation", "value" => "docs" }] }
        ], width: CARD_BODY_W, height: 42, spacing: 8, padding: 6, background: PANEL_DEEP,
           foreground: WHITE, muted: FAINT, accent: VIOLET, border_color: BORDER_SOFT,
           radius: 10, font_size: 12
        on(bar, :trigger) { |event| sc_menu_route(event["value"].to_s) }
        sc_eyebrow("MENU · opened from Ruby state")
        standalone = menu [{ "label" => "Duplicate", "value" => "duplicate" },
                           { "label" => "Rename", "value" => "rename" },
                           { "separator" => true },
                           { "label" => "Delete", "value" => "delete" }],
                          title: "Row actions", opened: false, modal: true, width: 220,
                          background: PANEL, foreground: WHITE, muted: FAINT, accent: VIOLET,
                          border_color: BORDER, radius: 10, font_size: 12
        bind(standalone, :opened) { state.menu_open == true }
        on(standalone, :trigger) { |event| sc_log("menu → #{event["value"]}") }
        on(standalone, :close) { state.menu_open = false }
        button "Open the menu", icon: :menu, width: CARD_BODY_W, height: 40, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: VIOLET, font_size: 12 do
          state.menu_open = true
        end
        sc_eyebrow("MENU_BAR_ITEM · one bar entry")
        row spacing: 6 do
          %w[File View Help].each do |title|
            entry = menu_bar_item title, width: 72, height: 32, padding: 8,
                                  foreground: MUTED, background: PANEL_DEEP,
                                  highlighted_background: TINT, font_size: 11 do
              sc_log("menu_bar_item #{title}")
            end
            bind(entry, :highlighted) { state.menu_bar_entry.to_s == title }
            on(entry, :hover) { state.menu_bar_entry = title }
          end
        end
        sc_eyebrow("MENU_ITEM · composed by hand")
        column spacing: 2, width: CARD_BODY_W do
          [["Copy id", :copy, CYAN], ["Open docs", :link, MINT], ["Remove", :trash, ROSE]].each do |label, glyph, tone|
            menu_item label, icon: glyph, width: CARD_BODY_W, height: 34,
                      background: PANEL_ALT, highlighted_background: TINT, foreground: WHITE,
                      highlighted_foreground: tone, muted: FAINT, accent: tone,
                      border_color: PANEL_ALT, radius: 8, font_size: 11 do
              sc_log("menu_item #{label}")
            end
          end
          menu_separator thickness: 1, width: CARD_BODY_W, color: BORDER_SOFT, padding: 4
        end
        sc_eyebrow("CONTEXT_MENU · right-click the panel")
        target = rectangle width: CARD_BODY_W, height: 56, radius: 12, color: PANEL_ALT,
                           border_color: BORDER_SOFT, border_width: 1 do
          text "right-click me", size: 11, color: MUTED, wrap: false
        end
        context_menu [{ "label" => "Inspect", "value" => "inspect" },
                      { "label" => "Copy name", "value" => "copy" },
                      { "separator" => true },
                      { "label" => "Reset", "value" => "reset" }],
                     target: target, modal: false, width: 200, background: PANEL,
                     foreground: WHITE, muted: FAINT, accent: CYAN, border_color: BORDER,
                     radius: 10, font_size: 11
      end
    end

    def sc_menu_route(value)
      case value
      when "catalog" then sc_goto(Showcase.page_index(:catalog))
      when "charts" then sc_goto(Showcase.page_index(:charts))
      when "apps" then sc_goto(Showcase.page_index(:apps))
      else sc_log("menu_bar → #{value}")
      end
    end

    def sc_feedback_dialogs
      sc_card("Dialogs", "Four kinds, all driven by one boolean each", glyph: :warning,
              accent: ROSE, tags: %w[dialog alert_dialog message_dialog confirm_dialog]) do
        button "Open dialog", icon: :menu, width: CARD_BODY_W, height: 40, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: CYAN, font_size: 12 do
          state.dialog_open = true
        end
        button "Open alert_dialog", icon: :warning, width: CARD_BODY_W, height: 40,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: GOLD,
               font_size: 12 do
          state.alert_open = true
        end
        button "Open message_dialog", icon: :info, width: CARD_BODY_W, height: 40,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: VIOLET,
               font_size: 12 do
          state.message_open = true
        end
        button "Open confirm_dialog", icon: :circle_check, width: CARD_BODY_W, height: 40,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: ROSE,
               font_size: 12 do
          state.confirm_open = true
        end
        sc_rule
        answer = sc_kv("Last answer", "none", accent: ROSE, key_width: 110)
        bind(answer, :text) { state.dialog_answer.to_s }
      end
    end

    def sc_feedback_sheets
      sc_card("Sheets", "Bottom and edge sheets with drag to dismiss", glyph: :arrow_up,
              accent: MINT, tags: %w[bottom_sheet modal_sheet popup]) do
        button "Open bottom_sheet", icon: :arrow_up, width: CARD_BODY_W, height: 40,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: MINT,
               font_size: 12 do
          state.sheet_open = true
        end
        button "Open modal_sheet", icon: :arrow_right, width: CARD_BODY_W, height: 40,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: CYAN,
               font_size: 12 do
          state.modal_open = true
        end
        button "Open popup", icon: :plus, width: CARD_BODY_W, height: 40, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: VIOLET, font_size: 12 do
          state.popup_open = true
        end
        sc_rule
        sc_caption("Sheets and popups are declared once, anywhere in the tree. Their `opened` " \
                   "property is bound to Ruby state, and their close events write it back.")
      end
    end

    def sc_feedback_transient
      sc_card("Transient feedback", "Snackbars, banners and toasts", glyph: :bell, accent: GOLD,
              tags: %w[snackbar banner toast]) do
        sc_eyebrow("BANNER · persistent, inline")
        banner "Three anomalies are waiting for classification.", title: "Review queue",
               severity: :warning, icon: :warning, action_text: "Review", dismissible: true,
               width: CARD_BODY_W, spacing: 10, padding: 14, background: PANEL_ALT,
               foreground: WHITE, muted: FAINT, accent: GOLD, warning_color: GOLD,
               border_color: BORDER_SOFT, radius: 12, font_size: 11, title_size: 12,
               icon_size: 16
        sc_eyebrow("SNACKBAR · bottom, with an action")
        bar = snackbar "Scene saved as Focus.", action_text: "Undo", opened: false,
                       duration: 4000, position: :bottom, max_width: 520, margin: 24,
                       padding: 14, background: PANEL_DEEP, foreground: WHITE,
                       action_color: MINT, border_color: BORDER, radius: 12, font_size: 12
        bind(bar, :opened) { state.snackbar_open == true }
        on(bar, :action) { sc_log("Snackbar action: undo") }
        on(bar, :timeout) { state.snackbar_open = false }
        on(bar, :dismiss) { state.snackbar_open = false }
        button "Show the snackbar", icon: :bell, width: CARD_BODY_W, height: 40, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: MINT, font_size: 12 do
          state.snackbar_open = true
        end
        sc_eyebrow("TOAST · top right, auto dismiss")
        notice = toast "Catalog refreshed", title: "Done", severity: :success, icon: :check,
                       opened: false, duration: 3000, position: :top_right, max_width: 360,
                       margin: 20, padding: 14, background: PANEL_DEEP, foreground: WHITE,
                       muted: FAINT, accent: MINT, success_color: MINT, border_color: BORDER,
                       radius: 12, font_size: 11, title_size: 12, icon_size: 16
        bind(notice, :opened) { state.toast_open == true }
        on(notice, :timeout) { state.toast_open = false }
        on(notice, :dismiss) { state.toast_open = false }
        button "Show the toast", icon: :check, width: CARD_BODY_W, height: 40, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: GOLD, font_size: 12 do
          state.toast_open = true
        end
      end
    end

    def sc_feedback_progress
      sc_card("Progress", "Determinate, indeterminate and skeleton", glyph: :refresh,
              accent: CYAN, tags: %w[busy_indicator progress_ring progress skeleton]) do
        row spacing: 18 do
          column spacing: 6, width: 100 do
            busy_indicator true, width: 56, height: 56, color: CYAN
            sc_eyebrow("BUSY", color: FAINT)
          end
          column spacing: 6, width: 100 do
            progress_ring 0, size: 56, thickness: 6, track_color: PANEL_ALT, color: VIOLET,
                          indeterminate: true, show_label: false
            sc_eyebrow("INDETERMINATE", color: FAINT)
          end
          column spacing: 6, width: 110 do
            ring = progress_ring 0, size: 56, thickness: 6, track_color: PANEL_ALT, color: MINT,
                                 show_label: true, label_format: "{percent}%", animated: true,
                                 font_size: 12
            bind(ring, :value) { state.job_progress.to_f }
            sc_eyebrow("DETERMINATE", color: FAINT)
          end
        end
        bar = progress 0, minimum: 0, maximum: 100, width: CARD_BODY_W, height: 8, color: MINT
        bind(bar, :value) { state.job_progress.to_i }
        row spacing: 8 do
          button "Run a job", icon: :play, width: 160, height: 36, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: MINT, font_size: 11 do
            transaction do
              state.job_running = true
              state.job_progress = 0
              state.activity = "Job started"
            end
          end
          button "Reset", icon: :reset, width: 150, height: 36, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: FAINT, font_size: 11 do
            transaction do
              state.job_running = false
              state.job_progress = 0
            end
          end
        end
        sc_eyebrow("SKELETON · loading placeholders")
        skeleton variant: :text, width: CARD_BODY_W, lines: 3, line_height: 12, spacing: 8,
                 last_line_width: 0.6, radius: 6, base_color: PANEL_ALT,
                 highlight_color: TINT, animated: true, duration: 1200
      end
    end

    def sc_feedback_inline
      sc_card("Severity in place", "The same banner at four severities", glyph: :info,
              accent: MUTED, tags: %w[banner alert_dialog toast]) do
        [[:info, "Scheduled maintenance tonight.", CYAN, :circle_info],
         [:success, "All twelve demos launched cleanly.", MINT, :circle_check],
         [:warning, "Two sensors have not reported in 5 minutes.", GOLD, :warning],
         [:error, "The native client is not configured.", ROSE, :circle_xmark]].each do |severity, message, tone, glyph|
          banner message, title: severity.to_s.capitalize, severity: severity, icon: glyph,
                 dismissible: false, width: CARD_BODY_W, spacing: 8, padding: 12,
                 background: PANEL_ALT, foreground: WHITE, muted: FAINT, accent: tone,
                 warning_color: GOLD, error_color: ROSE, success_color: MINT,
                 border_color: BORDER_SOFT, radius: 10, font_size: 11, title_size: 11,
                 icon_size: 14
        end
      end
    end

    # Window-level overlays live once at page level and are opened from state.
    def sc_feedback_overlays
      card width: FULL_W, padding: 18, spacing: 12, color: PANEL, border_color: BORDER,
           accent: MUTED do
        sc_head(:info, "Overlay declarations",
                "The dialogs, sheets and popups opened above are declared here, once.",
                accent: MUTED, width: FULL_W - 36)
        sc_caption("A Zui overlay is an ordinary component with an `opened` property. There is " \
                   "no imperative show/hide API: Ruby owns the boolean and the renderer " \
                   "follows it.", width: FULL_W - 36, size: 11)

        sheet = dialog "Component inspector", opened: false, centered: true, modal: true,
                       dim: true, width: 520, height: 300, standard_buttons: %i[ok cancel],
                       padding: 20, spacing: 12, background: PANEL, foreground: WHITE,
                       border_color: BORDER, radius: 16, font_size: 12 do
          column spacing: 10, width: 470 do
            sc_caption("A `dialog` is a container, so it holds any component tree — here a " \
                       "live readout of the catalog selection.", width: 470, size: 12)
            selected = sc_kv("Selected component", "button", accent: CYAN, key_width: 150,
                             width: 470)
            bind(selected, :text) { state.catalog_selected.to_s }
          end
        end
        bind(sheet, :opened) { state.dialog_open == true }
        on(sheet, :accept) { sc_dialog_answer("dialog accepted") }
        on(sheet, :reject) { sc_dialog_answer("dialog rejected") }
        on(sheet, :close) { state.dialog_open = false }

        alert = alert_dialog "Deep scan complete", "Seven signatures classified",
                             severity: :success, icon: :circle_check, show_icon: true,
                             informative_text: "No hostile intent detected · lattice 7A–9F",
                             detailed_text: "camera: ok\nlidar: ok\nradar: degraded",
                             opened: false, centered: true, modal: true, width: 520,
                             height: 380, standard_buttons: %i[ok], spacing: 12, padding: 20,
                             background: PANEL, header_background: PANEL_ALT,
                             footer_background: PANEL_ALT, foreground: WHITE, muted: FAINT,
                             accent: MINT, success_color: MINT, border_color: BORDER,
                             radius: 16, font_size: 12, title_size: 17, message_size: 13
        bind(alert, :opened) { state.alert_open == true }
        on(alert, :accept) { sc_dialog_answer("alert_dialog acknowledged") }
        on(alert, :close) { state.alert_open = false }

        message = message_dialog "Open the demo?", "The showcase will launch it as its own " \
                                 "native process.", informative_text: "This uses the platform " \
                                 "dialog, not a Zui-drawn one.", opened: false,
                                 buttons: %i[ok cancel]
        bind(message, :opened) { state.message_open == true }
        on(message, :accept) { sc_dialog_answer("message_dialog accepted") }
        on(message, :reject) { sc_dialog_answer("message_dialog rejected") }
        on(message, :close) { state.message_open = false }

        confirm = confirm_dialog "Reset every control on this page?", opened: false,
                                 cancel_text: "Keep", confirm_text: "Reset",
                                 selected_index: 1, background: PANEL, foreground: WHITE,
                                 scrim: "#8f06090f", selected_background: ROSE,
                                 selected_text: INK, corner_radius: 14
        bind(confirm, :opened) { state.confirm_open == true }
        on(confirm, :confirm) do
          transaction do
            state.confirm_open = false
            state.dialog_answer = "confirm_dialog confirmed"
            state.clicks = 0
            state.job_progress = 0
          end
        end
        on(confirm, :cancel) { sc_dialog_answer("confirm_dialog cancelled") }

        bottom = bottom_sheet opened: false, modal: true, dim: true, dismissible: true,
                              draggable: true, padding: 20, spacing: 12, width: 640,
                              height: 260, max_width: 720, margin: 16, handle_visible: true,
                              dismiss_threshold: 0.35, animated: true, duration: 260,
                              background: PANEL, foreground: WHITE, muted: FAINT,
                              accent: MINT, border_color: BORDER, radius: 20 do
          column spacing: 12, width: 580 do
            sc_head(:arrow_up, "Bottom sheet", "Drag the handle down to dismiss", accent: MINT,
                    width: 580)
            row spacing: 10 do
              %w[Morning Focus Away Night].each do |scene|
                button scene, width: 136, height: 40, bordered: true, foreground: WHITE,
                       background: PANEL_ALT, accent: MINT, font_size: 12 do
                  transaction do
                    state.scene = scene
                    state.sheet_open = false
                    state.activity = "Scene set to #{scene}"
                  end
                end
              end
            end
          end
        end
        bind(bottom, :opened) { state.sheet_open == true }
        on(bottom, :close) { state.sheet_open = false }
        on(bottom, :dismiss) { state.sheet_open = false }

        side = modal_sheet "Filters", opened: false, edge: :right, modal: true, dim: true,
                           dismissible: true, show_header: true, show_close: true, width: 380,
                           height: WINDOW_H, max_height: WINDOW_H, margin: 0, header_height: 56,
                           padding: 20, spacing: 14, animated: true, duration: 240,
                           background: PANEL, header_background: PANEL_ALT, foreground: WHITE,
                           muted: FAINT, accent: CYAN, border_color: BORDER, radius: 0,
                           font_size: 12, title_size: 15 do
          column spacing: 12, width: 330 do
            sc_caption("A modal_sheet enters from an edge and owns its own header.", width: 330,
                       size: 11)
            CATEGORY_ORDER.first(6).each do |category|
              checkbox category, checked: true, accent: CYAN, foreground: WHITE, font_size: 11,
                       indicator_size: 16
            end
            button "Apply", width: 330, height: 40, foreground: INK, background: CYAN,
                   accent: CYAN, font_size: 12 do
              transaction do
                state.modal_open = false
                state.activity = "Filters applied"
              end
            end
          end
        end
        bind(side, :opened) { state.modal_open == true }
        on(side, :close) { state.modal_open = false }
        on(side, :dismiss) { state.modal_open = false }

        floating = popup opened: false, x: 420, y: 260, width: 360, height: 180, modal: true,
                         dim: true, padding: 18, spacing: 10, animated: true, duration: 180,
                         background: PANEL, foreground: WHITE, border_color: BORDER, radius: 16 do
          column spacing: 10, width: 324 do
            sc_head(:plus, "Popup", "Positioned, modal and dimmed", accent: VIOLET, width: 324)
            button "Close", width: 324, height: 38, bordered: true, foreground: WHITE,
                   background: PANEL_ALT, accent: VIOLET, font_size: 12 do
              state.popup_open = false
            end
          end
        end
        bind(floating, :opened) { state.popup_open == true }
        on(floating, :close) { state.popup_open = false }
      end
    end

    def sc_dialog_answer(message)
      transaction do
        state.dialog_answer = message
        state.activity = message
        state.dialog_open = false
        state.alert_open = false
        state.message_open = false
        state.confirm_open = false
      end
    end
  end
end

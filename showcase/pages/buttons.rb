# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_buttons
      sc_page do
        sc_row do
          sc_buttons_primary
          sc_buttons_shapes
          sc_buttons_bar
        end
        sc_row do
          sc_buttons_toggles
          sc_buttons_choice
          sc_buttons_actions
        end
      end
    end

    def sc_buttons_primary
      sc_card("Buttons", "One component, every emphasis", glyph: :check, accent: MINT,
              tags: %w[button abstract_button tooltip]) do
        counter = sc_kv("Clicks recorded", "0", accent: MINT, key_width: 120)
        bind(counter, :text) { state.clicks.to_i.to_s }
        button "Primary action", icon: :check, width: CARD_BODY_W, height: 44, foreground: INK,
               background: MINT, accent: MINT, font_size: 13 do
          sc_bump_clicks("Primary action")
        end
        button "Bordered", icon: :plus, width: CARD_BODY_W, height: 42, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: CYAN, font_size: 12 do
          sc_bump_clicks("Bordered button")
        end
        row spacing: 8 do
          button "Left aligned", icon: :folder, width: 168, height: 40, left_align: true,
                 bordered: true, foreground: WHITE, background: PANEL_ALT, accent: VIOLET,
                 font_size: 12 do
            sc_bump_clicks("Left aligned button")
          end
          button "Spinning", icon: :refresh, icon_spinning: true, width: 140, height: 40,
                 bordered: true, foreground: GOLD, background: PANEL_ALT, accent: GOLD,
                 font_size: 12 do
            sc_bump_clicks("Spinning icon button")
          end
        end
        disabled = button "Disabled while idle", width: CARD_BODY_W, height: 40, bordered: true,
                          foreground: FAINT, background: PANEL_DEEP, accent: BORDER,
                          font_size: 12
        bind(disabled, :enabled) { state.clicks.to_i.positive? }
        sc_eyebrow("ABSTRACT_BUTTON · the shared base")
        base = abstract_button text: "abstract_button", checkable: true, width: CARD_BODY_W,
                               height: 40, padding: 10, radius: 10, background: PANEL_ALT,
                               foreground: WHITE, border_color: BORDER, font_size: 12
        on(base, :click) { sc_bump_clicks("abstract_button") }
        on(base, :press_and_hold) { sc_log("abstract_button held") }
      end
    end

    def sc_bump_clicks(source)
      total = state.clicks.to_i + 1
      transaction do
        state.clicks = total
        state.activity = "#{source} · #{total} click#{total == 1 ? "" : "s"}"
      end
    end

    def sc_toggle_member(key, name)
      current = Array(state.public_send(key))
      state.public_send("#{key}=", current.include?(name) ? current - [name] : current + [name])
    end

    def sc_buttons_shapes
      sc_card("Round, tool and delay", "Shaped and time-based buttons", glyph: :power,
              accent: CYAN, tags: %w[round_button tool_button delay_button action_button]) do
        sc_eyebrow("ROUND_BUTTON · checkable")
        row spacing: 10 do
          [[:play, CYAN], [:pause, VIOLET], [:stop, ROSE], [:heart, GOLD]].each do |glyph, tone|
            knob = round_button "", icon: glyph, diameter: 52, checkable: true,
                                foreground: tone, background: PANEL_ALT,
                                checked_background: TINT, accent: tone, icon_size: 18 do
              sc_log("round_button :#{glyph}")
            end
            bind(knob, :checked) { state.round_glyph.to_s == glyph.to_s }
            on(knob, :change) { state.round_glyph = glyph.to_s }
          end
        end
        sc_eyebrow("TOOL_BUTTON")
        row spacing: 8 do
          %i[edit copy trash].each do |glyph|
            tool_button "", icon: glyph, width: 48, height: 40, foreground: MUTED,
                        background: PANEL_ALT, checked_background: TINT, accent: CYAN,
                        icon_size: 16 do
              sc_log("tool_button :#{glyph}")
            end
          end
          action_button :gear, tooltip: "action_button with a tooltip", size: 40,
                        foreground: MUTED, hover_color: CYAN, bordered: true do
            sc_log("action_button :gear")
          end
        end
        sc_eyebrow("DELAY_BUTTON · hold to confirm")
        hold = delay_button "Hold to arm", delay: 1200, width: CARD_BODY_W, height: 46,
                            foreground: WHITE, background: PANEL_ALT,
                            progress_background: TINT, accent: ROSE, font_size: 12 do
          transaction do
            state.armed = !state.armed
            state.activity = state.armed ? "Armed by delay_button" : "Disarmed"
          end
        end
        on(hold, :cancel) { sc_log("delay_button released early") }
        armed = sc_kv("State", "idle", accent: ROSE, key_width: 120)
        bind(armed, :text) { state.armed ? "armed" : "idle" }
      end
    end

    def sc_buttons_bar
      sc_card("Zui bar controls", "Panel-native buttons and indicators", glyph: :menu,
              accent: VIOLET, tags: %w[bar_icon_button bar_indicator widget_button cursor_surface]) do
        sc_eyebrow("BAR_ICON_BUTTON")
        rectangle width: CARD_BODY_W, height: 54, radius: 12, color: PANEL_DEEP,
                  border_color: BORDER_SOFT, border_width: 1 do
          row spacing: 6 do
            %i[house search bell gear user].each do |glyph|
              slot = bar_icon_button glyph, tooltip: glyph.to_s, slot_size: 38, optical_size: 17,
                                     foreground: MUTED, active_color: VIOLET do
                state.bar_glyph = glyph.to_s
                sc_log("bar_icon_button :#{glyph}")
              end
              bind(slot, :active) { state.bar_glyph.to_s == glyph.to_s }
            end
          end
        end
        sc_eyebrow("BAR_INDICATOR · two states")
        rectangle width: CARD_BODY_W, height: 54, radius: 12, color: PANEL_DEEP,
                  border_color: BORDER_SOFT, border_width: 1 do
          row spacing: 10 do
            mic = bar_indicator :volume_high, inactive_icon: :volume_off,
                                active_tooltip: "Audio on", inactive_tooltip: "Audio muted",
                                foreground: MUTED, active_color: MINT do
              transaction do
                state.audio_on = !state.audio_on
                state.activity = state.audio_on ? "Audio enabled" : "Audio muted"
              end
            end
            bind(mic, :active) { state.audio_on == true }
            net = bar_indicator :wifi, inactive_icon: :xmark, active_tooltip: "Online",
                                inactive_tooltip: "Offline", foreground: MUTED,
                                active_color: CYAN do
              state.online = !state.online
            end
            bind(net, :active) { state.online == true }
            widget_button "WIDGET", font_size: 11, foreground: MUTED, active_color: GOLD,
                          horizontal_margin: 10, vertical_padding: 6, pressable: true,
                          use_active_color: true, tooltip: "widget_button" do
              sc_log("widget_button pressed")
            end
          end
        end
        sc_eyebrow("CURSOR_SURFACE · keyboard cursor")
        cursor_surface width: CARD_BODY_W, cursor: 1, current: 1, outline: true, bordered: true,
                       foreground: WHITE, accent: CYAN, fill: PANEL_ALT, current_fill: TINT do
          row spacing: 8 do
            text "focus ring surface", size: 11, color: MUTED, wrap: false
          end
        end
      end
    end

    def sc_buttons_toggles
      sc_card("Toggles", "Four ways to express a boolean", glyph: :check, accent: MINT,
              tags: %w[toggle toggle_switch checkbox radio_button]) do
        main = toggle "Reduced motion", description: "Pause every animation on this page",
                      checked: false, accent: MINT, foreground: WHITE, title_size: 13,
                      description_size: 10 do |event|
          state.reduced_motion = event["value"] != false
          sc_log(state.reduced_motion ? "Reduced motion on" : "Reduced motion off")
        end
        bind(main, :checked) { state.reduced_motion == true }
        sc_rule
        row spacing: 14 do
          column spacing: 8, width: 150 do
            sc_eyebrow("CHECKBOX")
            %w[Charts Motion Media].each do |name|
              box = checkbox name, checked: true, accent: CYAN, foreground: WHITE, font_size: 12,
                             indicator_size: 18 do |event|
                sc_toggle_member(:unchecked, name)
                sc_log("#{name} #{event["value"] == false ? "unchecked" : "checked"}")
              end
              bind(box, :checked) { !Array(state.unchecked).include?(name) }
            end
          end
          column spacing: 8, width: 160 do
            sc_eyebrow("TOGGLE_SWITCH")
            [["Telemetry", MINT], ["Autoplay", CYAN], ["Haptics", VIOLET]].each do |name, tone|
              row spacing: 8 do
                flip = toggle_switch checked: true, accent: tone, foreground: WHITE,
                                     track_width: 42, track_height: 20, knob_size: 16 do |event|
                  sc_toggle_member(:switched_off, name)
                  sc_log("#{name} #{event["value"] == false ? "off" : "on"}")
                end
                bind(flip, :checked) { !Array(state.switched_off).include?(name) }
                text name, size: 11, color: MUTED, wrap: false
              end
            end
          end
        end
      end
    end

    def sc_buttons_choice
      sc_card("Exclusive choice", "Radios, radio groups and button groups", glyph: :menu,
              accent: GOLD, tags: %w[radio_button radio_group button_group]) do
        sc_eyebrow("RADIO_BUTTON · manual exclusivity")
        %w[Comfortable Compact Dense].each do |name|
          choice = radio_button name, value: name, checked: false, accent: GOLD,
                                foreground: WHITE, font_size: 12, indicator_size: 17 do
            transaction do
              state.density = name
              state.activity = "Density: #{name}"
            end
          end
          bind(choice, :checked) { state.density.to_s == name }
        end
        sc_rule
        sc_eyebrow("RADIO_GROUP · one component")
        group = radio_group "Daily", options: %w[Hourly Daily Weekly], orientation: :horizontal,
                            spacing: 14, accent: CYAN, foreground: WHITE, font_size: 12 do |event|
          state.cadence = event["value"].to_s
          sc_log("Cadence: #{state.cadence}")
        end
        bind(group, :value) { state.cadence.to_s }
        sc_eyebrow("BUTTON_GROUP · segmented")
        segmented = button_group "Charts", options: %w[Charts Table Raw], foreground: MUTED,
                                 background: PANEL_ALT, accent: CYAN, font_size: 12 do |event|
          state.segment = event["value"].to_s
          sc_log("Segment: #{state.segment}")
        end
        bind(segmented, :value) { state.segment.to_s }
        readout = sc_kv("Selection", "Charts", accent: CYAN, key_width: 100)
        bind(readout, :text) { "#{state.segment} · #{state.cadence} · #{state.density}" }
      end
    end

    def sc_buttons_actions
      sc_card("Actions and button boxes", "Shared commands and standard dialog buttons",
              glyph: :terminal, accent: ROSE, tags: %w[action action_group dialog_button_box]) do
        sc_eyebrow("ACTION · reusable command objects")
        action "Save", icon: :save, shortcut: "Ctrl+S" do
          sc_log("Save action triggered")
        end
        action "Reload", icon: :refresh, shortcut: "Ctrl+R" do
          sc_log("Reload action triggered")
        end
        compact = action "Compact", icon: :menu, checkable: true, checked: true
        comfortable = action "Comfortable", icon: :menu, checkable: true
        action_group [compact, comfortable], checked: compact, exclusive: true
        sc_panel do
          sc_kv("Actions declared", "4", accent: ROSE, key_width: 140, width: 288)
          sc_kv("Exclusive group", "compact / comfortable", accent: MUTED, key_width: 140,
                width: 288)
          sc_caption("Actions carry text, icon, shortcut and checked state, and can be attached " \
                     "to menus, tool bars and buttons.", width: 288, size: 10)
        end
        row spacing: 8 do
          button "Trigger save", width: 150, height: 38, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: ROSE, font_size: 11 do
            sc_log("Save requested from a button")
          end
          button "Trigger reload", width: 150, height: 38, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: CYAN, font_size: 11 do
            sc_log("Reload requested from a button")
          end
        end
        sc_eyebrow("DIALOG_BUTTON_BOX · platform ordering")
        box = dialog_button_box %i[ok cancel apply], alignment: :right, spacing: 8,
                                width: CARD_BODY_W, height: 46, foreground: WHITE,
                                background: PANEL, accent: CYAN, font_size: 12
        on(box, :accept) { sc_log("dialog_button_box accepted") }
        on(box, :reject) { sc_log("dialog_button_box rejected") }
        on(box, :click) { |event| sc_log("dialog_button_box: #{event["role"] || event["value"]}") }
      end
    end
  end
end

# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_inputs
      sc_page do
        sc_row do
          sc_inputs_text
          sc_inputs_numeric
          sc_inputs_dials
        end
        sc_row do
          sc_inputs_dropdowns
          sc_inputs_pickers
          sc_inputs_files
        end
        sc_inputs_summary
      end
    end

    def sc_inputs_text
      sc_card("Text input", "Fields, areas, passwords and search", glyph: :edit, accent: CYAN,
              tags: %w[text_field password_field text_area search_field]) do
        sc_eyebrow("TEXT_FIELD")
        name = text_field "", placeholder: "Your name", width: CARD_BODY_W, height: 44,
                          foreground: WHITE, accent: CYAN, selection_tint: TINT,
                          horizontal_padding: 12 do |event|
          state.form_name = event["value"].to_s
        end
        bind(name, :text) { state.form_name.to_s }
        on(name, :submit) { sc_log("text_field submitted: #{state.form_name}") }
        sc_eyebrow("PASSWORD_FIELD · revealable")
        secret = password_field "", placeholder: "Passphrase", revealable: true, width: CARD_BODY_W,
                               height: 44, foreground: WHITE, accent: VIOLET,
                               selection_tint: TINT, horizontal_padding: 12 do |event|
          state.form_secret_length = event["value"].to_s.length
        end
        on(secret, :reveal) { |event| sc_log("Passphrase #{event["value"] ? "revealed" : "hidden"}") }
        strength = sc_kv("Characters", "0", accent: VIOLET, key_width: 110)
        bind(strength, :text) { state.form_secret_length.to_i.to_s }
        sc_eyebrow("TEXT_AREA · wrapping, max length")
        notes = text_area "", placeholder: "Release notes…", width: CARD_BODY_W, height: 92,
                          wrap: true, maximum_length: 280, foreground: WHITE,
                          background: PANEL_ALT, accent: CYAN, selection_tint: TINT,
                          font_size: 12, padding: 10 do |event|
          state.form_notes = event["value"].to_s
        end
        bind(notes, :text) { state.form_notes.to_s }
        remaining = sc_kv("Remaining", "280", accent: MUTED, key_width: 110)
        bind(remaining, :text) { (280 - state.form_notes.to_s.length).to_s }
        sc_eyebrow("SEARCH_FIELD · live suggestions")
        finder = search_field "", suggestions: COMPONENT_NAMES.first(40), live: true,
                             width: CARD_BODY_W, height: 44, foreground: WHITE,
                             background: PANEL_ALT, accent: MINT, font_size: 12
        on(finder, :input) { |event| state.form_search = event["value"].to_s }
        on(finder, :activate) { |event| sc_log("Chose #{event["value"]}") }
      end
    end

    def sc_inputs_numeric
      sc_card("Numbers", "Steppers, fields and sliders", glyph: :plus, accent: MINT,
              tags: %w[number_field spin_box double_spin_box slider range_slider]) do
        sc_eyebrow("NUMBER_FIELD")
        guests = number_field 4, label: "Guests", from: 1, to: 24, step: 1, accent: MINT,
                              foreground: WHITE, font_size: 12, field_width: 72 do |event|
          state.guests = event["value"].to_i
        end
        bind(guests, :value) { state.guests.to_i }
        sc_eyebrow("SPIN_BOX · prefix and suffix")
        row spacing: 10 do
          spin = spin_box 18, minimum: 0, maximum: 60, step: 1, editable: true, suffix: " min",
                          width: 150, foreground: WHITE, background: PANEL_ALT, accent: CYAN,
                          font_size: 12 do |event|
            state.minutes = event["value"].to_i
          end
          bind(spin, :value) { state.minutes.to_i }
          precise = double_spin_box 21.5, minimum: 15.0, maximum: 30.0, step: 0.5, decimals: 1,
                                    suffix: " °C", width: 150, foreground: WHITE,
                                    background: PANEL_ALT, accent: GOLD, font_size: 12 do |event|
            state.target_temp = event["value"].to_f
          end
          bind(precise, :value) { state.target_temp.to_f }
        end
        sc_eyebrow("SLIDER · with ticks")
        bright = slider 68, minimum: 0, maximum: 100, step: 1, integer: true,
                        track_color: PANEL_ALT, fill_color: MINT, knob_color: WHITE,
                        track_height: 6, knob_size: 18, ticks: 5, tick_color: BORDER do |event|
          state.brightness = event["value"].to_i
        end
        bind(bright, :value) { state.brightness.to_i }
        level = sc_kv("Brightness", "68%", accent: MINT, key_width: 110)
        bind(level, :text) { "#{state.brightness.to_i}%" }
        sc_eyebrow("RANGE_SLIDER · two handles")
        band = range_slider 19.0, 24.0, minimum: 10.0, maximum: 32.0, step: 0.5, snap: true,
                            live: true, width: CARD_BODY_W, height: 34, foreground: WHITE,
                            background: PANEL_ALT, accent: CYAN do |event|
          transaction do
            state.band_lower = event["lower"].to_f
            state.band_upper = event["upper"].to_f
          end
        end
        bind(band, :lower) { state.band_lower.to_f }
        bind(band, :upper) { state.band_upper.to_f }
        comfort = sc_kv("Comfort band", "19 – 24 °C", accent: CYAN, key_width: 110)
        bind(comfort, :text) do
          "#{state.band_lower.to_f.round(1)} – #{state.band_upper.to_f.round(1)} °C"
        end
      end
    end

    def sc_inputs_dials
      sc_card("Dials and rings", "Rotary input bound to the same state", glyph: :refresh,
              accent: VIOLET, tags: %w[dial progress_ring gauge progress]) do
        row spacing: 16 do
          knob = dial 68, minimum: 0, maximum: 100, step: 1, start_angle: -140, end_angle: 140,
                      snap: true, live: true, size: 132, foreground: WHITE,
                      background: PANEL_ALT, accent: VIOLET do |event|
            state.brightness = event["value"].to_i
          end
          bind(knob, :value) { state.brightness.to_i }
          column spacing: 10, width: 170 do
            ring = progress_ring 68, size: 86, thickness: 9, track_color: PANEL_ALT,
                                 color: VIOLET, foreground: WHITE, show_label: true,
                                 label_format: "%.0f%%", animated: true, font_size: 14
            bind(ring, :value) { state.brightness.to_f }
            bar = progress 68, minimum: 0, maximum: 100, width: 170, height: 8, color: VIOLET
            bind(bar, :value) { state.brightness.to_i }
          end
        end
        sc_caption("The dial, the ring and the bar all read `state.brightness`. The slider on " \
                   "the previous card writes it. One value, four native views, no manual " \
                   "synchronisation.")
        meter = gauge 68, minimum: 0, maximum: 100, width: CARD_BODY_W, height: 104, color: VIOLET,
                      track_color: PANEL_ALT, thickness: 14, label: "BRIGHTNESS",
                      label_format: "%.0f%%", show_label: true, font_size: 12
        bind(meter, :value) { state.brightness.to_f }
      end
    end

    def sc_inputs_dropdowns
      sc_card("Dropdowns", "Plain, searchable and multi-select", glyph: :chevron_down,
              accent: GOLD, tags: %w[dropdown searchable_dropdown multi_select tumbler]) do
        sc_eyebrow("DROPDOWN")
        scene = dropdown "Focus", label: "Scene", options: %w[Morning Focus Away Night],
                         show_label: true, foreground: WHITE, background: PANEL_ALT,
                         popup_border: BORDER, accent: GOLD, row_height: 42,
                         popup_row_height: 34 do |event|
          state.scene = event["value"].to_s
          sc_log("Scene: #{state.scene}")
        end
        bind(scene, :value) { state.scene.to_s }
        sc_eyebrow("SEARCHABLE_DROPDOWN · #{REGISTRY_COUNT} options")
        component = searchable_dropdown "button", label: "Component",
                                        options: COMPONENT_NAMES,
                                        placeholder: "Type to filter…",
                                        empty_text: "No component matches",
                                        trigger_label: "Pick", show_label: true,
                                        foreground: WHITE, background: PANEL_ALT,
                                        popup_border: BORDER, accent: CYAN, row_height: 42,
                                        popup_row_height: 30, popup_min_height: 220 do |event|
          transaction do
            state.catalog_selected = event["value"].to_s
            state.activity = "Selected #{event["value"]}"
          end
        end
        bind(component, :value) { state.catalog_selected.to_s }
        sc_eyebrow("MULTI_SELECT")
        rooms = multi_select %w[Kitchen Studio], label: "Rooms",
                             options: %w[Kitchen Living Studio Bedroom Garage],
                             placeholder: "Choose rooms", no_selection_text: "No rooms",
                             trigger_label: "Apply", show_label: true, foreground: WHITE,
                             background: PANEL_ALT, popup_border: BORDER, accent: MINT,
                             row_height: 42, popup_row_height: 32 do |event|
          state.rooms = Array(event["values"] || event["value"])
          sc_log("Rooms: #{state.rooms.join(", ")}")
        end
        bind(rooms, :values) { Array(state.rooms) }
        sc_eyebrow("TUMBLER · wheel selection")
        wheel = tumbler %w[05 10 15 20 25 30], current_index: 2, visible_item_count: 3,
                        wrap: true, width: CARD_BODY_W, height: 86, background: PANEL_ALT,
                        foreground: WHITE, muted: FAINT, accent: GOLD, font_size: 15
        on(wheel, :change) { |event| sc_log("Tumbler → #{event["value"]}") }
      end
    end

    def sc_inputs_pickers
      sc_card("Pickers", "Native colour, date and time dialogs", glyph: :calendar, accent: ROSE,
              tags: %w[color_picker date_picker time_picker]) do
        sc_eyebrow("COLOR_PICKER")
        swatch = color_picker CYAN, label: "Accent", title: "Pick an accent", show_alpha: false,
                              native_dialog: false, width: CARD_BODY_W, height: 46,
                              foreground: WHITE, background: PANEL_ALT, border_color: BORDER,
                              radius: 12, font_size: 12 do |event|
          state.accent = event["value"].to_s
          sc_log("Accent: #{state.accent}")
        end
        bind(swatch, :color) { state.accent.to_s }
        preview = rectangle width: CARD_BODY_W, height: 40, radius: 10, color: CYAN do
          text "bound preview", size: 11, bold: true, color: INK, wrap: false
        end
        bind(preview, :color) { state.accent.to_s }
        sc_eyebrow("DATE_PICKER")
        day = date_picker "2026-11-17", label: "Service date", format: "yyyy-MM-dd",
                          close_on_select: true, width: CARD_BODY_W, height: 46,
                          foreground: WHITE, muted: FAINT, background: PANEL_ALT,
                          popup_background: PANEL, border_color: BORDER, accent: ROSE,
                          radius: 12, font_size: 12 do |event|
          state.date = event["value"].to_s
          sc_log("Date: #{state.date}")
        end
        bind(day, :date) { state.date.to_s }
        sc_eyebrow("TIME_PICKER")
        clock = time_picker "09:30", label: "Window opens", use_24_hour: true, minute_step: 15,
                            width: CARD_BODY_W, height: 46, foreground: WHITE, muted: FAINT,
                            background: PANEL_ALT, popup_background: PANEL,
                            border_color: BORDER, accent: GOLD, radius: 12,
                            font_size: 12 do |event|
          state.time = event["value"].to_s
          sc_log("Time: #{state.time}")
        end
        bind(clock, :time) { state.time.to_s }
      end
    end

    def sc_inputs_files
      sc_card("File system and fonts", "Native dialogs, Ruby-owned state", glyph: :folder,
              accent: CYAN, tags: %w[file_picker folder_picker font_picker standard_paths]) do
        sc_eyebrow("FILE_PICKER · filters")
        picked = file_picker "", label: "Attachment", placeholder: "No file chosen",
                            title: "Choose an image", mode: :open, multiple: false,
                            filters: ["Images (*.png *.jpg *.svg)", "All files (*)"],
                            native_dialog: true, width: CARD_BODY_W, height: 46,
                            foreground: WHITE, muted: FAINT, background: PANEL_ALT,
                            border_color: BORDER, accent: CYAN, radius: 12,
                            font_size: 12 do |event|
          state.file_path = event["value"].to_s
          sc_log("Picked #{state.file_path}")
        end
        bind(picked, :path) { state.file_path.to_s }
        on(picked, :reject) { sc_log("File dialog cancelled") }
        sc_eyebrow("FOLDER_PICKER")
        folder = folder_picker "", label: "Export to", placeholder: "No folder chosen",
                               title: "Choose a folder", native_dialog: true,
                               width: CARD_BODY_W, height: 46, foreground: WHITE, muted: FAINT,
                               background: PANEL_ALT, border_color: BORDER, accent: MINT,
                               radius: 12, font_size: 12 do |event|
          state.folder_path = event["value"].to_s
          sc_log("Export folder #{state.folder_path}")
        end
        bind(folder, :path) { state.folder_path.to_s }
        sc_eyebrow("FONT_PICKER")
        font = font_picker "", label: "Report font", placeholder: "System default",
                           title: "Choose a font", point_size: 12, native_dialog: true,
                           width: CARD_BODY_W, height: 46, foreground: WHITE, muted: FAINT,
                           background: PANEL_ALT, border_color: BORDER, accent: VIOLET,
                           radius: 12, font_size: 12 do |event|
          state.font_family = event["value"].to_s
          sc_log("Font #{state.font_family}")
        end
        bind(font, :family) { state.font_family.to_s }
        sc_rule
        sc_caption("Every picker here writes one piece of Ruby state. Nothing is read back from " \
                   "the widget: the field below renders the same state the dialog wrote.")
        chosen = sc_kv("Current file", "none", accent: CYAN, key_width: 110)
        bind(chosen, :text) do
          path = state.file_path.to_s
          path.empty? ? "none" : path.split("/").last.to_s
        end
      end
    end

    def sc_inputs_summary
      card width: FULL_W, padding: 20, spacing: 14, color: PANEL, border_color: BORDER,
           accent: MINT do
        sc_head(:terminal, "One form, one state store",
                "Everything typed, dragged or picked on this page, read straight back out of Ruby.",
                accent: MINT, width: FULL_W - 40)
        dynamic type: :wrap, width: FULL_W - 40, spacing: 10 do
          [["Name", state.form_name.to_s.empty? ? "—" : state.form_name.to_s, CYAN],
           ["Notes", "#{state.form_notes.to_s.length} chars", MUTED],
           ["Guests", state.guests.to_s, MINT],
           ["Window", "#{state.minutes} min", CYAN],
           ["Target", "#{state.target_temp} °C", GOLD],
           ["Brightness", "#{state.brightness}%", VIOLET],
           ["Comfort", "#{state.band_lower}–#{state.band_upper} °C", CYAN],
           ["Scene", state.scene.to_s, GOLD],
           ["Rooms", Array(state.rooms).join(", "), MINT],
           ["Date", state.date.to_s, ROSE],
           ["Time", state.time.to_s, GOLD],
           ["Accent", state.accent.to_s, state.accent.to_s]].each do |label, value, tone|
            rectangle width: 170, height: 66, radius: 12, padding: 12, color: PANEL_ALT,
                      border_color: BORDER_SOFT, border_width: 1 do
              column spacing: 2, width: 146 do
                sc_eyebrow(label, color: FAINT)
                text value.to_s, size: 13, bold: true, color: tone, width: 146, wrap: false
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Showcase
  ROOMS = [
    { "key" => "kitchen", "label" => "Kitchen", "description" => "3 devices · 0.42 kW",
      "icon" => "house", "load" => 420, "state" => "On" },
    { "key" => "living", "label" => "Living room", "description" => "6 devices · 1.10 kW",
      "icon" => "image", "load" => 1100, "state" => "On" },
    { "key" => "studio", "label" => "Studio", "description" => "4 devices · 0.86 kW",
      "icon" => "music", "load" => 860, "state" => "Focus" },
    { "key" => "bedroom", "label" => "Bedroom", "description" => "2 devices · 0.08 kW",
      "icon" => "clock", "load" => 80, "state" => "Night" },
    { "key" => "garage", "label" => "Garage", "description" => "1 device · 7.20 kW",
      "icon" => "power", "load" => 7200, "state" => "Charging" }
  ].freeze

  DEVICE_ROWS = [
    { "device" => "Ceiling array", "room" => "Living room", "watts" => 148, "state" => "On" },
    { "device" => "Floor lamp", "room" => "Living room", "watts" => 32, "state" => "Dimmed" },
    { "device" => "Range hood", "room" => "Kitchen", "watts" => 210, "state" => "Auto" },
    { "device" => "Dishwasher", "room" => "Kitchen", "watts" => 1850, "state" => "Queued" },
    { "device" => "Studio monitors", "room" => "Studio", "watts" => 96, "state" => "On" },
    { "device" => "Desk lamp", "room" => "Studio", "watts" => 18, "state" => "On" },
    { "device" => "Heat pump", "room" => "Bedroom", "watts" => 640, "state" => "Eco" },
    { "device" => "Wall charger", "room" => "Garage", "watts" => 7200, "state" => "Charging" },
    { "device" => "Server rack", "room" => "Studio", "watts" => 310, "state" => "On" },
    { "device" => "Outdoor lights", "room" => "Garage", "watts" => 44, "state" => "Scheduled" }
  ].freeze

  TREE_ROWS = [
    { "name" => "Habitat One", "kind" => "home", "value" => "9.6 kW",
      "children" => [
        { "name" => "Ground floor", "kind" => "zone", "value" => "2.1 kW",
          "children" => [
            { "name" => "Kitchen", "kind" => "room", "value" => "0.42 kW" },
            { "name" => "Living room", "kind" => "room", "value" => "1.10 kW" }
          ] },
        { "name" => "First floor", "kind" => "zone", "value" => "0.9 kW",
          "children" => [
            { "name" => "Studio", "kind" => "room", "value" => "0.86 kW" },
            { "name" => "Bedroom", "kind" => "room", "value" => "0.08 kW" }
          ] },
        { "name" => "Outbuildings", "kind" => "zone", "value" => "7.2 kW",
          "children" => [{ "name" => "Garage", "kind" => "room", "value" => "7.20 kW" }] }
      ] }
  ].freeze

  module UI
    def sc_page_data
      sc_page do
        sc_row do
          sc_data_list
          sc_data_delegates
          sc_data_grid
        end
        sc_data_table_card
        sc_row do
          sc_data_tree
          sc_data_reorder
          sc_data_calendar
        end
        sc_row do
          sc_data_headers
          sc_data_dynamic
          sc_data_carousel
        end
      end
    end

    def sc_data_list
      sc_card("List view", "A model-backed native list", glyph: :folder, accent: CYAN,
              tags: %w[list_view list_model item_delegate]) do
        listing = list_view ROOMS, key_field: :key, label_field: :label,
                            description_field: :description, icon_field: :icon,
                            selected: "living", orientation: :vertical, spacing: 4,
                            width: CARD_BODY_W, height: 208, empty_text: "No rooms" do |event|
          transaction do
            state.room = event["value"].to_s
            state.activity = "Room → #{event["value"]}"
          end
        end
        bind(listing, :selected) { state.room.to_s }
        chosen = sc_kv("Selected", "living", accent: CYAN, key_width: 110)
        bind(chosen, :text) { state.room.to_s }
        sc_eyebrow("LIST_MODEL · the same rows as a model")
        list_model ROOMS, revision: 1
        sc_caption("list_model exposes the rows to other components without rendering them, " \
                   "which is how the proxy and delegate models are fed.", size: 10)
      end
    end

    def sc_data_delegates
      sc_card("Delegates", "Five row shapes the collections reuse", glyph: :check, accent: MINT,
              tags: %w[item_delegate check_delegate radio_delegate switch_delegate swipe_delegate]) do
        item_delegate "item_delegate", description: "text, icon, trailing text",
                      icon: :circle_info, trailing_text: "⌘1", width: CARD_BODY_W, height: 50,
                      radius: 10, padding: 10, spacing: 10, icon_size: 16, font_size: 12,
                      description_size: 10, background: PANEL_ALT, selected_background: TINT,
                      foreground: WHITE, selected_foreground: WHITE, muted: FAINT,
                      accent: MINT, border_color: BORDER_SOFT, border_width: 1 do
          sc_log("item_delegate activated")
        end
        check_delegate "check_delegate", description: "tristate capable", checked: true,
                       width: CARD_BODY_W, height: 50, radius: 10, padding: 10,
                       spacing: 10, indicator_size: 18, font_size: 12,
                       description_size: 10, background: PANEL_ALT,
                       selected_background: TINT, foreground: WHITE, muted: FAINT,
                       accent: CYAN, check_color: INK, border_color: BORDER_SOFT,
                       border_width: 1 do |event|
          sc_log("check_delegate #{event["value"] == false ? "cleared" : "set"}")
        end
        %w[Daily Weekly].each do |cadence|
          radio = radio_delegate "radio_delegate · #{cadence}", value: cadence, checked: false,
                                 width: CARD_BODY_W, height: 44, radius: 10, padding: 10,
                                 spacing: 10, indicator_size: 17, dot_size: 8, font_size: 12,
                                 background: PANEL_ALT, selected_background: TINT,
                                 foreground: WHITE, muted: FAINT, accent: VIOLET,
                                 border_color: BORDER_SOFT, border_width: 1 do
            state.cadence = cadence
          end
          bind(radio, :checked) { state.cadence.to_s == cadence }
        end
        switch_delegate "switch_delegate", description: "inline boolean", checked: true,
                        width: CARD_BODY_W, height: 50, radius: 10, padding: 10,
                        spacing: 10, indicator_width: 42, indicator_height: 20,
                        thumb_size: 16, font_size: 12, description_size: 10,
                        background: PANEL_ALT, foreground: WHITE, muted: FAINT,
                        accent: MINT, border_color: BORDER_SOFT, border_width: 1 do |event|
          sc_log("switch_delegate #{event["value"] == false ? "off" : "on"}")
        end
        swipe = swipe_delegate "swipe_delegate", description: "drag left or right",
                               icon: :chevron_right, left_action: "Archive", left_icon: :folder,
                               left_color: CYAN, right_action: "Delete", right_icon: :trash,
                               right_color: ROSE, action_width: 92, close_on_action: true,
                               width: CARD_BODY_W, height: 54, radius: 10, padding: 10,
                               spacing: 10, icon_size: 15, font_size: 12,
                               description_size: 10, background: PANEL_ALT, foreground: WHITE,
                               muted: FAINT, accent: GOLD, border_color: BORDER_SOFT,
                               border_width: 1
        on(swipe, :left_action) { sc_log("Row archived") }
        on(swipe, :right_action) { sc_log("Row deleted") }
      end
    end

    def sc_data_grid
      sc_card("Grid view", "Cells, selection and keyboard navigation", glyph: :menu,
              accent: VIOLET, tags: %w[grid_view responsive_view]) do
        grid = grid_view ROOMS, key_field: :key, label_field: :label,
                         description_field: :description, icon_field: :icon,
                         selected: "studio", cell_width: 150, cell_height: 96, spacing: 8,
                         padding: 4, width: CARD_BODY_W, height: 220, snap_mode: :snap_to_row,
                         key_navigation_wraps: true, interactive: true, clip: true,
                         background: PANEL, cell_background: PANEL_ALT,
                         selected_background: TINT, foreground: WHITE,
                         selected_foreground: VIOLET, muted: FAINT, accent: VIOLET,
                         border_color: BORDER_SOFT, radius: 12, font_size: 12,
                         description_size: 9, icon_size: 18,
                         empty_text: "No rooms" do |event|
          transaction do
            state.room = event["value"].to_s
            state.activity = "Grid → #{event["value"]}"
          end
        end
        bind(grid, :selected) { state.room.to_s }
        sc_caption("grid_view and list_view read the same array of hashes. Only the field map " \
                   "and the cell geometry differ.")
      end
    end

    def sc_data_table_card
      card width: FULL_W, padding: 18, spacing: 14, color: PANEL, border_color: BORDER,
           accent: CYAN do
        row spacing: 14 do
          sc_tile(:folder, accent: CYAN)
          column spacing: 2, width: 430 do
            text "Data table", size: 16, bold: true, color: WHITE, wrap: false
            sc_caption("data_table adds sorting, filtering and paging on top of table_view, " \
                       "and reports each change back to Ruby.", width: 430, size: 11)
          end
          filter = text_field "", placeholder: "Filter devices…", width: 240, height: 40,
                              foreground: WHITE, accent: CYAN, selection_tint: TINT,
                              horizontal_padding: 12 do |event|
            state.device_filter = event["value"].to_s
          end
          bind(filter, :text) { state.device_filter.to_s }
          spacer width: 90, height: 1
          shown = sc_stat("ROWS", DEVICE_ROWS.size, CYAN, width: 90)
          bind(shown, :text) { sc_device_rows.size.to_s }
          sc_stat("COLUMNS", 4, VIOLET, width: 90)
          total = sc_stat("TOTAL WATTS", "0", MINT, width: 130)
          bind(total, :text) { sc_device_rows.sum { |row| row["watts"].to_i }.to_s }
        end
        grid = data_table [], columns: [{ key: "device", label: "Device", width: 280 },
                                        { key: "room", label: "Room", width: 220 },
                                        { key: "watts", label: "Watts", width: 140,
                                          alignment: "right" },
                                        { key: "state", label: "State", width: 180 }],
                          width: FULL_W - 36, height: 268, row_height: 34, header_height: 38,
                          show_header: true, alternating_rows: true,
                          selection_behavior: :rows, selection_mode: :single,
                          sort_column: 2, sort_order: :descending, page: 1, page_size: 7,
                          background: PANEL, header_background: PANEL_DEEP,
                          cell_background: PANEL, alternate_background: PANEL_ALT,
                          selected_background: TINT, foreground: WHITE,
                          header_foreground: MUTED, selected_foreground: CYAN, muted: FAINT,
                          accent: CYAN, grid_color: BORDER_SOFT, border_color: BORDER,
                          radius: 12, font_size: 11, header_size: 10,
                          empty_text: "No device matches the filter"
        bind(grid, :rows) { sc_device_rows }
        on(grid, :sort) { |event| sc_log("Sorted by column #{event["column"] || event["value"]}") }
        on(grid, :page_change) { |event| sc_log("Page #{event["value"]}") }
        on(grid, :cell_click) do |event|
          row = event["row_data"]
          sc_log("#{row["device"]} · #{row["watts"]} W") if row.is_a?(Hash)
        end
      end
    end

    def sc_device_rows
      query = state.device_filter.to_s.strip.downcase
      return DEVICE_ROWS if query.empty?

      DEVICE_ROWS.select do |row|
        row["device"].downcase.include?(query) || row["room"].downcase.include?(query) ||
          row["state"].downcase.include?(query)
      end
    end

    def sc_data_tree
      sc_card("Tree view", "Hierarchy with expansion state in Ruby", glyph: :folder,
              accent: MINT, tags: %w[tree_view tree_view_delegate]) do
        tree = tree_view TREE_ROWS, columns: [{ key: "name", label: "Zone", width: 190 },
                                              { key: "value", label: "Load", width: 96,
                                                alignment: "right" }],
                         children_field: :children, expand_depth: 2, show_header: true,
                         header_height: 34, row_height: 30, indentation: 16,
                         width: CARD_BODY_W, height: 250, alternating_rows: false,
                         selection_behavior: :rows, background: PANEL,
                         header_background: PANEL_DEEP, cell_background: PANEL,
                         selected_background: TINT, foreground: WHITE,
                         header_foreground: MUTED, selected_foreground: MINT, muted: FAINT,
                         accent: MINT, grid_color: BORDER_SOFT, border_color: BORDER,
                         radius: 12, font_size: 11, header_size: 10 do |event|
          row = event["row_data"]
          sc_log("Tree → #{row["name"]}") if row.is_a?(Hash)
        end
        on(tree, :expand) { |event| sc_log("Expanded #{event["path"] || event["value"]}") }
        on(tree, :collapse) { |event| sc_log("Collapsed #{event["path"] || event["value"]}") }
      end
    end

    def sc_data_reorder
      sc_card("Reorderable list", "Drag rows, keep the order in Ruby", glyph: :arrow_up,
              accent: GOLD, tags: %w[reorderable_list]) do
        order = reorderable_list [], key_field: :key, label_field: :label,
                                 description_field: :description, orientation: :vertical,
                                 spacing: 6, padding: 4, item_padding: 10, item_height: 54,
                                 width: CARD_BODY_W, height: 240, handle_position: :right,
                                 drag_enabled: true, drag_scale: 1.03, drag_opacity: 0.9,
                                 drag_transition_duration: 180, background: PANEL,
                                 item_background: PANEL_ALT, selected_background: TINT,
                                 foreground: WHITE, selected_foreground: GOLD, muted: FAINT,
                                 border_color: BORDER_SOFT, radius: 10, font_size: 12,
                                 empty_text: "Nothing to order"
        bind(order, :items) { sc_ordered_rooms }
        on(order, :reorder) do |event|
          keys = Array(event["keys"] || event["value"]).map(&:to_s)
          next if keys.empty?

          transaction do
            state.room_order = keys
            state.activity = "Reordered to #{keys.first}"
          end
        end
        on(order, :activate) { |event| sc_log("Row #{event["value"]}") }
      end
    end

    def sc_ordered_rooms
      order = Array(state.room_order)
      return ROOMS if order.empty?

      order.map { |key| ROOMS.find { |room| room["key"] == key } }.compact
    end

    def sc_data_calendar
      sc_card("Calendars", "A full calendar and its three parts", glyph: :calendar,
              accent: ROSE, tags: %w[calendar calendar_model month_grid day_of_week_row week_number_column]) do
        picker = calendar "2026-11-17", month: 11, year: 2026, show_week_numbers: true,
                          show_navigation: true, width: CARD_BODY_W, height: 236,
                          background: PANEL_ALT, header_background: PANEL_DEEP,
                          selected_background: ROSE, today_background: TINT, foreground: WHITE,
                          muted: FAINT, accent: ROSE, border_color: BORDER_SOFT, radius: 12,
                          font_size: 11
        bind(picker, :date) { state.date.to_s }
        on(picker, :change) do |event|
          transaction do
            state.date = event["value"].to_s
            state.activity = "Date → #{event["value"]}"
          end
        end
        on(picker, :navigate) { |event| sc_log("Calendar → #{event["month"]}/#{event["year"]}") }
        calendar_model from: "2026-01-01", to: "2026-12-31"
        sc_eyebrow("DAY_OF_WEEK_ROW · WEEK_NUMBER_COLUMN · MONTH_GRID")
        row spacing: 8 do
          week_number_column month: 11, year: 2026, width: 34, height: 150,
                             background: PANEL_ALT, foreground: MUTED, muted: FAINT,
                             font_size: 10
          column spacing: 4, width: CARD_BODY_W - 46 do
            day_of_week_row width: CARD_BODY_W - 46, height: 24, background: PANEL_ALT,
                            foreground: MUTED, muted: FAINT, font_size: 10
            month_grid month: 11, year: 2026, selected_date: "2026-11-17",
                       width: CARD_BODY_W - 46, height: 122, background: PANEL_ALT,
                       selected_background: ROSE, today_background: TINT, foreground: WHITE,
                       muted: FAINT, accent: ROSE, font_size: 10
          end
        end
      end
    end

    def sc_data_headers
      sc_card("Headers and cell delegates", "The pieces a table is assembled from",
              glyph: :menu, accent: CYAN,
              tags: %w[horizontal_header vertical_header table_view_delegate
                       horizontal_header_delegate vertical_header_delegate]) do
        sc_eyebrow("HORIZONTAL_HEADER")
        header = horizontal_header %w[Device Room Watts], current_index: 2, section_width: 104,
                                  height: 34, spacing: 1, movable: true, clickable: true,
                                  sort_index: 2, sort_order: :descending,
                                  background: PANEL_DEEP, selected_background: TINT,
                                  foreground: MUTED, selected_foreground: CYAN,
                                  border_color: BORDER_SOFT, font_size: 10
        on(header, :sort) { |event| sc_log("Header sort #{event["index"] || event["value"]}") }
        on(header, :click) { |event| sc_log("Header #{event["index"] || event["value"]}") }
        sc_eyebrow("VERTICAL_HEADER + TABLE_VIEW_DELEGATE")
        row spacing: 6 do
          vertical_header %w[1 2 3 4], current_index: 0, width: 32, section_height: 32,
                          spacing: 1, clickable: true, background: PANEL_DEEP,
                          selected_background: TINT, foreground: MUTED,
                          selected_foreground: CYAN, border_color: BORDER_SOFT, font_size: 10
          column spacing: 1, width: CARD_BODY_W - 40 do
            [["Ceiling array", false], ["Floor lamp", true], ["Range hood", false],
             ["Dishwasher", false]].each_with_index do |(label, selected), index|
              table_view_delegate label, value: label, row: index, column: 0,
                                  selected: selected, width: CARD_BODY_W - 40, height: 32,
                                  background: PANEL_ALT, selected_background: TINT,
                                  foreground: WHITE, selected_foreground: CYAN,
                                  border_color: BORDER_SOFT, font_size: 11
            end
          end
        end
        sc_eyebrow("HEADER DELEGATES")
        row spacing: 6 do
          horizontal_header_delegate "Watts", value: "watts", index: 2, selected: true,
                                     sort_order: :descending, width: 150, height: 32,
                                     background: PANEL_DEEP, selected_background: TINT,
                                     foreground: MUTED, selected_foreground: CYAN,
                                     border_color: BORDER_SOFT, font_size: 10
          vertical_header_delegate "7", value: 7, index: 6, selected: false, width: 60,
                                   height: 32, background: PANEL_DEEP,
                                   selected_background: TINT, foreground: MUTED,
                                   selected_foreground: CYAN, border_color: BORDER_SOFT,
                                   font_size: 10
          tree_view_delegate "Studio", value: "studio", row: 3, column: 0, depth: 2,
                             expanded: true, has_children: true, width: 120, height: 32,
                             indentation: 14, background: PANEL_ALT,
                             selected_background: TINT, foreground: WHITE,
                             selected_foreground: MINT, border_color: BORDER_SOFT,
                             font_size: 11
        end
      end
    end

    def sc_data_dynamic
      sc_card("Dynamic structure", "Children rebuilt from state, not just properties",
              glyph: :refresh, accent: VIOLET, tags: %w[dynamic column rectangle]) do
        sc_caption("`dynamic` re-runs its block whenever state changes and reconciles the " \
                   "children it produced. Everything below appears and disappears with the " \
                   "slider — no component is hidden, they are not declared at all.")
        count = slider 4, minimum: 1, maximum: 8, step: 1, integer: true,
                       track_color: PANEL_ALT, fill_color: VIOLET, knob_color: WHITE,
                       track_height: 6, knob_size: 18, ticks: 8, tick_color: BORDER do |event|
          state.dynamic_count = event["value"].to_i
        end
        bind(count, :value) { state.dynamic_count.to_i }
        dynamic type: :column, spacing: 6, width: CARD_BODY_W do
          total = state.dynamic_count.to_i
          total.times do |index|
            tone = ACCENTS[index % ACCENTS.size]
            rectangle width: CARD_BODY_W, height: 32, radius: 8, color: PANEL_ALT,
                      border_color: tone, border_width: 1 do
              text "row #{index + 1} of #{total}", size: 11, color: tone, wrap: false
            end
          end
        end
      end
    end

    def sc_data_carousel
      sc_card("Carousel", "A path view over image-backed items", glyph: :image, accent: GOLD,
              tags: %w[carousel image grid_view]) do
        wheel = carousel sc_drink_items, key_field: :key, label_field: :label,
                         description_field: :description, image_field: :image,
                         current_index: 2, path_radius: 120, item_width: 118, item_height: 152,
                         width: CARD_BODY_W, height: 196, interactive: true,
                         highlight_range: :strict, snap_mode: :snap_one_item,
                         background: PANEL, foreground: WHITE, muted: FAINT, accent: GOLD,
                         font_size: 11
        on(wheel, :change) do |event|
          transaction do
            state.drink_index = event["value"].to_i
            item = sc_drink_items[event["value"].to_i]
            state.activity = "Carousel → #{item ? item["label"] : "item"}"
          end
        end
        on(wheel, :activate) { |event| sc_log("Opened #{event["value"]}") }
        chosen = sc_kv("Showing", "—", accent: GOLD, key_width: 100)
        bind(chosen, :text) do
          item = sc_drink_items[state.drink_index.to_i]
          item ? item["label"].to_s : "—"
        end
      end
    end

    def sc_drink_items
      DRINK_IMAGES.each_with_index.map do |(path, name), index|
        { "key" => "drink-#{index}", "label" => name.split.map(&:capitalize).join(" "),
          "description" => "nova_pour asset", "image" => path }
      end
    end
  end
end

# frozen_string_literal: true

module Showcase
  # The catalog is driven by the framework's own registry, never by a hand
  # written list, so it can never drift from the Zui version it runs against.
  SCHEMA = Zui::DEFAULT_COMPONENTS.protocol_schema.freeze
  REGISTRY_COUNT = SCHEMA.size
  COMPONENT_NAMES = SCHEMA.keys.sort.freeze

  CATEGORY_OF = COMPONENT_CATEGORIES.each_with_object({}) do |(category, names), result|
    names.each { |name| result[name] = category }
  end.freeze

  ALL_CATEGORIES = "All categories"
  CATEGORY_OPTIONS = ([ALL_CATEGORIES] + CATEGORY_ORDER).freeze

  REGISTRY_ROWS = COMPONENT_NAMES.map do |name|
    definition = SCHEMA.fetch(name)
    {
      "component" => name,
      "category" => CATEGORY_OF.fetch(name, "Uncategorized"),
      "properties" => definition.fetch("properties").size,
      "events" => definition.fetch("events").size,
      "container" => definition.fetch("container") ? "container" : "leaf"
    }
  end.freeze

  CATEGORY_COUNTS = CATEGORY_ORDER.map do |category|
    [category, REGISTRY_ROWS.count { |row| row["category"] == category }]
  end.freeze

  TOTAL_PROPERTIES = REGISTRY_ROWS.sum { |row| row["properties"] }
  TOTAL_EVENTS = REGISTRY_ROWS.sum { |row| row["events"] }

  CATALOG_COLUMNS = [
    { key: "component", label: "Component", width: 180 },
    { key: "category", label: "Category", width: 196 },
    { key: "properties", label: "Props", width: 70, alignment: "right" },
    { key: "events", label: "Events", width: 70, alignment: "right" },
    { key: "container", label: "Shape", width: 92 },
    { key: "live", label: "On screen", width: 92 }
  ].freeze

  module UI
    def sc_catalog_rows
      return [] unless state.catalog_ready == true

      query = state.catalog_query.to_s.strip.downcase
      category = state.catalog_category.to_s
      live = state.live_types
      rows = REGISTRY_ROWS
      rows = rows.select { |row| row["category"] == category } unless category.empty? ||
                                                                     category == ALL_CATEGORIES
      unless query.empty?
        rows = rows.select do |row|
          row["component"].include?(query) || row["category"].downcase.include?(query)
        end
      end
      rows.map { |row| row.merge("live" => live.include?(row["component"]) ? "yes" : "·") }
    end

    # The table shows one page at a time: 306 rows in a single property value
    # would exceed the client's collection ceiling and the patch carrying the
    # whole page would be rejected.
    def sc_catalog_page_count
      [(sc_catalog_rows.size + CATALOG_PAGE_SIZE - 1) / CATALOG_PAGE_SIZE, 1].max
    end

    def sc_catalog_offset
      page = state.catalog_page.to_i
      page = sc_catalog_page_count - 1 if page >= sc_catalog_page_count
      [page, 0].max * CATALOG_PAGE_SIZE
    end

    def sc_catalog_visible_rows
      sc_catalog_rows.slice(sc_catalog_offset, CATALOG_PAGE_SIZE) || []
    end

    def sc_catalog_range_text
      total = sc_catalog_rows.size
      return "No component matches" if total.zero?

      first = sc_catalog_offset + 1
      last = [sc_catalog_offset + CATALOG_PAGE_SIZE, total].min
      "Showing #{first}-#{last} of #{total}"
    end

    def sc_catalog_pager
      row spacing: 10, alignment: :center do
        previous = button "Previous", width: 108, height: 32, font_size: 11,
                          background: PANEL_ALT, foreground: WHITE, accent: CYAN do
          state.catalog_page = [state.catalog_page.to_i - 1, 0].max
        end
        bind(previous, :enabled) { state.catalog_page.to_i.positive? }
        nxt = button "Next", width: 108, height: 32, font_size: 11,
                     background: PANEL_ALT, foreground: WHITE, accent: CYAN do
          state.catalog_page = [state.catalog_page.to_i + 1, sc_catalog_page_count - 1].min
        end
        bind(nxt, :enabled) { state.catalog_page.to_i < sc_catalog_page_count - 1 }
        range = sc_caption(sc_catalog_range_text, width: 420, size: 11)
        bind(range, :text) { sc_catalog_range_text }
      end
    end

    def sc_page_catalog
      sc_page do
        sc_catalog_controls
        sc_row do
          sc_catalog_table
          sc_catalog_detail
        end
        sc_catalog_breakdown
      end
    end

    def sc_catalog_controls
      card width: FULL_W, padding: 18, spacing: 14, color: PANEL, border_color: BORDER do
        row spacing: 14 do
          column spacing: 2, width: 300 do
            text "Live component registry", size: 16, bold: true, color: WHITE, wrap: false
            sc_caption("Filter #{REGISTRY_COUNT} registered components by name or category.",
                       width: 300, size: 11)
          end
          field = search_field "", suggestions: [], live: true, width: 300,
                               height: 44, foreground: WHITE, background: PANEL_ALT,
                               accent: CYAN, font_size: 12
          bind(field, :suggestions) do
            state.catalog_ready == true ? COMPONENT_NAMES.first(MAX_COLLECTION_ITEMS) : []
          end
          on(field, :input) do |event|
            transaction do
              state.catalog_query = event["value"].to_s
              state.catalog_page = 0
            end
          end
          on(field, :clear) do
            transaction do
              state.catalog_query = ""
              state.catalog_page = 0
            end
          end
          picker = dropdown ALL_CATEGORIES, label: "Category", options: CATEGORY_OPTIONS,
                            show_label: false, foreground: WHITE, background: PANEL_ALT,
                            popup_border: BORDER, accent: CYAN, row_height: 40,
                            popup_row_height: 34 do |event|
            transaction do
              state.catalog_category = event["value"].to_s
              state.catalog_page = 0
            end
          end
          bind(picker, :value) { state.catalog_category.to_s }
          counter = sc_stat("MATCHING", REGISTRY_COUNT, CYAN, width: 110)
          bind(counter, :text) { sc_catalog_rows.size.to_s }
          sc_stat("PROPERTIES", TOTAL_PROPERTIES, VIOLET, width: 110)
          sc_stat("EVENTS", TOTAL_EVENTS, MINT, width: 100)
        end
      end
    end

    def sc_catalog_table
      card width: 712, padding: 14, spacing: 10, color: PANEL, border_color: BORDER do
        table = table_view [], columns: CATALOG_COLUMNS, width: 684, height: 512,
                           row_height: 32, header_height: 36, show_header: true,
                           alternating_rows: true, selection_behavior: :rows,
                           selection_mode: :single, background: PANEL,
                           header_background: PANEL_DEEP, cell_background: PANEL,
                           alternate_background: PANEL_ALT, selected_background: TINT,
                           foreground: WHITE, header_foreground: MUTED,
                           selected_foreground: CYAN, muted: FAINT, accent: CYAN,
                           grid_color: BORDER_SOFT, border_color: BORDER, radius: 12,
                           font_size: 11, header_size: 10, empty_text: "No component matches"
        bind(table, :rows) { sc_catalog_visible_rows }
        sc_catalog_pager
        on(table, :cell_click) do |event|
          row = event["row_data"]
          next unless row.is_a?(Hash)

          transaction do
            state.catalog_selected = row["component"].to_s
            state.activity = "Inspecting #{row["component"]}"
          end
        end
      end
    end

    def sc_catalog_detail
      card width: 372, padding: 18, spacing: 12, color: PANEL, border_color: BORDER,
           accent: VIOLET do
        sc_head(:code, "Schema", "Click any row to inspect its contract", accent: VIOLET,
                width: 336)
        dynamic type: :column, spacing: 12, width: 336 do
          name = state.catalog_selected.to_s
          definition = SCHEMA[name]
          if definition.nil?
            sc_panel(width: 336) do
              sc_caption("Select a component in the table to read its registered properties, " \
                         "events and native QML adapter.", width: 300)
            end
          else
            sc_panel(width: 336) do
              row spacing: 8 do
                text name, size: 17, bold: true, color: WHITE, wrap: false
                chip definition["container"] ? "container" : "leaf", height: 22, font_size: 9,
                     radius: 7, horizontal_padding: 8, background: PANEL_DEEP,
                     selected_background: PANEL_DEEP, foreground: VIOLET,
                     selected_foreground: VIOLET, accent: VIOLET
              end
              sc_kv("Category", CATEGORY_OF.fetch(name, "Uncategorized"), accent: MUTED,
                    key_width: 80, width: 300)
              sc_kv("QML adapter", definition["qml"], accent: CYAN, key_width: 80, width: 300)
              sc_kv("Reactive bind", definition["auto_bind"] ? "automatic" : "manual",
                    accent: MINT, key_width: 80, width: 300)
            end
            sc_eyebrow("PROPERTIES · #{definition["properties"].size}")
            sc_tags(definition["properties"], width: 336)
            sc_eyebrow("EVENTS · #{definition["events"].size}")
            if definition["events"].empty?
              sc_caption("This component declares no events.", width: 336, size: 10)
            else
              sc_tags(definition["events"], width: 336)
            end
          end
        end
      end
    end

    def sc_catalog_breakdown
      card width: FULL_W, padding: 18, spacing: 14, color: PANEL, border_color: BORDER do
        sc_head(:menu, "Catalog by category",
                "Counts come from the registry at startup, not from documentation.",
                accent: CYAN, width: FULL_W - 36)
        wrap width: FULL_W - 36, spacing: 10 do
          CATEGORY_COUNTS.each_with_index do |(category, count), index|
            accent = ACCENTS[index % ACCENTS.size]
            rectangle width: 206, height: 74, radius: 12, padding: 12, color: PANEL_ALT,
                      border_color: BORDER_SOFT, border_width: 1 do
              column spacing: 4, width: 182 do
                row spacing: 8 do
                  text count.to_s, size: 20, bold: true, color: accent, wrap: false
                  text "components", size: 10, color: FAINT, wrap: false
                end
                text category, size: 11, color: MUTED, width: 182, wrap: true
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Showcase
  CHART_W = CARD_BODY_W
  CHART_H = 150
  # head + chart + a caption line + tags, with nothing left over.
  CHART_CARD_H = 348

  module UI
    def sc_page_charts
      sc_page do
        sc_charts_intro
        sc_row height: CHART_CARD_H do
          sc_chart_line
          sc_chart_area
          sc_chart_spark
        end
        sc_row height: CHART_CARD_H do
          sc_chart_bar
          sc_chart_stacked
          sc_chart_histogram
        end
        sc_row height: CHART_CARD_H do
          sc_chart_pie
          sc_chart_donut
          sc_chart_radar
        end
        sc_row height: CHART_CARD_H do
          sc_chart_scatter
          sc_chart_bubble
          sc_chart_heatmap
        end
        sc_row height: CHART_CARD_H do
          sc_chart_gauge
          sc_chart_radial
          sc_chart_candles
        end
      end
    end

    def sc_charts_intro
      card width: FULL_W, padding: 18, spacing: 12, color: PANEL, border_color: BORDER,
           accent: MINT do
        row spacing: 14 do
          sc_tile(:star, accent: MINT)
          column spacing: 2, width: 470 do
            text "Sixteen native charts", size: 16, bold: true, color: WHITE, wrap: false
            sc_caption("Every chart is drawn by the native renderer from plain Ruby arrays. " \
                       "The ones marked live re-read the same scheduler tick as the overview.",
                       width: 470, size: 11)
          end
          spacer width: 80, height: 1
          legend [{ "label" => "Throughput", "color" => MINT },
                  { "label" => "Latency", "color" => CYAN },
                  { "label" => "Errors", "color" => ROSE },
                  { "label" => "Saturation", "color" => VIOLET }],
                 orientation: :horizontal, spacing: 16, marker_size: 10, interactive: true,
                 width: 420, height: 34, background: PANEL, foreground: WHITE, muted: FAINT,
                 font_size: 11
          sc_stat("SERIES", 4, MINT, width: 90)
        end
      end
    end

    def sc_chart_line
      sc_card("line_chart", "Live · points, grid and bounds", glyph: :wifi, accent: MINT,
              tags: %w[line_chart]) do
        chart = line_chart [], labels: [], width: CHART_W, height: CHART_H, color: MINT,
                           fill_color: "#12352a", grid_color: BORDER_SOFT, line_width: 2,
                           minimum: 0, maximum: 100, show_grid: true, show_points: true,
                           point_size: 3
        bind(chart, :values) { state.pulse }
        on(chart, :select) { |event| sc_log("line_chart point #{event["index"]}") }
        sc_kv("Window", "16 samples · 1s tick", accent: MUTED, key_width: 110)
      end
    end

    def sc_chart_area
      sc_card("area_chart", "Live · filled band under the line", glyph: :arrow_up,
              accent: CYAN, tags: %w[area_chart]) do
        chart = area_chart [], width: CHART_W, height: CHART_H, color: CYAN,
                           fill_color: "#11314a", grid_color: BORDER_SOFT, line_width: 2,
                           minimum: 0, maximum: 60, show_grid: true
        bind(chart, :values) { state.latency }
        readout = sc_kv("Latency", "0 ms", accent: CYAN, key_width: 110)
        bind(readout, :text) { "#{state.latency.last.to_f.round(1)} ms" }
      end
    end

    def sc_chart_spark
      sc_card("sparkline", "Live · no axes, no grid", glyph: :check, accent: VIOLET,
              tags: %w[sparkline progress]) do
        [[MINT, :pulse], [CYAN, :latency], [VIOLET, :pulse]].each_with_index do |(tone, key), index|
          column spacing: 4, width: CHART_W do
            sc_eyebrow(["THROUGHPUT", "LATENCY", "SMOOTHED"][index], color: FAINT)
            spark = sparkline [], width: CHART_W, height: 40, color: tone,
                              fill_color: "transparent", line_width: 2, show_points: false
            bind(spark, :values) do
              values = state.public_send(key)
              index == 2 ? values.each_slice(2).map { |pair| pair.sum / pair.size.to_f } : values
            end
          end
        end
      end
    end

    def sc_chart_bar
      sc_card("bar_chart", "Per-room load, one colour each", glyph: :menu, accent: GOLD,
              tags: %w[bar_chart]) do
        bar_chart ROOMS.map { |room| room["load"].to_i },
                  labels: ROOMS.map { |room| room["label"].to_s.split.first },
                  width: CHART_W, height: CHART_H, colors: ACCENTS.first(5),
                  grid_color: BORDER_SOFT, minimum: 0, maximum: 7500, show_grid: true,
                  bar_spacing: 10
        sc_kv("Peak", "garage · 7.2 kW", accent: GOLD, key_width: 110)
      end
    end

    def sc_chart_stacked
      sc_card("stacked_bar_chart", "Three series, one stack", glyph: :folder, accent: MINT,
              tags: %w[stacked_bar_chart legend]) do
        stacked_bar_chart [[2.1, 2.4, 2.2, 2.8, 3.1, 2.9, 3.4],
                           [1.2, 1.1, 1.4, 1.3, 1.6, 1.5, 1.7],
                           [0.4, 0.6, 0.5, 0.7, 0.6, 0.8, 0.9]],
                          labels: %w[Mon Tue Wed Thu Fri Sat Sun],
                          colors: [MINT, CYAN, VIOLET], width: CHART_W, height: CHART_H,
                          grid_color: BORDER_SOFT, minimum: 0, show_grid: true,
                          bar_spacing: 8, stack_spacing: 1, orientation: :vertical
        legend [{ "label" => "Solar", "color" => MINT },
                { "label" => "Battery", "color" => CYAN },
                { "label" => "Grid", "color" => VIOLET }],
               orientation: :horizontal, spacing: 12, marker_size: 9, width: CHART_W,
               background: PANEL, foreground: WHITE, muted: FAINT, font_size: 10
      end
    end

    def sc_chart_histogram
      sc_card("histogram", "Binned distribution", glyph: :menu, accent: CYAN,
              tags: %w[histogram]) do
        histogram [12, 14, 15, 15, 16, 18, 18, 19, 19, 19, 20, 21, 21, 22, 24, 25, 25, 27, 30,
                   31, 33, 34, 36, 41],
                  bins: 8, width: CHART_W, height: CHART_H, color: CYAN,
                  grid_color: BORDER_SOFT, show_grid: true, bar_spacing: 3, normalize: false,
                  cumulative: false
        sc_kv("Bins", "8 · 24 samples", accent: CYAN, key_width: 110)
      end
    end

    def sc_chart_pie
      sc_card("pie_chart", "Share of total load", glyph: :circle_info, accent: VIOLET,
              tags: %w[pie_chart]) do
        pie_chart ROOMS.map { |room| room["load"].to_i },
                  labels: ROOMS.map { |room| room["label"].to_s.split.first },
                  colors: ACCENTS.first(5), width: CHART_W, height: CHART_H,
                  start_angle: -90, clockwise: true, pad_angle: 1, show_labels: true,
                  label_color: WHITE, font_size: 10
      end
    end

    def sc_chart_donut
      sc_card("donut_chart", "Inner radius and a centre label", glyph: :refresh, accent: MINT,
              tags: %w[donut_chart]) do
        ring = donut_chart [62, 24, 14], labels: %w[Solar Battery Grid],
                           colors: [MINT, CYAN, VIOLET], width: CHART_W, height: CHART_H,
                           inner_radius: 0.62, start_angle: -90, clockwise: true, pad_angle: 2,
                           show_labels: true, center_text: "62%", label_color: WHITE,
                           font_size: 10
        bind(ring, :center_text) { "#{state.brightness.to_i}%" }
        sc_caption("The centre text is bound to the brightness slider on the Inputs page.",
                   size: 10)
      end
    end

    def sc_chart_radar
      sc_card("radar_chart", "Two profiles across six axes", glyph: :star, accent: ROSE,
              tags: %w[radar_chart]) do
        radar_chart [[82, 74, 61, 88, 70, 79], [58, 86, 72, 54, 91, 63]],
                    labels: %w[CPU GPU Disk Net Audio Input],
                    colors: [ROSE, CYAN], width: CHART_W, height: CHART_H + 10,
                    grid_color: BORDER_SOFT, levels: 4, fill_opacity: 0.22, line_width: 2,
                    point_size: 3
      end
    end

    def sc_chart_scatter
      sc_card("scatter_chart", "Two series of x/y points", glyph: :plus, accent: GOLD,
              tags: %w[scatter_chart]) do
        scatter_chart [], series: [[[1, 12], [2, 18], [3, 16], [4, 24], [5, 22], [6, 31]],
                                   [[1, 6], [2, 9], [3, 14], [4, 11], [5, 17], [6, 15]]],
                      colors: [GOLD, VIOLET], width: CHART_W, height: CHART_H,
                      grid_color: BORDER_SOFT, minimum_x: 0, maximum_x: 7, minimum_y: 0,
                      maximum_y: 36, point_size: 6, show_grid: true, connect_lines: false
        sc_kv("Points", "12 across 2 series", accent: GOLD, key_width: 110)
      end
    end

    def sc_chart_bubble
      sc_card("bubble_chart", "x, y and a third dimension", glyph: :circle_info, accent: CYAN,
              tags: %w[bubble_chart]) do
        bubble_chart [[1, 14, 3], [2, 22, 9], [3, 18, 5], [4, 29, 14], [5, 24, 7],
                      [6, 33, 18]],
                     colors: [CYAN], width: CHART_W, height: CHART_H,
                     grid_color: BORDER_SOFT, minimum_x: 0, maximum_x: 7, minimum_y: 0,
                     maximum_y: 40, minimum_size: 6, maximum_size: 26, show_grid: true
        sc_kv("Encoding", "size = concurrency", accent: CYAN, key_width: 110)
      end
    end

    def sc_chart_heatmap
      sc_card("heatmap", "A matrix with labelled axes", glyph: :image, accent: VIOLET,
              tags: %w[heatmap]) do
        heatmap [[12, 18, 24, 31, 28, 19, 14],
                 [16, 22, 29, 38, 33, 24, 17],
                 [21, 28, 36, 47, 41, 30, 22],
                 [14, 19, 26, 34, 29, 21, 15]],
                x_labels: %w[Mon Tue Wed Thu Fri Sat Sun],
                y_labels: %w[00h 06h 12h 18h], colors: [PANEL_DEEP, VIOLET, MINT],
                width: CHART_W, height: CHART_H, cell_spacing: 2, show_values: false,
                value_color: WHITE, font_size: 9
        sc_kv("Cells", "28 · 4 x 7", accent: VIOLET, key_width: 110)
      end
    end

    def sc_chart_gauge
      sc_card("gauge", "Live · a linear arc with a label", glyph: :power, accent: MINT,
              tags: %w[gauge]) do
        meter = gauge 0, minimum: 0, maximum: 100, width: CHART_W, height: CHART_H,
                      color: MINT, track_color: PANEL_ALT, thickness: 16, label: "THROUGHPUT",
                      label_format: "%{value}", show_label: true, font_size: 13
        bind(meter, :value) { state.pulse.last.to_f }
      end
    end

    def sc_chart_radial
      sc_card("radial_gauge", "Live · start and end angles", glyph: :refresh, accent: CYAN,
              tags: %w[radial_gauge progress_ring]) do
        dialled = radial_gauge 0, minimum: 0, maximum: 60, width: CHART_W, height: CHART_H,
                               color: CYAN, track_color: PANEL_ALT, thickness: 14,
                               start_angle: -210, end_angle: 30, label: "LATENCY",
                               label_format: "%{value} ms", show_label: true, font_size: 13
        bind(dialled, :value) { state.latency.last.to_f }
      end
    end

    def sc_chart_candles
      sc_card("candlestick_chart", "Open, high, low, close", glyph: :star, accent: GOLD,
              tags: %w[candlestick_chart]) do
        candlestick_chart [{ "open" => 184.2, "high" => 188.9, "low" => 183.1, "close" => 187.6 },
                           { "open" => 187.6, "high" => 191.2, "low" => 186.0, "close" => 189.8 },
                           { "open" => 189.8, "high" => 190.4, "low" => 184.7, "close" => 185.3 },
                           { "open" => 185.3, "high" => 187.1, "low" => 181.9, "close" => 182.4 },
                           { "open" => 182.4, "high" => 186.8, "low" => 182.0, "close" => 186.1 },
                           { "open" => 186.1, "high" => 192.5, "low" => 185.8, "close" => 191.9 },
                           { "open" => 191.9, "high" => 194.0, "low" => 189.4, "close" => 190.2 }],
                          labels: %w[Mon Tue Wed Thu Fri Sat Sun], width: CHART_W,
                          height: CHART_H, up_color: MINT, down_color: ROSE, wick_color: FAINT,
                          grid_color: BORDER_SOFT, show_grid: true, candle_spacing: 6
        sc_kv("Close", "190.20", accent: GOLD, key_width: 110)
      end
    end
  end
end

# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_drawing
      sc_page do
        sc_row do
          sc_draw_canvas
          sc_draw_shapes
          sc_draw_gradients
        end
        sc_row do
          sc_draw_shader
          sc_draw_particles
          sc_draw_pointer
        end
        sc_row do
          sc_draw_gestures
          sc_draw_devices
          sc_draw_scrollers
        end
      end
    end

    # ----------------------------------------------------------------- canvas
    def sc_canvas_commands
      values = state.pulse
      width = CARD_BODY_W
      height = 160
      top = 14
      usable = height - top - 18
      step = (width - 24) / [values.size - 1, 1].max
      points = values.each_with_index.map do |value, index|
        [12 + index * step, top + usable * (1 - value.to_f / 100.0)]
      end
      commands = [
        { "op" => "fill_rect", "fill_style" => PANEL_DEEP, "x" => 0, "y" => 0,
          "width" => width, "height" => height },
        { "op" => "begin_path", "stroke_style" => BORDER_SOFT, "line_width" => 1 }
      ]
      4.times do |index|
        y = top + usable * index / 3.0
        commands << { "op" => "move_to", "x" => 12, "y" => y }
        commands << { "op" => "line_to", "x" => width - 12, "y" => y }
      end
      commands << { "op" => "stroke" }
      commands << { "op" => "begin_path", "stroke_style" => CYAN, "line_width" => 2.5,
                    "line_join" => "round", "line_cap" => "round" }
      points.each_with_index do |(x, y), index|
        commands << { "op" => index.zero? ? "move_to" : "line_to", "x" => x, "y" => y }
      end
      commands << { "op" => "stroke" }
      last = points.last
      commands << { "op" => "begin_path", "fill_style" => WHITE }
      commands << { "op" => "arc", "x" => last[0], "y" => last[1], "radius" => 4,
                    "start_angle" => 0, "end_angle" => 6.2832 }
      commands << { "op" => "fill" }
      commands << { "op" => "fill_text", "fill_style" => MUTED, "font" => "11px sans-serif",
                    "text" => "#{values.last.to_i} req/s", "x" => 14, "y" => height - 6 }
      commands
    end

    def sc_draw_canvas
      sc_card("Canvas", "Live · a retained 2D scene drawn from Ruby", glyph: :code,
              accent: CYAN, tags: %w[canvas]) do
        scene = canvas [], width: CARD_BODY_W, height: 160, antialiasing: true, smooth: true,
                       render_target: :image, render_strategy: :immediate,
                       background: "transparent"
        bind(scene, :commands) { sc_canvas_commands }
        on(scene, :click) { |event| sc_log("canvas click at #{event["x"].to_i},#{event["y"].to_i}") }
        on(scene, :error) { |event| sc_log("canvas error: #{event["message"]}") }
        sc_caption("The command list is an ordinary array of hashes rebuilt on every tick. " \
                   "Zui diffs it and the renderer repaints once.")
      end
    end

    # ----------------------------------------------------------------- shapes
    def sc_draw_shapes
      sc_card("Shapes and paths", "GPU-accelerated vector geometry", glyph: :edit,
              accent: VIOLET, tags: %w[shape path line circle]) do
        sc_eyebrow("SHAPE · SVG path data")
        shape "M 0,60 C 60,0 120,120 180,40 S 260,0 320,60", width: CARD_BODY_W, height: 110,
              stroke: VIOLET, fill: "transparent", stroke_width: 3, cap: :round, join: :round,
              antialiasing: true
        sc_eyebrow("PATH · dashed")
        path "M 0,20 L 80,20 L 120,60 L 200,60 L 240,20 L 316,20", width: CARD_BODY_W,
             height: 80, stroke: CYAN, fill: "transparent", stroke_width: 2,
             dash_pattern: [6, 4], dash_offset: 0, cap: :flat, antialiasing: true
        sc_eyebrow("LINE · CIRCLE · arcs")
        row spacing: 10 do
          line 0, 0, 120, 60, width: 130, height: 70, stroke: MINT, stroke_width: 3,
               cap: :round
          circle 32, center_x: 36, center_y: 36, width: 76, height: 76, stroke: GOLD,
                 fill: "#2a230f", stroke_width: 3
          circle 30, center_x: 34, center_y: 34, start_angle: -90, sweep_angle: 240,
                 width: 72, height: 72, stroke: ROSE, fill: "transparent", stroke_width: 6,
                 cap: :round
        end
      end
    end

    def sc_draw_gradients
      sc_card("Gradients", "Linear, radial and conical fills", glyph: :image, accent: GOLD,
              tags: %w[gradient shape]) do
        sc_eyebrow("LINEAR")
        gradient [CYAN, VIOLET, ROSE], type: :linear, width: CARD_BODY_W, height: 54,
                 start_x: 0, start_y: 0, end_x: CARD_BODY_W, end_y: 0, radius: 12
        sc_eyebrow("RADIAL")
        gradient [MINT, PANEL_DEEP], type: :radial, width: CARD_BODY_W, height: 90,
                 center_x: CARD_BODY_W / 2, center_y: 45, center_radius: 90, focal_x: 120,
                 focal_y: 30, focal_radius: 4
        sc_eyebrow("CONICAL")
        gradient [GOLD, ROSE, VIOLET, GOLD], type: :conical, width: CARD_BODY_W, height: 90,
                 center_x: CARD_BODY_W / 2, center_y: 45, angle: 0
        sc_eyebrow("STOPS · explicit positions")
        gradient [], stops: [{ "position" => 0.0, "color" => INK },
                             { "position" => 0.45, "color" => CYAN },
                             { "position" => 1.0, "color" => MINT }],
                 type: :linear, width: CARD_BODY_W, height: 42, start_x: 0, start_y: 0,
                 end_x: CARD_BODY_W, end_y: 0
      end
    end

    # ---------------------------------------------------------------- shaders
    def sc_draw_shader
      sc_card("Shader effect", "A compiled fragment shader with live uniforms", glyph: :power,
              accent: MINT, tags: %w[shader_effect shader_effect_source uniform_animator multi_effect]) do
        effect = shader_effect nil, shader: Showcase.asset(:shader), width: CARD_BODY_W,
                               height: 150, running: true, fps: 60, live: true,
                               amount: 0.6, intensity: 0.8, frequency: 2.4, amplitude: 0.5,
                               radius: 0.35, mouse_x: 0.5, mouse_y: 0.5, color: INK
        bind(effect, :amount) { state.shader_amount.to_f }
        bind(effect, :running) { state.live == true }
        on(effect, :error) { |event| sc_log("shader: #{event["message"]}") }
        on(effect, :click) do |event|
          state.shader_amount = (event["x"].to_f / CARD_BODY_W).round(3)
        end
        amount = slider 0.6, minimum: 0.0, maximum: 1.0, step: 0.01, track_color: PANEL_ALT,
                        fill_color: MINT, knob_color: WHITE, track_height: 6,
                        knob_size: 18 do |event|
          state.shader_amount = event["value"].to_f
        end
        bind(amount, :value) { state.shader_amount.to_f }
        readout = sc_kv("amount", "0.60", accent: MINT, key_width: 110)
        bind(readout, :text) { state.shader_amount.to_f.round(2).to_s }
        sc_eyebrow("UNIFORM_ANIMATOR · animate a shader uniform")
        uniforms = uniform_animator effect, uniform: "intensity", from: 0.35, to: 0.95,
                                   duration: 2600, easing: :in_out_quad, loops: "infinite",
                                   running: true
        bind(uniforms, :running) { state.live == true && state.reduced_motion != true }
        sc_eyebrow("SHADER_EFFECT_SOURCE · texture a live subtree")
        shader_effect_source width: CARD_BODY_W, height: 72, live: true, hide_source: false,
                             smooth: true, mipmap: false do
          rectangle width: CARD_BODY_W, height: 72, radius: 12, color: PANEL_ALT do
            text "captured as a texture", size: 11, color: MINT, wrap: false
          end
        end
      end
    end

    def sc_draw_particles
      sc_card("Particle system", "GPU particles with bursts", glyph: :star, accent: VIOLET,
              tags: %w[particle_system]) do
        rectangle width: CARD_BODY_W, height: 170, radius: 14, color: PANEL_DEEP,
                  border_color: BORDER_SOFT, border_width: 1 do
          field = particle_system width: CARD_BODY_W - 2, height: 168, running: true,
                                  emit_rate: 48, life_span: 2400, life_span_variation: 600,
                                  maximum_emitted: 600, size: 10, end_size: 2,
                                  size_variation: 0.4, source: Showcase.asset(:particle),
                                  color: VIOLET, color_variation: 0.4, alpha: 0.8,
                                  alpha_variation: 0.3, emitter_x: (CARD_BODY_W - 2) / 2,
                                  emitter_y: 150, emitter_width: CARD_BODY_W - 40,
                                  emitter_height: 8, velocity_angle: -90, velocity: 70,
                                  velocity_angle_variation: 24, velocity_variation: 30,
                                  acceleration_angle: -90, acceleration: 12, turbulence: 6,
                                  particle_shape: :image
          bind(field, :running) { state.live == true }
          bind(field, :burst_revision) { state.burst_revision.to_i }
          bind(field, :burst_count) { 120 }
          bind(field, :burst_x) { (CARD_BODY_W - 2) / 2 }
          bind(field, :burst_y) { 120 }
        end
        button "Burst", icon: :star, width: CARD_BODY_W, height: 40, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: VIOLET, font_size: 12 do
          transaction do
            state.burst_revision = state.burst_revision.to_i + 1
            state.activity = "Emitted a 120 particle burst"
          end
        end
      end
    end

    # --------------------------------------------------------------- pointers
    def sc_draw_pointer
      sc_card("Drag and drop", "Pointer areas that move real items", glyph: :arrow_right,
              accent: CYAN, tags: %w[drag_area drop_area hover_area]) do
        sc_eyebrow("DRAG_AREA · bounded on both axes")
        rectangle width: CARD_BODY_W, height: 130, radius: 12, color: PANEL_DEEP,
                  border_color: BORDER_SOFT, border_width: 1 do
          handle = drag_area axis: :both, minimum_x: -(CARD_BODY_W - 64) / 2,
                             maximum_x: (CARD_BODY_W - 64) / 2, minimum_y: -32,
                             maximum_y: 32, threshold: 2, cursor: :closed_hand,
                             width: 64, height: 64 do
            rectangle width: 64, height: 64, radius: 16, color: CYAN do
              text "drag", size: 11, bold: true, color: INK, wrap: false
            end
          end
          on(handle, :drag_end) do |event|
            state.drag_position = "#{event["target_x"].to_f.round}, " \
                                  "#{event["target_y"].to_f.round}"
          end
        end
        position = sc_kv("Released at", "0, 0", accent: CYAN, key_width: 110)
        bind(position, :text) { state.drag_position.to_s }
        sc_eyebrow("DROP_AREA · accepts a key")
        zone = drop_area keys: ["text/plain"], width: CARD_BODY_W, height: 70 do
          rectangle width: CARD_BODY_W, height: 70, radius: 12, color: PANEL_ALT,
                    border_color: BORDER, border_width: 1 do
            text "drop files or text here", size: 11, color: MUTED, wrap: false
          end
        end
        on(zone, :enter) { sc_log("Drop candidate entered") }
        on(zone, :drop) { |event| sc_log("Dropped #{event["text"] || "payload"}") }
        on(zone, :exit) { sc_log("Drop candidate left") }
        sc_eyebrow("HOVER_AREA · cursor shapes")
        hovered = hover_area cursor: :pointing_hand, blocking: false, margin: 0,
                             width: CARD_BODY_W, height: 54 do
          rectangle width: CARD_BODY_W, height: 54, radius: 12, color: PANEL_ALT do
            text "hover me", size: 11, color: MINT, wrap: false
          end
        end
        on(hovered, :enter) { state.hovering = true }
        on(hovered, :exit) { state.hovering = false }
        indicator = sc_kv("Hovering", "no", accent: MINT, key_width: 110)
        bind(indicator, :text) { state.hovering ? "yes" : "no" }
      end
    end

    def sc_draw_gestures
      sc_card("Gestures", "Tap, long press and pinch", glyph: :phone, accent: GOLD,
              tags: %w[tap_area pinch_area multi_touch_area]) do
        sc_eyebrow("TAP_AREA · tap, double tap, long press")
        taps = tap_area accepted_buttons: %i[left right], gesture_policy: :within_bounds,
                        long_press_threshold: 600, width: CARD_BODY_W, height: 74 do
          rectangle width: CARD_BODY_W, height: 74, radius: 12, color: PANEL_ALT,
                    border_color: BORDER_SOFT, border_width: 1 do
            label_node = text "tap, double tap or hold", size: 11, color: GOLD, wrap: false
            bind(label_node, :text) { state.tap_state.to_s }
          end
        end
        on(taps, :tap) { state.tap_state = "tap" }
        on(taps, :double_tap) { state.tap_state = "double tap" }
        on(taps, :long_press) { state.tap_state = "long press" }
        sc_eyebrow("PINCH_AREA · scale and rotate a target")
        rectangle width: CARD_BODY_W, height: 150, radius: 12, color: PANEL_DEEP,
                  border_color: BORDER_SOFT, border_width: 1 do
          zoom = pinch_area minimum_scale: 0.6, maximum_scale: 2.0, minimum_rotation: -45,
                            maximum_rotation: 45, width: CARD_BODY_W, height: 148 do
            rectangle width: 120, height: 120, radius: 18, color: TINT, border_color: GOLD,
                      border_width: 1 do
              icon :star, size: 32, color: GOLD
            end
          end
          on(zoom, :pinch_end) { |event| sc_log("pinch scale #{event["scale"].to_f.round(2)}") }
        end
        sc_eyebrow("MULTI_TOUCH_AREA")
        touch = multi_touch_area minimum_touch_points: 1, maximum_touch_points: 5,
                                 mouse_enabled: true, width: CARD_BODY_W, height: 62 do
          rectangle width: CARD_BODY_W, height: 62, radius: 12, color: PANEL_ALT do
            points = text "0 touch points", size: 11, color: MUTED, wrap: false
            bind(points, :text) { "#{state.touch_points.to_i} touch points" }
          end
        end
        on(touch, :press) { |event| state.touch_points = Array(event["points"]).size }
        on(touch, :update) { |event| state.touch_points = Array(event["points"]).size }
        on(touch, :release) { state.touch_points = 0 }
      end
    end

    def sc_draw_devices
      sc_card("Devices and insets", "Wheel, point handler and safe areas", glyph: :gear,
              accent: MINT, tags: %w[wheel_area point_handler safe_area]) do
        sc_eyebrow("WHEEL_AREA · scroll to change a value")
        wheel = wheel_area blocking: true, width: CARD_BODY_W, height: 80 do
          rectangle width: CARD_BODY_W, height: 80, radius: 12, color: PANEL_ALT,
                    border_color: BORDER_SOFT, border_width: 1 do
            column spacing: 2 do
              value = text "50", size: 22, bold: true, color: MINT, wrap: false
              bind(value, :text) { state.wheel_value.to_i.to_s }
              text "scroll over this panel", size: 10, color: FAINT, wrap: false
            end
          end
        end
        on(wheel, :wheel) do |event|
          delta = event["angle_y"] || event["pixel_y"] || 0
          step = delta.to_f.positive? ? 2 : -2
          state.wheel_value = [[state.wheel_value.to_i + step, 0].max, 100].min
        end
        sc_eyebrow("POINT_HANDLER · raw pointer position")
        pointer = point_handler accepted_buttons: %i[left], margin: 0, width: CARD_BODY_W,
                                height: 74 do
          rectangle width: CARD_BODY_W, height: 74, radius: 12, color: PANEL_DEEP do
            readout = text "press and move", size: 11, color: CYAN, wrap: false
            bind(readout, :text) { state.point_position.to_s }
          end
        end
        on(pointer, :point) do |event|
          state.point_position = "#{event["x"].to_i}, #{event["y"].to_i}"
        end
        sc_eyebrow("SAFE_AREA · device insets")
        safe_area edges: %i[top bottom left right], padding: 10, background: PANEL_ALT,
                  width: CARD_BODY_W, height: 70 do
          text "children stay clear of notches and home indicators", size: 10, color: MUTED,
               width: CARD_BODY_W - 24, wrap: true
        end
      end
    end

    def sc_draw_scrollers
      sc_card("Scrollers and selection", "Attached indicators and rubber-band selection",
              glyph: :menu, accent: ROSE, tags: %w[scroll_bar scroll_indicator selection_rectangle]) do
        sc_eyebrow("SCROLL_BAR · attached to a flickable")
        flick = flickable width: CARD_BODY_W, height: 110, content_width: CARD_BODY_W,
                          content_height: 420, direction: :vertical, interactive: true,
                          clip: true do
          column spacing: 6 do
            12.times do |index|
              rectangle width: CARD_BODY_W - 14, height: 28, radius: 8, color: PANEL_ALT do
                text "row #{index + 1}", size: 10, color: MUTED, wrap: false
              end
            end
          end
        end
        scroll_bar flick, orientation: :vertical, policy: :as_needed, interactive: true,
                   step_size: 0.08, minimum_size: 0.12, width: 8, height: 110
        scroll_indicator flick, orientation: :vertical, minimum_size: 0.12, width: 4,
                         height: 110
        sc_eyebrow("SELECTION_RECTANGLE · drag across the table")
        grid = table_view ROOMS.map { |room| { "room" => room["label"], "state" => room["state"] } },
                          columns: [{ key: "room", label: "Room", width: 180 },
                                    { key: "state", label: "State", width: 120 }],
                          width: CARD_BODY_W, height: 150, row_height: 28, header_height: 30,
                          selection_behavior: :cells, selection_mode: :extended,
                          background: PANEL, header_background: PANEL_DEEP,
                          cell_background: PANEL, alternate_background: PANEL_ALT,
                          selected_background: TINT, foreground: WHITE,
                          header_foreground: MUTED, selected_foreground: ROSE, muted: FAINT,
                          accent: ROSE, grid_color: BORDER_SOFT, border_color: BORDER,
                          radius: 10, font_size: 10, header_size: 9
        picker = selection_rectangle grid, mode: :drag, enabled: true
        on(picker, :selection_change) { sc_log("Selection changed") }
      end
    end
  end
end

# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_motion
      sc_page do
        sc_motion_intro
        sc_row do
          sc_motion_imperative
          sc_motion_declarative
          sc_motion_animators
        end
        sc_row do
          sc_motion_groups
          sc_motion_physics
          sc_motion_states
        end
        sc_row do
          sc_motion_timing
          sc_motion_effects
          sc_motion_shadows
        end
        sc_motion_declared
      end
    end

    def sc_motion_intro
      card width: FULL_W, padding: 18, spacing: 12, color: PANEL, border_color: BORDER,
           accent: VIOLET do
        row spacing: 14 do
          sc_tile(:play, accent: VIOLET)
          column spacing: 2, width: 560 do
            text "Motion is declared, not scripted", size: 16, bold: true, color: WHITE,
                 wrap: false
            sc_caption("Animations are components with a target, a property and a running " \
                       "flag. Ruby flips the flag; Qt runs the animation on the render thread.",
                       width: 560, size: 11)
          end
          spacer width: 180, height: 1
          brake = toggle "Reduced motion", description: "Stops every looping animation here",
                         checked: false, accent: VIOLET, foreground: WHITE, title_size: 12,
                         description_size: 10 do |event|
            state.reduced_motion = event["value"] != false
            sc_log(state.reduced_motion ? "Reduced motion on" : "Reduced motion off")
          end
          bind(brake, :checked) { state.reduced_motion == true }
        end
      end
    end

    def sc_motion_running
      state.reduced_motion != true
    end

    def sc_motion_imperative
      sc_card("animate and animate_sequence", "Fire-and-forget transitions from Ruby",
              glyph: :arrow_right, accent: CYAN, tags: %w[animation]) do
        puck = rectangle width: CARD_BODY_W, height: 76, radius: 14, color: TINT,
                         border_color: CYAN, border_width: 1 do
          text "animate me", size: 13, bold: true, color: CYAN, wrap: false
        end
        row spacing: 8 do
          button "Fade", width: 100, height: 36, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: CYAN, font_size: 11 do
            animate(puck, { opacity: 0.25 }, duration: 260, easing: :out_quad)
            after(0.4) { animate(puck, { opacity: 1.0 }, duration: 260, easing: :in_quad) }
          end
          button "Scale", width: 100, height: 36, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: MINT, font_size: 11 do
            animate_sequence(puck, [{ to: { scale: 1.08 }, duration: 160, easing: :out_back },
                                    { to: { scale: 1.0 }, duration: 220, easing: :in_out_quad }])
          end
          button "Spin", width: 104, height: 36, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: VIOLET, font_size: 11 do
            animate_sequence(puck, [{ to: { rotation: 8 }, duration: 140 },
                                    { to: { rotation: -8 }, duration: 180 },
                                    { to: { rotation: 0 }, duration: 160 }])
          end
        end
        sc_caption("`animate` emits one animation patch for the properties you name. " \
                   "`animate_sequence` chains them with computed delays, still in one message.")
        sc_code("animate(puck, { opacity: 0.25 },\n        duration: 260,\n" \
                "        easing: :out_quad)")
      end
    end

    def sc_motion_declarative
      sc_card("Declarative animations", "Components that own their own loop", glyph: :refresh,
              accent: MINT, tags: %w[animation number_animation color_animation
                                     rotation_animation property_animation]) do
        pulse = rectangle width: CARD_BODY_W, height: 48, radius: 12, color: PANEL_ALT do
          text "number_animation · opacity", size: 11, color: MINT, wrap: false
        end
        fade = number_animation pulse, property: :opacity, from: 0.35, to: 1.0, duration: 1100,
                               easing: :in_out_quad, loops: "infinite", running: true
        bind(fade, :running) { sc_motion_running }

        tinted = rectangle width: CARD_BODY_W, height: 48, radius: 12, color: PANEL_ALT do
          text "color_animation · color", size: 11, color: INK, wrap: false
        end
        tint = color_animation tinted, property: :color, from: TINT, to: MINT, duration: 1600,
                               easing: :in_out_quad, loops: "infinite", running: true
        bind(tint, :running) { sc_motion_running }

        spinner = sc_tile(:refresh, accent: VIOLET, size: 56, radius: 16, glyph_size: 22)
        spin = rotation_animation spinner, property: :rotation, from: 0, to: 360,
                                  duration: 2400, easing: :linear, loops: "infinite",
                                  direction: :clockwise, running: true
        bind(spin, :running) { sc_motion_running }

        generic = rectangle width: CARD_BODY_W, height: 44, radius: 12, color: PANEL_ALT do
          text "animation · the generic component", size: 11, color: GOLD, wrap: false
        end
        any = animation target: generic, property: :opacity, from: 0.45, to: 1.0,
                        duration: 1400, easing: :in_out_quad, loops: "infinite",
                        running: true, always_run: false
        bind(any, :running) { sc_motion_running }

        slid = rectangle width: 96, height: 32, radius: 10, color: CYAN do
          text "property", size: 10, bold: true, color: INK, wrap: false
        end
        slide = property_animation slid, property: :x, from: 0, to: CARD_BODY_W - 96,
                                   duration: 1800, easing: :in_out_cubic, loops: "infinite",
                                   running: true
        bind(slide, :running) { sc_motion_running }
      end
    end

    def sc_motion_animators
      sc_card("Animators", "Render-thread animators, five properties", glyph: :star,
              accent: GOLD, tags: %w[opacity_animator rotation_animator scale_animator
                                     x_animator y_animator]) do
        [[:opacity_animator, "opacity", 0.3, 1.0, MINT],
         [:rotation_animator, "rotation", 0, 360, CYAN],
         [:scale_animator, "scale", 0.85, 1.0, VIOLET]].each do |type, label, from, to, tone|
          row spacing: 10 do
            dot = rectangle width: 44, height: 44, radius: 12, color: tone do
              text label[0, 1].upcase, size: 15, bold: true, color: INK, wrap: false
            end
            animator = public_send(type, dot, from: from, to: to, duration: 1500,
                                   easing: :in_out_quad, loops: "infinite", running: true)
            bind(animator, :running) { sc_motion_running }
            column spacing: 1, width: CARD_BODY_W - 56 do
              sc_value(type.to_s, color: tone, size: 12)
              sc_caption("#{label}: #{from} → #{to}", width: CARD_BODY_W - 56, size: 10)
            end
          end
        end
        sc_eyebrow("X_ANIMATOR · Y_ANIMATOR")
        rectangle width: CARD_BODY_W, height: 76, radius: 12, color: PANEL_DEEP do
          travel = rectangle width: 34, height: 34, radius: 10, color: GOLD
          x_move = x_animator travel, from: 0, to: CARD_BODY_W - 60, duration: 2000,
                              easing: :in_out_quad, loops: "infinite", running: true
          y_move = y_animator travel, from: -14, to: 14, duration: 900, easing: :in_out_quad,
                              loops: "infinite", running: true
          bind(x_move, :running) { sc_motion_running }
          bind(y_move, :running) { sc_motion_running }
        end
      end
    end

    def sc_motion_groups
      sc_card("Groups and actions", "Parallel, sequential, pause and script",
              glyph: :menu, accent: CYAN, tags: %w[parallel_animation sequential_animation
                                                   pause_animation script_action property_action]) do
        stage = rectangle width: CARD_BODY_W, height: 86, radius: 14, color: PANEL_ALT,
                          border_color: CYAN, border_width: 1 do
          text "group target", size: 12, bold: true, color: CYAN, wrap: false
        end
        together = parallel_animation [
          { target: stage, property: "opacity", from: 0.4, to: 1.0, duration: 900,
            easing: "in_out_quad" },
          { target: stage, property: "scale", from: 0.96, to: 1.0, duration: 900,
            easing: "out_back" }
        ], loops: "infinite", running: true
        bind(together, :running) { sc_motion_running }

        after_each = sequential_animation [
          { target: stage, property: "rotation", from: 0, to: 2, duration: 600 },
          { target: stage, property: "rotation", from: 2, to: -2, duration: 900 },
          { target: stage, property: "rotation", from: -2, to: 0, duration: 600 }
        ], loops: "infinite", running: false
        bind(after_each, :running) { state.sequence_running == true && sc_motion_running }
        on(after_each, :step) { |event| sc_log("sequence step #{event["value"]}") }

        pause_animation 400, running: false
        row spacing: 8 do
          button "Run sequence", width: 160, height: 36, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: CYAN, font_size: 11 do
            state.sequence_running = true
          end
          button "Stop", width: 150, height: 36, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: FAINT, font_size: 11 do
            state.sequence_running = false
          end
        end
        sc_eyebrow("SCRIPT_ACTION · PROPERTY_ACTION")
        script = script_action "showcase.marker", trigger: false, revision: 0
        bind(script, :revision) { state.action_revision.to_i }
        on(script, :trigger) { sc_log("script_action fired") }
        setter = property_action stage, property: :opacity, value: 1.0, revision: 0
        bind(setter, :revision) { state.action_revision.to_i }
        button "Fire both actions", width: CARD_BODY_W, height: 38, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: MINT, font_size: 11 do
          transaction do
            state.action_revision = state.action_revision.to_i + 1
            state.activity = "script_action and property_action fired"
          end
        end
      end
    end

    def sc_motion_physics
      sc_card("Physics and easing", "Spring, smoothed and behaviours", glyph: :heart,
              accent: ROSE, tags: %w[spring_animation smoothed_animation behavior
                                     anchor_animation parent_animation]) do
        sc_eyebrow("SPRING_ANIMATION · drag the slider")
        rectangle width: CARD_BODY_W, height: 70, radius: 12, color: PANEL_DEEP do
          bob = rectangle width: 40, height: 40, radius: 20, color: ROSE
          spring = spring_animation bob, property: :x, from: 0, to: 0, spring: 2.4,
                                    damping: 0.18, mass: 1.0, epsilon: 0.01, running: true
          bind(spring, :to) { (state.spring_target.to_f / 100.0) * (CARD_BODY_W - 60) - (CARD_BODY_W - 60) / 2.0 }
          bind(spring, :running) { sc_motion_running }
        end
        target = slider 50, minimum: 0, maximum: 100, step: 1, integer: true,
                        track_color: PANEL_ALT, fill_color: ROSE, knob_color: WHITE,
                        track_height: 6, knob_size: 18 do |event|
          state.spring_target = event["value"].to_i
        end
        bind(target, :value) { state.spring_target.to_i }
        sc_eyebrow("SMOOTHED_ANIMATION · velocity limited")
        rectangle width: CARD_BODY_W, height: 60, radius: 12, color: PANEL_DEEP do
          glide = rectangle width: 34, height: 34, radius: 10, color: CYAN
          smoothed = smoothed_animation glide, property: :x, from: 0, to: 0, velocity: 180,
                                        reversing_mode: :immediate, running: true
          bind(smoothed, :to) { (state.spring_target.to_f / 100.0) * (CARD_BODY_W - 54) - (CARD_BODY_W - 54) / 2.0 }
          bind(smoothed, :running) { sc_motion_running }
        end
        sc_eyebrow("BEHAVIOR · animate every write to one property")
        watched = rectangle width: CARD_BODY_W, height: 54, radius: 12, color: TINT do
          text "behaviour on opacity", size: 11, color: WHITE, wrap: false
        end
        guard = behavior watched, property: :opacity, value: 1.0, duration: 420,
                         easing: :in_out_cubic, enabled: true
        bind(guard, :value) { state.behavior_value.to_f }
        row spacing: 8 do
          [["Dim", 0.35], ["Half", 0.65], ["Full", 1.0]].each do |label, value|
            button label, width: 104, height: 34, bordered: true, foreground: WHITE,
                   background: PANEL_ALT, accent: ROSE, font_size: 11 do
              state.behavior_value = value
            end
          end
        end
      end
    end

    def sc_motion_states
      sc_card("States and transitions", "Declarative property sets", glyph: :gear,
              accent: VIOLET, tags: %w[state state_group transition property_changes
                                       anchor_changes parent_change]) do
        panel = rectangle width: CARD_BODY_W, height: 90, radius: 14, color: PANEL_ALT,
                          border_color: BORDER, border_width: 1 do
          label_node = text "base state", size: 13, bold: true, color: WHITE, wrap: false
          bind(label_node, :text) { "#{state.panel_state} state" }
        end
        highlighted = state :highlighted, target: panel,
                            properties: { "color" => TINT, "scale" => 1.02 },
                            restore_entry_values: true, revision: 0
        bind(highlighted, :when) { state.panel_state.to_s == "highlighted" }
        on(highlighted, :enter) { sc_log("Entered the highlighted state") }
        alarmed = state :alarmed, target: panel,
                        properties: { "color" => "#3a1420", "scale" => 1.0 },
                        restore_entry_values: true, revision: 0
        bind(alarmed, :when) { state.panel_state.to_s == "alarmed" }
        row spacing: 8 do
          %w[base highlighted alarmed].each do |name|
            chosen = button name.capitalize, width: 104, height: 34, bordered: true,
                            foreground: WHITE, background: PANEL_ALT, accent: VIOLET,
                            font_size: 11 do
              transaction do
                state.panel_state = name
                state.activity = "Panel state → #{name}"
              end
            end
            bind(chosen, :selected) { state.panel_state.to_s == name }
          end
        end
        group = state_group panel, current: "base", revision: 0
        bind(group, :current) { state.panel_state.to_s }
        on(group, :change) { |event| sc_log("state_group → #{event["value"]}") }
        move = transition panel, from_state: "base", to_state: "highlighted",
                          animations: [{ property: "scale", from: 1.0, to: 1.02,
                                         duration: 260, easing: "out_back" }],
                          enabled: true, running: false, revision: 0
        bind(move, :running) { state.panel_state.to_s == "highlighted" && sc_motion_running }
        changes = property_changes panel, properties: { "radius" => 14 }, revision: 0
        bind(changes, :properties) do
          { "radius" => state.panel_state.to_s == "alarmed" ? 4 : 14 }
        end
        sc_caption("`state` applies a property set while its `when` is true and restores the " \
                   "previous values on exit. Ruby only ever writes the state name.", size: 10)
      end
    end

    # Six animation components need a target property shape this page cannot
    # meaningfully drive (a vector3d, a path, anchors or a new parent). They are
    # declared here, inert, with the target they would act on.
    def sc_motion_declared
      card width: FULL_W, padding: 18, spacing: 14, color: PANEL, border_color: BORDER,
           accent: MUTED do
        sc_head(:info, "Declared, not animated",
                "These six are real components in this tree with running: false.",
                accent: MUTED, width: FULL_W - 36)
        anchor_target = rectangle width: FULL_W - 36, height: 46, radius: 12, color: PANEL_ALT,
                                  border_color: BORDER_SOFT, border_width: 1 do
          text "shared target for the six declarations below", size: 11, color: MUTED,
               wrap: false
        end
        vector_animation anchor_target, property: :scale, from: [1.0, 1.0, 1.0],
                         to: [1.05, 1.05, 1.0], duration: 800, easing: :in_out_quad,
                         running: false
        path_animation anchor_target, path: "M 0,0 L 120,0 L 120,40", orientation: :fixed,
                       anchor_x: 0, anchor_y: 0, duration: 1200, easing: :in_out_quad,
                       running: false
        anchor_animation anchor_target, duration: 400, easing: :in_out_quad, running: false
        parent_animation anchor_target, duration: 400, easing: :in_out_quad, running: false
        anchor_changes anchor_target, anchors: { "horizontalCenter" => "parent" },
                       margins: 0, revision: 0
        parent_change anchor_target, x: 0, y: 0, scale: 1.0, rotation: 0, revision: 0
        wrap width: FULL_W - 36, spacing: 10 do
          [["vector_animation", "animates a vector3d property, such as a 3D scale"],
           ["path_animation", "moves an item along a declared path"],
           ["anchor_animation", "animates an anchor change"],
           ["parent_animation", "animates a reparenting"],
           ["anchor_changes", "declares the anchors a state applies"],
           ["parent_change", "declares the new parent a state applies"]].each do |name, note|
            rectangle width: 206, height: 86, radius: 12, padding: 12, color: PANEL_ALT,
                      border_color: BORDER_SOFT, border_width: 1 do
              column spacing: 4, width: 182 do
                text name, size: 11, bold: true, color: VIOLET, width: 182, wrap: false
                sc_caption(note, width: 182, size: 10)
              end
            end
          end
        end
      end
    end

    def sc_motion_timing
      sc_card("Timing", "Timers, frame callbacks and controllers", glyph: :clock, accent: MINT,
              tags: %w[timer frame_animation animation_controller pause_animation]) do
        sc_eyebrow("TIMER · a declared component")
        ticker = timer 1000, repeat: true, running: true, triggered_on_start: false, revision: 0
        bind(ticker, :running) { state.live == true }
        on(ticker, :trigger) { state.timer_ticks = state.timer_ticks.to_i + 1 }
        ticks = sc_kv("Component ticks", "0", accent: MINT, key_width: 130)
        bind(ticks, :text) { state.timer_ticks.to_i.to_s }
        sc_eyebrow("FRAME_ANIMATION · per-frame callback")
        frames = frame_animation running: false
        bind(frames, :running) { state.frame_counting == true }
        on(frames, :frame) { state.frame_count = state.frame_count.to_i + 1 }
        counted = sc_kv("Frames observed", "0", accent: CYAN, key_width: 130)
        bind(counted, :text) { state.frame_count.to_i.to_s }
        row spacing: 8 do
          button "Count frames", width: 160, height: 36, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: CYAN, font_size: 11 do
            state.frame_counting = true
          end
          button "Stop", width: 150, height: 36, bordered: true, foreground: WHITE,
                 background: PANEL_ALT, accent: FAINT, font_size: 11 do
            state.frame_counting = false
          end
        end
        sc_eyebrow("ANIMATION_CONTROLLER · scrub a transition")
        scrubbed = rectangle width: CARD_BODY_W, height: 56, radius: 12, color: PANEL_ALT do
          text "scrubbed by progress", size: 11, color: MINT, wrap: false
        end
        controller = animation_controller scrubbed, property: :opacity, from: 0.2, to: 1.0,
                                          duration: 1000, progress: 1.0, revision: 0
        bind(controller, :progress) { state.scrub.to_f }
        scrub = slider 100, minimum: 0, maximum: 100, step: 1, integer: true,
                       track_color: PANEL_ALT, fill_color: MINT, knob_color: WHITE,
                       track_height: 6, knob_size: 18 do |event|
          state.scrub = event["value"].to_f / 100.0
        end
        bind(scrub, :value) { (state.scrub.to_f * 100).round }
      end
    end

    def sc_motion_effects
      sc_card("GPU effects", "Blur, colorize and glow over real pixels", glyph: :image,
              accent: CYAN, tags: %w[blur colorize glow multi_effect]) do
        sc_eyebrow("BLUR · bound amount")
        haze = blur width: CARD_BODY_W, height: 96, amount: 0.0, maximum: 48,
                    multiplier: 1.0, auto_padding: true do
          aspect_ratio ratio: 3.29, width: CARD_BODY_W, clip: true do
            image Showcase.asset(:storm), width: CARD_BODY_W, height: 96,
                  fill_mode: :preserve_aspect_crop, asynchronous: true
          end
        end
        bind(haze, :amount) { state.blur_amount.to_f }
        amount = slider 0, minimum: 0, maximum: 100, step: 1, integer: true,
                        track_color: PANEL_ALT, fill_color: CYAN, knob_color: WHITE,
                        track_height: 6, knob_size: 18 do |event|
          state.blur_amount = event["value"].to_f / 100.0
        end
        bind(amount, :value) { (state.blur_amount.to_f * 100).round }
        sc_eyebrow("COLORIZE")
        colorize width: CARD_BODY_W, height: 90, amount: 0.75, color: VIOLET, brightness: 0.05,
                 contrast: 0.1, saturation: 0.2 do
          aspect_ratio ratio: 3.51, width: CARD_BODY_W, clip: true do
            image Showcase.asset(:room), width: CARD_BODY_W, height: 90,
                  fill_mode: :preserve_aspect_crop, asynchronous: true
          end
        end
        sc_eyebrow("GLOW")
        glow width: CARD_BODY_W, height: 70, blur: 0.6, maximum: 32, multiplier: 1.2,
             color: MINT, opacity: 0.9 do
          rectangle width: CARD_BODY_W, height: 70, radius: 14, color: PANEL_DEEP do
            text "glowing surface", size: 13, bold: true, color: MINT, wrap: false
          end
        end
        sc_eyebrow("MULTI_EFFECT · one pass, many knobs")
        multi_effect width: CARD_BODY_W, height: 96, brightness: 0.08, contrast: 0.12,
                     saturation: 0.3, colorization: 0.25, colorization_color: CYAN,
                     blur_enabled: true, blur: 0.18, blur_max: 32, shadow_enabled: true,
                     shadow_opacity: 0.6, shadow_blur: 0.8, shadow_vertical_offset: 6,
                     shadow_color: INK, auto_padding: true do
          aspect_ratio ratio: 3.29, width: CARD_BODY_W, clip: true do
            image Showcase.asset(:heart), width: CARD_BODY_W, height: 96,
                  fill_mode: :preserve_aspect_crop, asynchronous: true
          end
        end
      end
    end

    def sc_motion_shadows
      sc_card("Shadows and masks", "Depth without a browser", glyph: :image, accent: VIOLET,
              tags: %w[drop_shadow rectangular_shadow opacity_mask shader_effect_source]) do
        sc_eyebrow("DROP_SHADOW")
        drop_shadow width: CARD_BODY_W, height: 86, blur: 0.7, maximum: 32, multiplier: 1.0,
                    horizontal_offset: 0, vertical_offset: 8, color: "#99000000",
                    opacity: 1.0 do
          rectangle width: CARD_BODY_W - 20, height: 70, radius: 14, color: PANEL_ALT,
                    border_color: VIOLET, border_width: 1 do
            text "elevated card", size: 12, bold: true, color: WHITE, wrap: false
          end
        end
        sc_eyebrow("RECTANGULAR_SHADOW · cheap, exact")
        rectangular_shadow width: CARD_BODY_W, height: 86, blur: 22, spread: 2, radius: 16,
                           offset_x: 0, offset_y: 10, color: "#aa06090f", cached: true do
          rectangle width: CARD_BODY_W - 24, height: 66, radius: 16, color: TINT do
            text "rectangular_shadow", size: 12, bold: true, color: CYAN, wrap: false
          end
        end
        sc_eyebrow("OPACITY_MASK · fade with a mask source")
        opacity_mask width: CARD_BODY_W, height: 96, mask_source: Showcase.asset(:core),
                     threshold_min: 0.1, spread_min: 0.2, threshold_max: 1.0,
                     spread_max: 0.0, inverted: false do
          aspect_ratio ratio: 3.29, width: CARD_BODY_W, clip: true do
            image Showcase.asset(:car), width: CARD_BODY_W, height: 96,
                  fill_mode: :preserve_aspect_crop, asynchronous: true
          end
        end
        sc_caption("Effects are containers: they wrap the subtree they operate on, so the " \
                   "thing being blurred or masked stays an ordinary component.", size: 10)
      end
    end
  end
end

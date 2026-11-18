# frozen_string_literal: true

module Showcase
  # GPU effects live on their own page rather than beside the animations. Seven
  # shader passes over four images in the same scene as twenty looping
  # animations means every frame of every animation re-renders every effect,
  # which costs a whole core and leaves the window unable to answer a click.
  # Apart they are both cheap, and each has room to be read.
  module UI
    def sc_page_effects
      sc_page do
        sc_effects_intro
        sc_row height: EFFECT_CARD_H do
          sc_effects_gpu
          sc_effects_shadows
          sc_effects_notes
        end
      end
    end

    def sc_effects_intro
      card width: FULL_W, padding: 18, spacing: 12, color: PANEL, border_color: BORDER,
           accent: CYAN do
        row spacing: 14 do
          sc_tile(:image, accent: CYAN)
          column spacing: 2, width: 620 do
            text "Effects are containers", size: 16, bold: true, color: WHITE, wrap: false
            sc_caption("Every effect here wraps the subtree it operates on, so the thing being " \
                       "blurred, tinted, glowed, shadowed or masked stays an ordinary component " \
                       "underneath. The shaders are compiled by Qt and run on the GPU.",
                       width: 620, size: 11)
          end
          spacer width: 40, height: 1
          sc_stat("EFFECTS", 8, CYAN, width: 110)
          sc_stat("SHADER PASSES", 7, VIOLET, width: 150)
          sc_stat("DRAWN BY", "GPU", MINT, width: 120)
        end
      end
    end

    def sc_effects_notes
      sc_card("What each one costs", "Where the work actually happens", glyph: :info,
              accent: GOLD, tags: %w[shader_effect_source]) do
        sc_panel do
          sc_kv("blur", "one pass, radius bound", accent: CYAN, key_width: 128, width: CARD_BODY_W - 28)
          sc_kv("colorize", "one pass, no sampling", accent: MINT, key_width: 128, width: CARD_BODY_W - 28)
          sc_kv("glow", "blur then additive", accent: VIOLET, key_width: 128, width: CARD_BODY_W - 28)
          sc_kv("multi_effect", "one pass, many knobs", accent: GOLD, key_width: 128, width: CARD_BODY_W - 28)
          sc_kv("drop_shadow", "blur of the alpha", accent: ROSE, key_width: 128, width: CARD_BODY_W - 28)
          sc_kv("rectangular_shadow", "no source needed", accent: AMBER, key_width: 128, width: CARD_BODY_W - 28)
          sc_kv("opacity_mask", "one sample per pixel", accent: CYAN, key_width: 128, width: CARD_BODY_W - 28)
        end
        sc_caption("`multi_effect` is the one to reach for when you want several of these at " \
                   "once: it does brightness, contrast, saturation, colorization, blur and a " \
                   "shadow in a single pass instead of stacking a pass for each.")
        sc_code("multi_effect width: 320, height: 96,\n" \
                "             blur_enabled: true,\n" \
                "             blur: 0.18,\n" \
                "             shadow_enabled: true do\n" \
                "  image \"room.jpg\"\n" \
                "end")
      end
    end

    def sc_effects_gpu
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

    def sc_effects_shadows
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

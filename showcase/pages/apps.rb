# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_apps
      sc_page do
        sc_apps_intro
        DEMOS.each_slice(3) do |group|
          sc_row do
            group.each { |demo| sc_demo_card(demo) }
          end
        end
        sc_apps_footer
      end
    end

    def sc_apps_intro
      card width: FULL_W, padding: 22, spacing: 16, color: PANEL, border_color: BORDER,
           accent: MINT do
        gradient colors: [MINT, CYAN, VIOLET], type: :linear, width: FULL_W - 44, height: 3,
                 start_x: 0, start_y: 0, end_x: FULL_W - 44, end_y: 0
        row spacing: 18 do
          column spacing: 8, width: 600 do
            text "Twelve complete applications", size: 24, bold: true, color: WHITE,
                 width: 600, wrap: true
            sc_caption("Each one is a standalone Zui app checked into this repository under " \
                       "demos/. They are not screenshots or embedded views: pressing Launch " \
                       "starts the real application as its own native process, with its own " \
                       "window, state and assets.", width: 600, size: 12)
          end
          column spacing: 10, width: 300 do
            sc_stat("BUNDLED APPS", DEMOS.size, MINT, width: 300, size: 26)
            launched = sc_stat("LAUNCHED THIS SESSION", "0", CYAN, width: 300, size: 26)
            bind(launched, :text) { state.launch_count.to_i.to_s }
            last = sc_caption("nothing launched yet", width: 300, size: 10)
            bind(last, :text) { state.launch_status.to_s }
          end
          column spacing: 8, width: 150 do
            sc_eyebrow("RUN MANUALLY")
            sc_code("zui run \\\n  demos/<app>/\\\n  main.rb", width: 150)
          end
        end
      end
    end

    def sc_demo_hero(demo)
      hero = demo[:hero]
      path = hero.nil? ? nil : "demos/#{demo[:slug]}/#{hero}"
      if path.nil?
        rectangle width: CARD_BODY_W, height: 128, radius: 12, color: PANEL_DEEP,
                  border_color: BORDER_SOFT, border_width: 1 do
          column spacing: 8 do
            sc_tile(demo[:glyph], accent: demo[:accent], size: 48, radius: 14, glyph_size: 22)
            text demo[:tagline], size: 10, color: FAINT, wrap: false
          end
        end
      else
        aspect_ratio ratio: 2.47, width: CARD_BODY_W, clip: true do
          shot = image path, width: CARD_BODY_W, height: 128,
                       fill_mode: :preserve_aspect_crop, asynchronous: true, cache: true,
                       smooth: true
          on(shot, :error) { sc_log("#{demo[:title]}: hero image missing") }
        end
      end
    end

    def sc_demo_card(demo)
      card width: CARD_W, padding: CARD_PAD, spacing: 14, color: PANEL, border_color: BORDER,
           accent: demo[:accent], alignment: :start do
        sc_demo_hero(demo)
        row spacing: 10 do
          sc_tile(demo[:glyph], accent: demo[:accent], size: 34, radius: 10, glyph_size: 15)
          column spacing: 1, width: CARD_BODY_W - 46 do
            text demo[:title], size: 17, bold: true, color: WHITE, wrap: false
            text demo[:tagline], size: 10, color: demo[:accent], wrap: false
          end
        end
        sc_caption(demo[:blurb], width: CARD_BODY_W, size: 11)
        sc_tags(demo[:exercises], width: CARD_BODY_W)
        sc_kv("Entry point", "demos/#{demo[:slug]}", accent: MUTED, key_width: 86)
        row spacing: 8 do
          button "Launch", icon: :play, width: 196, height: 42, foreground: INK,
                 background: demo[:accent], accent: demo[:accent], font_size: 13 do
            sc_launch_demo(demo)
          end
          button "Copy", icon: :copy, width: 108, height: 42, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: MUTED, font_size: 12 do
            sc_copy_launch_command(demo)
          end
        end
      end
    end

    def sc_demo_entry(demo)
      File.join(REPO_ROOT, "demos", demo[:slug], "main.rb")
    rescue StandardError
      "demos/#{demo[:slug]}/main.rb"
    end

    def sc_launch_command(demo)
      "zui run demos/#{demo[:slug]}/main.rb"
    end

    def sc_copy_launch_command(demo)
      transaction do
        state.clipboard_text = sc_launch_command(demo)
        state.clipboard_revision = state.clipboard_revision.to_i + 1
        state.launch_status = "Copied: #{sc_launch_command(demo)}"
        state.activity = "Copied the launch command for #{demo[:title]}"
      end
    end

    # Starts the demo as a detached process. The showcase never blocks on it:
    # a failure is reported in the activity strip and on the card.
    def sc_launch_demo(demo)
      entry = sc_demo_entry(demo)
      unless sc_demo_present?(entry)
        sc_launch_failed(demo, "demos/#{demo[:slug]}/main.rb is not in this checkout")
        return
      end
      executable = sc_zui_executable
      begin
        pid = Process.spawn(executable, "run", entry,
                            { chdir: REPO_ROOT, out: File::NULL, err: File::NULL })
        Process.detach(pid)
      rescue StandardError => error
        sc_launch_failed(demo, "#{error.class}: #{error.message}")
        return
      end
      total = state.launch_count.to_i + 1
      transaction do
        state.launch_count = total
        state.launch_status = "Launched #{demo[:title]} (pid #{pid})"
        state.activity = "Launched #{demo[:title]}"
      end
    end

    def sc_launch_failed(demo, reason)
      transaction do
        state.launch_status = "#{demo[:title]}: #{reason}"
        state.activity = "Could not launch #{demo[:title]} — #{reason}"
      end
    end

    def sc_demo_present?(entry)
      File.file?(entry)
    rescue StandardError
      false
    end

    def sc_zui_executable
      ENV.fetch("ZUI_COMMAND", "zui")
    rescue StandardError
      "zui"
    end

    def sc_apps_footer
      card width: FULL_W, padding: 20, spacing: 14, color: PANEL, border_color: BORDER,
           accent: MUTED do
        sc_head(:info, "How launching works",
                "Nothing is embedded, mocked or screenshotted.", accent: MUTED,
                width: FULL_W - 40)
        row spacing: 16 do
          sc_panel(width: 340) do
            sc_eyebrow("THE MECHANISM", color: CYAN)
            sc_caption("Launch runs `zui run demos/<app>/main.rb` as a detached child " \
                       "process from the repository root. The showcase keeps running; the " \
                       "demo owns its own window and exits on its own.", width: 312, size: 11)
          end
          sc_panel(width: 340) do
            sc_eyebrow("IF LAUNCH FAILS", color: GOLD)
            sc_caption("The `zui` executable must be on PATH, or set ZUI_COMMAND to its full " \
                       "path. Run `zui doctor --fix` once to install the native client. Every " \
                       "failure is printed on the card and in the activity strip.",
                       width: 312, size: 11)
          end
          sc_panel(width: 340) do
            sc_eyebrow("ASSETS AND PROVENANCE", color: MINT)
            sc_caption("Each demo keeps its own README and asset provenance notes. The media " \
                       "pages of this showcase reuse those same files rather than shipping " \
                       "duplicates.", width: 312, size: 11)
          end
        end
      end
    end
  end
end

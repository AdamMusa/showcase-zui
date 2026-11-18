# frozen_string_literal: true

require "zui"

require_relative "showcase/theme"
require_relative "showcase/catalog_data"
require_relative "showcase/coverage_data"
require_relative "showcase/assets"
require_relative "showcase/demos"
require_relative "showcase/nav"
require_relative "showcase/support"
require_relative "showcase/catalog"
require_relative "showcase/chrome"
require_relative "showcase/pages/overview"
require_relative "showcase/pages/foundation"
require_relative "showcase/pages/content"
require_relative "showcase/pages/buttons"
require_relative "showcase/pages/inputs"
require_relative "showcase/pages/navigation"
require_relative "showcase/pages/feedback"
require_relative "showcase/pages/data"
require_relative "showcase/pages/charts"
require_relative "showcase/pages/drawing"
require_relative "showcase/pages/motion"
require_relative "showcase/pages/effects"
require_relative "showcase/pages/media"
require_relative "showcase/pages/system"
require_relative "showcase/pages/apps"
require_relative "showcase/pages/about"

module Showcase
  # Page bodies are built on demand so the first frame stays small and fast.
  # script/verify.rb sets ZUI_SHOWCASE_EAGER=1 to get the whole tree at once.
  def self.eager?
    defined?(ENV) && ENV["ZUI_SHOWCASE_EAGER"].to_s == "1"
  rescue StandardError
    false
  end

  # Walks the built surface tree and reports which component types are really
  # on screen, so the catalog can mark them without a hand-maintained list.
  def self.rendered_types(tree)
    found = {}
    tree.each_value { |node| walk(node, found) } if tree.is_a?(Hash)
    found.keys.sort
  end

  def self.walk(node, found)
    return unless node.is_a?(Hash)

    type = node["type"]
    found[type] = true if type
    children = node["children"]
    children.each { |child| walk(child, found) } if children.is_a?(Array)
  end

  SEED_PULSE = [38, 42, 39, 48, 51, 47, 58, 63, 61, 70, 68, 76, 73, 82, 78, 86].freeze
  SEED_LATENCY = [28, 24, 25, 21, 23, 19, 18, 20, 17, 16, 14, 15, 13, 14, 12, 13].freeze

  def self.build
    Zui::Application.new(ui: UI) do
      # ---------------------------------------------------------------- shell
      state :page, 0
      state :activity, "Showcase ready"
      state :activity_revision, 0
      state :tick, 0
      state :live, true
      state :pulse, SEED_PULSE.dup
      state :latency, SEED_LATENCY.dup
      state :live_types, []
      state :live_count, 0

      # -------------------------------------------------------------- catalog
      state :catalog_ready, false
      state :catalog_page, 0
      state :catalog_query, ""
      state :catalog_category, ALL_CATEGORIES
      state :catalog_selected, "button"

      # ----------------------------------------------------------- foundation
      state :split_sizes, "drag to measure"
      state :layout_index, 0
      state :loader_active, true
      state :flipped, false

      # -------------------------------------------------------------- content
      state :metrics, "waiting…"
      state :icon_name, "star"
      state :chip_name, "Reactive"

      # -------------------------------------------------------------- buttons
      state :clicks, 0
      state :armed, false
      state :round_glyph, "play"
      state :bar_glyph, "house"
      state :audio_on, true
      state :online, true
      state :reduced_motion, false
      state :unchecked, []
      state :switched_off, []
      state :density, "Comfortable"
      state :cadence, "Daily"
      state :segment, "Charts"

      # --------------------------------------------------------------- inputs
      state :form_name, ""
      state :form_secret_length, 0
      state :form_notes, ""
      state :form_search, ""
      state :guests, 4
      state :minutes, 18
      state :target_temp, 21.5
      state :brightness, 68
      state :band_lower, 19.0
      state :band_upper, 24.0
      state :scene, "Focus"
      state :rooms, %w[Kitchen Studio]
      state :accent, CYAN
      state :date, "2026-11-17"
      state :time, "09:30"
      state :file_path, ""
      state :folder_path, ""
      state :font_family, ""

      # ----------------------------------------------------------- navigation
      state :tab_index, 0
      state :range_index, 1
      state :view_mode, "Grid"
      state :rail_index, 0
      state :rail_extended, true
      state :page_number, 1
      state :panel_open, true
      state :step_index, 0
      state :drawer_open, false

      # ------------------------------------------------------------- feedback
      state :menu_open, false
      state :menu_bar_entry, ""
      state :dialog_open, false
      state :alert_open, false
      state :message_open, false
      state :confirm_open, false
      state :sheet_open, false
      state :modal_open, false
      state :popup_open, false
      state :snackbar_open, false
      state :toast_open, false
      state :dialog_answer, "none"
      state :job_running, false
      state :job_progress, 0

      # ----------------------------------------------------------------- data
      state :room, "living"
      state :room_order, []
      state :device_filter, ""
      state :dynamic_count, 4
      state :drink_index, 2

      # -------------------------------------------------------------- drawing
      state :shader_amount, 0.6
      state :burst_revision, 0
      state :drag_position, "0, 0"
      state :hovering, false
      state :tap_state, "waiting for a tap"
      state :touch_points, 0
      state :wheel_value, 50
      state :point_position, "press and move"

      # --------------------------------------------------------------- motion
      state :sequence_running, false
      state :action_revision, 0
      state :spring_target, 50
      state :behavior_value, 1.0
      state :panel_state, "base"
      state :timer_ticks, 0
      state :frame_count, 0
      state :frame_counting, false
      state :scrub, 1.0
      state :blur_amount, 0.0

      # ---------------------------------------------------------------- media
      state :player_command, ""
      state :player_revision, 0
      state :player_state, "stopped"
      state :player_volume, 0.7
      state :player_muted, false
      state :player_position, 0
      state :player_duration, 0
      state :clip_command, ""
      state :clip_revision, 0
      state :cue_command, ""
      state :cue_revision, 0
      state :devices_revision, 0
      state :video_inputs, "—"
      state :audio_inputs, "—"
      state :audio_outputs, "—"
      state :camera_on, false
      state :camera_zoom, 1.0
      state :capture_revision, 0
      state :record_command, ""
      state :record_revision, 0
      state :recording, false
      state :record_duration, 0
      state :screen_capture_on, false
      state :window_capture_on, false

      # --------------------------------------------------------------- system
      state :model_filter, ""
      state :model_count, ROOMS.size
      state :folder_count, 0
      state :host_product, "resolving…"
      state :host_kernel, "resolving…"
      state :host_cpu, "resolving…"
      state :host_name, ""
      state :host_revision, 0
      state :network, "checking…"
      state :app_data, "resolving…"
      state :settings_revision, 0
      state :clipboard_text, ""
      state :clipboard_revision, 0
      state :keyboard_text, ""
      state :keyboard_active, false
      state :location_on, false
      state :latitude, 0.0
      state :longitude, 0.0
      state :accuracy, 0.0
      state :satellites, 0
      state :active_sensors, []
      state :sensor_readings, {}
      state :map_loaded, false
      state :web_loaded, false
      state :documents_loaded, false
      state :socket_on, false
      state :socket_status, "closed"
      state :socket_message, "—"
      state :speech_revision, 0

      PERMISSIONS.each do |type, _label, _glyph, _tone, _extra|
        state :"#{type}_revision", 0
        state :"#{type}_status", "not requested"
      end

      # ------------------------------------------------------------ demo apps
      state :launch_count, 0
      state :launch_status, "nothing launched yet"

      # ------------------------------------------------------------ the window
      app :main, title: "Zui Showcase · #{REGISTRY_COUNT} native components",
                 width: WINDOW_W, height: WINDOW_H, min_width: 1180, min_height: 720,
                 padding: WINDOW_PAD, color: INK do
        showcase_root
      end

      # The catalog marks every component the showcase actually renders. The
      # count comes from the finished node tree, never from a curated list.
      rendered = Showcase.eager? ? Showcase.rendered_types(@application.tree) : COVERAGE_TYPES
      transaction do
        state.live_types = rendered
        state.live_count = rendered.size
      end

      # The component registry is large enough that sending its table rows and
      # search suggestions inside the first render frame would push that frame
      # past the protocol's 1 MiB ceiling. They are pure data, so they arrive
      # as a patch immediately after the window appears instead.
      after(0.05) { state.catalog_ready = true }

      # One scheduler drives every "live" card in the application.
      every(1.0) do
        next unless state.live == true

        next_tick = state.tick.to_i + 1
        throughput = 56 + ((next_tick * 11) % 37)
        latency = 11 + ((next_tick * 7) % 9)
        progress = state.job_running ? [state.job_progress.to_i + 7, 100].min : state.job_progress.to_i

        transaction do
          state.tick = next_tick
          state.pulse = state.pulse.drop(1) + [throughput]
          state.latency = state.latency.drop(1) + [latency]
          state.job_progress = progress
          state.job_running = false if progress >= 100
        end
      end
    end
  end

  def self.run = build.run
end

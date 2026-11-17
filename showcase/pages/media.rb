# frozen_string_literal: true

module Showcase
  module UI
    def sc_page_media
      sc_page do
        sc_media_intro
        sc_row do
          sc_media_player
          sc_media_audio
          sc_media_devices
        end
        sc_row do
          sc_media_camera
          sc_media_recording
          sc_media_screen
        end
      end
    end

    def sc_media_intro
      card width: FULL_W, padding: 18, spacing: 12, color: PANEL, border_color: BORDER,
           accent: ROSE do
        row spacing: 14 do
          sc_tile(:music, accent: ROSE)
          column spacing: 2, width: 620 do
            text "Qt Multimedia, declared in Ruby", size: 16, bold: true, color: WHITE,
                 wrap: false
            sc_caption("Playback, capture and device enumeration are components with a " \
                       "`command` and a `command_revision`: Ruby bumps the revision, the " \
                       "renderer performs the action exactly once. Nothing here starts your " \
                       "camera, microphone or screen until you switch it on.",
                       width: 620, size: 11)
          end
          spacer width: 120, height: 1
          sc_stat("COMPONENTS", 12, ROSE, width: 110)
          sc_stat("AUTO-STARTED", 0, MINT, width: 130)
        end
      end
    end

    def sc_media_player
      sc_card("Media player", "Real transport over a bundled track", glyph: :play,
              accent: ROSE, tags: %w[media_player video_output audio_output]) do
        player = media_player Showcase.asset(:track_audio), auto_play: false, loops: 1,
                              playback_rate: 1.0, volume: 0.7, muted: false, command: "",
                              command_revision: 0
        bind(player, :command) { state.player_command.to_s }
        bind(player, :command_revision) { state.player_revision.to_i }
        bind(player, :volume) { state.player_volume.to_f }
        bind(player, :muted) { state.player_muted == true }
        on(player, :play) { sc_media_state("playing") }
        on(player, :pause) { sc_media_state("paused") }
        on(player, :stop) { sc_media_state("stopped") }
        on(player, :duration) { |event| state.player_duration = event["value"].to_i }
        on(player, :position) { |event| state.player_position = event["value"].to_i }
        on(player, :error) { |event| sc_log("player: #{event["message"]}") }

        row spacing: 8 do
          [["Play", :play, "play", MINT], ["Pause", :pause, "pause", GOLD],
           ["Stop", :stop, "stop", ROSE]].each do |label, glyph, command, tone|
            button label, icon: glyph, width: 104, height: 38, bordered: true,
                   foreground: WHITE, background: PANEL_ALT, accent: tone, font_size: 11 do
              sc_media_command(command)
            end
          end
        end
        position = progress 0, minimum: 0, maximum: 100, width: CARD_BODY_W, height: 6,
                            color: ROSE
        bind(position, :value) do
          duration = state.player_duration.to_i
          duration.positive? ? (state.player_position.to_i * 100 / duration) : 0
        end
        elapsed = sc_kv("Position", "0:00 / 0:00", accent: ROSE, key_width: 110)
        bind(elapsed, :text) do
          "#{sc_media_time(state.player_position)} / #{sc_media_time(state.player_duration)}"
        end
        status = sc_kv("Transport", "stopped", accent: MUTED, key_width: 110)
        bind(status, :text) { state.player_state.to_s }
        row spacing: 10 do
          level = slider 70, minimum: 0, maximum: 100, step: 1, integer: true,
                         track_color: PANEL_ALT, fill_color: ROSE, knob_color: WHITE,
                         track_height: 6, knob_size: 16 do |event|
            state.player_volume = event["value"].to_f / 100.0
          end
          bind(level, :value) { (state.player_volume.to_f * 100).round }
          mute = bar_indicator :volume_high, inactive_icon: :volume_off,
                               active_tooltip: "Mute", inactive_tooltip: "Unmute",
                               foreground: MUTED, active_color: ROSE do
            state.player_muted = !state.player_muted
          end
          bind(mute, :active) { state.player_muted != true }
        end
        sc_eyebrow("VIDEO_OUTPUT · attach a player to a surface")
        video_output player, fill_mode: :preserve_aspect_fit, orientation: 0, mirrored: false,
                     width: CARD_BODY_W, height: 76
        audio_output volume: 0.7, muted: false
      end
    end

    def sc_media_command(command)
      transaction do
        state.player_command = command
        state.player_revision = state.player_revision.to_i + 1
        state.activity = "media_player ← #{command}"
      end
    end

    def sc_media_state(name)
      transaction do
        state.player_state = name
        state.activity = "Transport #{name}"
      end
    end

    def sc_media_time(milliseconds)
      total = milliseconds.to_i / 1000
      seconds = total % 60
      "#{total / 60}:#{seconds < 10 ? "0#{seconds}" : seconds}"
    end

    def sc_media_audio
      sc_card("Audio and sound effects", "Streaming audio and low-latency cues", glyph: :music,
              accent: MINT, tags: %w[audio sound_effect audio_input]) do
        sc_eyebrow("AUDIO · the simple component")
        clip = audio Showcase.asset(:cockpit_audio), auto_play: false, loops: 1, volume: 0.6,
                     muted: false, playback_rate: 1.0, playback: "", seek_revision: 0
        bind(clip, :playback) { state.clip_command.to_s }
        bind(clip, :seek_revision) { state.clip_revision.to_i }
        on(clip, :play) { sc_log("audio playing") }
        on(clip, :end) { sc_log("audio finished") }
        on(clip, :error) { |event| sc_log("audio: #{event["message"]}") }
        row spacing: 8 do
          [["Play", "play", MINT], ["Pause", "pause", GOLD], ["Stop", "stop", ROSE]].each do |label, command, tone|
            button label, width: 104, height: 36, bordered: true, foreground: WHITE,
                   background: PANEL_ALT, accent: tone, font_size: 11 do
              transaction do
                state.clip_command = command
                state.clip_revision = state.clip_revision.to_i + 1
                state.activity = "audio ← #{command}"
              end
            end
          end
        end
        sc_eyebrow("SOUND_EFFECT · fire and forget")
        cue = sound_effect Showcase.asset(:cockpit_audio), loops: 1, volume: 0.5, muted: false,
                           playback: "", command: "", command_revision: 0
        bind(cue, :command) { state.cue_command.to_s }
        bind(cue, :command_revision) { state.cue_revision.to_i }
        on(cue, :play) { sc_log("sound_effect played") }
        button "Trigger the cue", icon: :bell, width: CARD_BODY_W, height: 38, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: MINT, font_size: 11 do
          transaction do
            state.cue_command = "play"
            state.cue_revision = state.cue_revision.to_i + 1
            state.activity = "sound_effect triggered"
          end
        end
        sc_eyebrow("AUDIO_INPUT · declared, muted")
        audio_input muted: true, volume: 0.0
        sc_caption("audio_input is declared here with `muted: true` so nothing listens until " \
                   "you change it.", size: 10)
      end
    end

    def sc_media_devices
      sc_card("Device enumeration", "Ask the platform what exists", glyph: :gear, accent: CYAN,
              tags: %w[media_devices audio_output]) do
        devices = media_devices kind: :all, refresh_revision: 0
        bind(devices, :refresh_revision) { state.devices_revision.to_i }
        on(devices, :video_inputs) do |event|
          state.video_inputs = Array(event["values"]).size
        end
        on(devices, :audio_inputs) do |event|
          state.audio_inputs = Array(event["values"]).size
        end
        on(devices, :audio_outputs) do |event|
          state.audio_outputs = Array(event["values"]).size
        end
        row spacing: 10 do
          cameras = sc_stat("CAMERAS", "—", CYAN, width: 100)
          bind(cameras, :text) { state.video_inputs.to_s }
          mics = sc_stat("INPUTS", "—", MINT, width: 100)
          bind(mics, :text) { state.audio_inputs.to_s }
          outs = sc_stat("OUTPUTS", "—", VIOLET, width: 110)
          bind(outs, :text) { state.audio_outputs.to_s }
        end
        button "Refresh devices", icon: :refresh, width: CARD_BODY_W, height: 40,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: CYAN,
               font_size: 12 do
          transaction do
            state.devices_revision = state.devices_revision.to_i + 1
            state.activity = "Enumerated media devices"
          end
        end
        sc_caption("The counts above come from the host's real device list. On a machine with " \
                   "no camera the camera count is zero and the capture card below reports it " \
                   "instead of pretending.")
      end
    end

    def sc_media_camera
      sc_card("Camera", "Opt-in preview through a capture session", glyph: :camera,
              accent: VIOLET, tags: %w[camera capture_session video_output]) do
        session = capture_session camera_active: false, camera_enabled: true,
                                  audio_input_enabled: false, video_output_enabled: true,
                                  width: CARD_BODY_W, height: 180
        @sc_capture_session = session
        bind(session, :camera_active) { state.camera_on == true }
        on(session, :error) { |event| sc_log("capture: #{event["message"]}") }
        on(session, :ready) { sc_log("Capture session ready") }
        lens = camera active: false, focus_mode: :auto, flash_mode: :off, torch_mode: :off,
                      exposure_mode: :auto, zoom_factor: 1.0, command: "",
                      command_revision: 0
        bind(lens, :active) { state.camera_on == true }
        on(lens, :error) { |event| sc_log("camera: #{event["message"]}") }
        switch = toggle "Enable the camera", description: "Starts a real capture session",
                        checked: false, accent: VIOLET, foreground: WHITE, title_size: 12,
                        description_size: 10 do |event|
          state.camera_on = event["value"] != false
          sc_log(state.camera_on ? "Camera requested" : "Camera stopped")
        end
        bind(switch, :checked) { state.camera_on == true }
        zoom = slider 1.0, minimum: 1.0, maximum: 4.0, step: 0.1, track_color: PANEL_ALT,
                      fill_color: VIOLET, knob_color: WHITE, track_height: 6,
                      knob_size: 16 do |event|
          state.camera_zoom = event["value"].to_f
        end
        bind(zoom, :value) { state.camera_zoom.to_f }
        bind(lens, :zoom_factor) { state.camera_zoom.to_f }
        level = sc_kv("Zoom", "1.0x", accent: VIOLET, key_width: 110)
        bind(level, :text) { "#{state.camera_zoom.to_f.round(1)}x" }
      end
    end

    def sc_media_recording
      sc_card("Capture and record", "Stills and recordings from the same session",
              glyph: :save, accent: GOLD, tags: %w[image_capture media_recorder]) do
        capture = image_capture @sc_capture_session, quality: :high, format: :jpeg,
                                command: "", path: "", command_revision: 0
        bind(capture, :command_revision) { state.capture_revision.to_i }
        bind(capture, :command) { "capture" }
        on(capture, :captured) { sc_log("Still captured") }
        on(capture, :saved) { |event| sc_log("Saved #{event["path"] || event["value"]}") }
        on(capture, :error) { |event| sc_log("capture: #{event["message"]}") }
        recorder = media_recorder @sc_capture_session, quality: :high, frame_rate: 30,
                                  video_codec: :h264, audio_codec: :aac, media_format: :mpeg4,
                                  command: "", command_revision: 0
        bind(recorder, :command_revision) { state.record_revision.to_i }
        bind(recorder, :command) { state.record_command.to_s }
        on(recorder, :record) { state.recording = true }
        on(recorder, :stop) { state.recording = false }
        on(recorder, :duration) { |event| state.record_duration = event["value"].to_i / 1000 }
        on(recorder, :error) { |event| sc_log("recorder: #{event["message"]}") }
        button "Capture a still", icon: :camera, width: CARD_BODY_W, height: 40,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: GOLD,
               font_size: 12 do
          transaction do
            state.capture_revision = state.capture_revision.to_i + 1
            state.activity = "image_capture requested"
          end
        end
        row spacing: 8 do
          button "Record", icon: :play, width: 160, height: 38, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: ROSE, font_size: 11 do
            sc_record_command("record")
          end
          button "Stop", icon: :stop, width: 150, height: 38, bordered: true,
                 foreground: WHITE, background: PANEL_ALT, accent: FAINT, font_size: 11 do
            sc_record_command("stop")
          end
        end
        status = sc_kv("Recorder", "idle", accent: ROSE, key_width: 110)
        bind(status, :text) do
          state.recording ? "recording · #{state.record_duration.to_i}s" : "idle"
        end
        sc_caption("Both components report real platform errors. Without a granted camera or " \
                   "microphone the error lands in the activity strip instead of being swallowed.",
                   size: 10)
      end
    end

    def sc_record_command(command)
      transaction do
        state.record_command = command
        state.record_revision = state.record_revision.to_i + 1
        state.activity = "media_recorder ← #{command}"
      end
    end

    def sc_media_screen
      sc_card("Screen and window capture", "Opt-in, revision driven", glyph: :terminal,
              accent: MINT, tags: %w[screen_capture window_capture]) do
        screen = screen_capture active: false, command: "", command_revision: 0
        bind(screen, :active) { state.screen_capture_on == true }
        on(screen, :start) { sc_log("Screen capture started") }
        on(screen, :stop) { sc_log("Screen capture stopped") }
        on(screen, :error) { |event| sc_log("screen_capture: #{event["message"]}") }
        window = window_capture active: false, command: "", command_revision: 0
        bind(window, :active) { state.window_capture_on == true }
        on(window, :error) { |event| sc_log("window_capture: #{event["message"]}") }
        [["Capture the screen", :screen_capture_on, MINT],
         ["Capture a window", :window_capture_on, CYAN]].each do |label, key, tone|
          switch = toggle label, description: "Off by default", checked: false, accent: tone,
                          foreground: WHITE, title_size: 12, description_size: 10 do |event|
            state.public_send("#{key}=", event["value"] != false)
            sc_log("#{label}: #{event["value"] != false ? "on" : "off"}")
          end
          bind(switch, :checked) { state.public_send(key) == true }
        end
        sc_rule
        sc_caption("Screen and window capture need the platform's screen-recording permission. " \
                   "Zui surfaces the refusal as an error event rather than rendering a blank " \
                   "rectangle.")
      end
    end
  end
end

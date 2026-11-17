# frozen_string_literal: true

module Showcase
  SENSORS = [
    [:accelerometer, "Accelerometer", :arrow_down],
    [:gyroscope, "Gyroscope", :refresh],
    [:magnetometer, "Magnetometer", :globe],
    [:compass, "Compass", :location],
    [:orientation_sensor, "Orientation", :phone],
    [:rotation_sensor, "Rotation", :refresh],
    [:tilt_sensor, "Tilt", :arrow_up],
    [:tap_sensor, "Tap", :check],
    [:light_sensor, "Light", :eye],
    [:ambient_light_sensor, "Ambient light", :eye],
    [:ambient_temperature_sensor, "Ambient temp", :clock],
    [:humidity_sensor, "Humidity", :info],
    [:pressure_sensor, "Pressure", :info],
    [:proximity_sensor, "Proximity", :pin],
    [:ir_proximity_sensor, "IR proximity", :pin],
    [:lid_sensor, "Lid", :lock]
  ].freeze

  PERMISSIONS = [
    [:camera_permission, "Camera", :camera, Showcase::CYAN, {}],
    [:microphone_permission, "Microphone", :volume_high, Showcase::MINT, {}],
    [:location_permission, "Location", :location, Showcase::VIOLET,
     { availability: :when_in_use, accuracy: :precise }],
    [:bluetooth_permission, "Bluetooth", :bluetooth, Showcase::GOLD,
     { communication_modes: [:access] }],
    [:contacts_permission, "Contacts", :user, Showcase::ROSE, { access_mode: :read_write }],
    [:calendar_permission, "Calendar", :calendar, Showcase::AMBER, { access_mode: :full }]
  ].freeze

  module UI
    def sc_page_system
      sc_page do
        sc_row do
          sc_system_models
          sc_system_platform
          sc_system_storage
        end
        sc_row do
          sc_system_permissions
          sc_system_keyboard
          sc_system_positioning
        end
        sc_system_sensors
        sc_row do
          sc_system_map
          sc_system_web
          sc_system_documents
        end
      end
    end

    # ----------------------------------------------------------------- models
    def sc_system_models
      sc_card("Models", "Rows without a view, filtered in place", glyph: :folder, accent: CYAN,
              tags: %w[list_model delegate_model delegate_model_group sort_filter_proxy_model
                       folder_list_model]) do
        list_model ROOMS, revision: 1
        delegate_model ROOMS, filter_group: "items", revision: 1
        delegate_model_group ROOMS, name: "selected", include_by_default: false, revision: 1
        sc_eyebrow("SORT_FILTER_PROXY_MODEL · live")
        query = text_field "", placeholder: "Filter rooms by label…", width: CARD_BODY_W,
                           height: 42, foreground: WHITE, accent: CYAN, selection_tint: TINT,
                           horizontal_padding: 12 do |event|
          state.model_filter = event["value"].to_s
        end
        bind(query, :text) { state.model_filter.to_s }
        proxy = sort_filter_proxy_model ROOMS, filter: "", filter_field: "label",
                                        filter_case_sensitive: false, sort_field: "label",
                                        sort_order: :ascending, dynamic: true, revision: 1
        bind(proxy, :filter) { state.model_filter.to_s }
        on(proxy, :count_change) { |event| state.model_count = event["value"].to_i }
        matched = sc_kv("Proxy rows", ROOMS.size.to_s, accent: CYAN, key_width: 110)
        bind(matched, :text) { state.model_count.to_s }
        sc_eyebrow("FOLDER_LIST_MODEL · the demos directory")
        folders = folder_list_model "demos", name_filters: ["*"], show_files: false,
                                   show_dirs: true, show_dirs_first: true,
                                   show_dot_and_dot_dot: false, show_hidden: false,
                                   sort_field: :name, revision: 1
        on(folders, :count_change) { |event| state.folder_count = event["value"].to_i }
        on(folders, :error) { |event| sc_log("folder_list_model: #{event["message"]}") }
        counted = sc_kv("Demo folders", DEMOS.size.to_s, accent: MINT, key_width: 110)
        bind(counted, :text) { state.folder_count.to_i.positive? ? state.folder_count.to_s : "—" }
      end
    end

    def sc_system_platform
      sc_card("This machine", "Real values from the host", glyph: :terminal, accent: MINT,
              tags: %w[system_info network_status]) do
        info = system_info refresh_revision: 0
        on(info, :information) do |event|
          transaction do
            state.host_product = event["pretty_product_name"].to_s
            state.host_kernel = "#{event["kernel_type"]} #{event["kernel_version"]}"
            state.host_cpu = event["current_cpu_architecture"].to_s
            state.host_name = event["machine_host_name"].to_s
          end
        end
        on(info, :error) { |event| sc_log("system_info: #{event["message"]}") }
        product = sc_kv("Product", "resolving…", accent: MINT, key_width: 96)
        bind(product, :text) { state.host_product.to_s }
        kernel = sc_kv("Kernel", "resolving…", accent: MUTED, key_width: 96)
        bind(kernel, :text) { state.host_kernel.to_s }
        cpu = sc_kv("CPU", "resolving…", accent: CYAN, key_width: 96)
        bind(cpu, :text) { state.host_cpu.to_s }
        sc_rule
        network = network_status watch: true, refresh_revision: 0
        on(network, :information) { |event| state.network = event["reachability"].to_s }
        on(network, :change) { |event| state.network = event["reachability"].to_s }
        on(network, :error) { |event| sc_log("network_status: #{event["message"]}") }
        reach = sc_kv("Reachability", "checking…", accent: VIOLET, key_width: 96)
        bind(reach, :text) { state.network.to_s }
        button "Refresh", icon: :refresh, width: CARD_BODY_W, height: 38, bordered: true,
               foreground: WHITE, background: PANEL_ALT, accent: MINT, font_size: 11 do
          transaction do
            state.host_revision = state.host_revision.to_i + 1
            state.activity = "Re-read system information"
          end
        end
        bind(info, :refresh_revision) { state.host_revision.to_i }
        bind(network, :refresh_revision) { state.host_revision.to_i }
      end
    end

    def sc_system_storage
      sc_card("Paths, settings and clipboard", "Where an app may write", glyph: :save,
              accent: VIOLET, tags: %w[standard_paths settings clipboard]) do
        paths = standard_paths :app_data, refresh_revision: 0
        on(paths, :resolved) do |event|
          state.app_data = Array(event["locations"]).first.to_s
        end
        on(paths, :error) { |event| sc_log("standard_paths: #{event["message"]}") }
        resolved = sc_caption("resolving…", width: CARD_BODY_W, size: 10, color: VIOLET)
        bind(resolved, :text) { state.app_data.to_s }
        sc_eyebrow("SETTINGS · persisted key/values")
        store = settings({ "scene" => "Focus", "brightness" => 68 },
                         category: "showcase", sync_revision: 0)
        bind(store, :values) do
          { "scene" => state.scene.to_s, "brightness" => state.brightness.to_i }
        end
        bind(store, :sync_revision) { state.settings_revision.to_i }
        on(store, :synced) { sc_log("Settings written") }
        on(store, :error) { |event| sc_log("settings: #{event["message"]}") }
        button "Persist the current scene", icon: :save, width: CARD_BODY_W, height: 38,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: VIOLET,
               font_size: 11 do
          transaction do
            state.settings_revision = state.settings_revision.to_i + 1
            state.activity = "Settings synced"
          end
        end
        sc_eyebrow("CLIPBOARD")
        board = clipboard "", watch: false, revision: 0
        bind(board, :text) { state.clipboard_text.to_s }
        bind(board, :revision) { state.clipboard_revision.to_i }
        on(board, :copied) { sc_log("Copied to the clipboard") }
        button "Copy a status line", icon: :copy, width: CARD_BODY_W, height: 38,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: CYAN,
               font_size: 11 do
          transaction do
            state.clipboard_text = "Zui #{Zui::VERSION} · #{REGISTRY_COUNT} components · " \
                                   "scene #{state.scene}"
            state.clipboard_revision = state.clipboard_revision.to_i + 1
            state.activity = "Status line copied"
          end
        end
      end
    end

    # ------------------------------------------------------------ permissions
    def sc_system_permissions
      sc_card("Permissions", "Six protected capabilities, never auto-requested",
              glyph: :lock, accent: ROSE,
              tags: %w[camera_permission microphone_permission location_permission
                       bluetooth_permission contacts_permission calendar_permission]) do
        PERMISSIONS.each do |type, label, glyph, tone, extra|
          node = public_send(type, **extra.merge(auto_request: false, request_revision: 0))
          key = "#{type}_revision"
          bind(node, :request_revision) { state.public_send(key).to_i }
          on(node, :change) do |event|
            state.public_send("#{type}_status=",
                              (event["status"] || event["value"] || "changed").to_s)
          end
          on(node, :granted) { state.public_send("#{type}_status=", "granted") }
          on(node, :denied) { state.public_send("#{type}_status=", "denied") }
          on(node, :error) { |event| sc_log("#{label}: #{event["message"]}") }
          row spacing: 10, width: CARD_BODY_W do
            sc_tile(glyph, accent: tone, size: 34, radius: 10, glyph_size: 14)
            column spacing: 1, width: 150 do
              sc_value(label, color: WHITE, size: 12)
              status = text "not requested", size: 10, color: FAINT, wrap: false
              bind(status, :text) { state.public_send("#{type}_status").to_s }
            end
            button "Request", width: 104, height: 34, bordered: true, foreground: WHITE,
                   background: PANEL_ALT, accent: tone, font_size: 11 do
              transaction do
                state.public_send("#{key}=", state.public_send(key).to_i + 1)
                state.activity = "#{label} permission requested"
              end
            end
          end
        end
      end
    end

    # --------------------------------------------------------------- keyboard
    def sc_system_keyboard
      sc_card("Virtual keyboard", "The mobile input stack, declared", glyph: :edit,
              accent: GOLD, tags: %w[virtual_keyboard handwriting_input keyboard_context
                                     keyboard_settings keyboard_text_field]) do
        typed = keyboard_text_field "", placeholder: "Keyboard-aware field", enter_key: :done,
                                   enter_key_label: "Done", enter_key_enabled: true,
                                   input_method_hints: [:no_predictive_text],
                                   width: CARD_BODY_W, height: 46 do |event|
          state.keyboard_text = event["value"].to_s
        end
        bind(typed, :text) { state.keyboard_text.to_s }
        on(typed, :accept) { sc_log("Keyboard field accepted") }
        on(typed, :error) { |event| sc_log("keyboard_text_field: #{event["message"]}") }
        echo = sc_kv("Characters", "0", accent: GOLD, key_width: 110)
        bind(echo, :text) { state.keyboard_text.to_s.length.to_s }
        keyboard = virtual_keyboard active: false, external_language_switch: false, z: 2000
        bind(keyboard, :active) { state.keyboard_active == true }
        on(keyboard, :active_change) { |event| state.keyboard_active = event["value"] == true }
        on(keyboard, :error) { |event| sc_log("virtual_keyboard: #{event["message"]}") }
        switch = toggle "Show the virtual keyboard", description: "Mobile and touch hosts",
                        checked: false, accent: GOLD, foreground: WHITE, title_size: 12,
                        description_size: 10 do |event|
          state.keyboard_active = event["value"] != false
        end
        bind(switch, :checked) { state.keyboard_active == true }
        handwriting_input available: false, active: false, width: CARD_BODY_W, height: 1,
                          z: 1999
        keyboard_settings style: "default", locale: "en_US", full_screen_mode: false,
                          close_on_return: true, refresh_revision: 0
        context = keyboard_context watch: true, command: "", command_revision: 0
        on(context, :change) { |event| sc_log("keyboard locale #{event["locale"]}") if event["locale"] }
        sc_caption("These five components are mobile-first. On desktop they declare cleanly " \
                   "and stay inert, which is why the mobile demos share this exact code.",
                   size: 10)
      end
    end

    # ------------------------------------------------------------ positioning
    def sc_system_positioning
      sc_card("Positioning", "GPS and satellites, opt-in", glyph: :location, accent: MINT,
              tags: %w[position_source satellite_source location_permission]) do
        source = position_source active: false, update_interval: 2000,
                                 preferred_methods: [:all], refresh_revision: 0
        bind(source, :active) { state.location_on == true }
        on(source, :position) do |event|
          transaction do
            state.latitude = event["latitude"].to_f
            state.longitude = event["longitude"].to_f
            state.accuracy = event["horizontal_accuracy"].to_f
          end
        end
        on(source, :error) { |event| sc_log("position_source: #{event["message"]}") }
        satellites = satellite_source active: false, update_interval: 5000,
                                      refresh_revision: 0
        bind(satellites, :active) { state.location_on == true }
        on(satellites, :in_view) { |event| state.satellites = Array(event["values"]).size }
        on(satellites, :error) { |event| sc_log("satellite_source: #{event["message"]}") }
        switch = toggle "Enable positioning", description: "Requests the platform permission",
                        checked: false, accent: MINT, foreground: WHITE, title_size: 12,
                        description_size: 10 do |event|
          state.location_on = event["value"] != false
          sc_log(state.location_on ? "Positioning on" : "Positioning off")
        end
        bind(switch, :checked) { state.location_on == true }
        coords = sc_kv("Latitude", "—", accent: MINT, key_width: 110)
        bind(coords, :text) { state.latitude.to_f.round(5).to_s }
        longitude = sc_kv("Longitude", "—", accent: MINT, key_width: 110)
        bind(longitude, :text) { state.longitude.to_f.round(5).to_s }
        accuracy = sc_kv("Accuracy", "—", accent: MUTED, key_width: 110)
        bind(accuracy, :text) { "#{state.accuracy.to_f.round(1)} m" }
        seen = sc_kv("Satellites in view", "—", accent: CYAN, key_width: 110)
        bind(seen, :text) { state.satellites.to_i.to_s }
      end
    end

    # ---------------------------------------------------------------- sensors
    def sc_system_sensors
      card width: FULL_W, padding: 18, spacing: 14, color: PANEL, border_color: BORDER,
           accent: CYAN do
        row spacing: 14 do
          sc_tile(:phone, accent: CYAN)
          column spacing: 2, width: 560 do
            text "Sensors", size: 16, bold: true, color: WHITE, wrap: false
            sc_caption("All #{SENSORS.size} sensor components, each with its own activation " \
                       "switch. A sensor the host does not have reports an error instead of " \
                       "inventing a reading.", width: 560, size: 11)
          end
          spacer width: 180, height: 1
          active = sc_stat("ACTIVE", "0", CYAN, width: 100)
          bind(active, :text) { Array(state.active_sensors).size.to_s }
          sc_stat("DECLARED", SENSORS.size, MINT, width: 110)
        end
        wrap width: FULL_W - 36, spacing: 10 do
          SENSORS.each_with_index do |(type, label, glyph), index|
            tone = ACCENTS[index % ACCENTS.size]
            node = public_send(type, active: false, always_on: false, data_rate: 10,
                               skip_duplicates: true, refresh_revision: 0)
            bind(node, :active) { Array(state.active_sensors).include?(type.to_s) }
            on(node, :reading) { |event| sc_sensor_reading(type, event) }
            on(node, :error) { |event| sc_log("#{label}: #{event["message"]}") }
            rectangle width: 256, height: 92, radius: 12, padding: 12, color: PANEL_ALT,
                      border_color: BORDER_SOFT, border_width: 1 do
              column spacing: 6, width: 228 do
                row spacing: 8 do
                  sc_tile(glyph, accent: tone, size: 26, radius: 8, glyph_size: 12)
                  column spacing: 0, width: 128 do
                    sc_value(label, color: WHITE, size: 11)
                    reading = text "idle", size: 9, color: FAINT, width: 128, wrap: false
                    bind(reading, :text) { state.sensor_readings.to_h.fetch(type.to_s, "idle") }
                  end
                  flip = toggle_switch checked: false, accent: tone, foreground: WHITE,
                                       track_width: 36, track_height: 18, knob_size: 14 do |event|
                    sc_toggle_sensor(type, event["value"] != false)
                  end
                  bind(flip, :checked) { Array(state.active_sensors).include?(type.to_s) }
                end
              end
            end
          end
        end
      end
    end

    def sc_toggle_sensor(type, enabled)
      current = Array(state.active_sensors)
      next_list = enabled ? (current + [type.to_s]).uniq : current - [type.to_s]
      transaction do
        state.active_sensors = next_list
        state.activity = "#{type} #{enabled ? "activated" : "stopped"}"
      end
    end

    def sc_sensor_reading(type, event)
      fields = event.reject { |key, _| key == "timestamp" }
      summary = fields.first(2).map do |key, value|
        formatted = value.is_a?(Float) ? value.round(2) : value
        "#{key} #{formatted}"
      end.join(" · ")
      readings = state.sensor_readings.to_h.merge(type.to_s => summary.empty? ? "reading" : summary)
      state.sensor_readings = readings
    end

    # ------------------------------------------------------------------- maps
    def sc_system_map
      sc_card("Maps", "QtLocation, loaded on demand", glyph: :globe, accent: VIOLET,
              tags: %w[map map_marker map_circle map_polyline map_item_view map_copyright]) do
        switch = toggle "Load the map", description: "Needs the QtLocation Qt module",
                        checked: false, accent: VIOLET, foreground: WHITE, title_size: 12,
                        description_size: 10 do |event|
          state.map_loaded = event["value"] != false
          sc_log(state.map_loaded ? "Map requested" : "Map unloaded")
        end
        bind(switch, :checked) { state.map_loaded == true }
        holder = loader width: CARD_BODY_W, height: 220, active: false do
          map plugin: "osm", latitude: 37.3349, longitude: -122.009, zoom: 12,
              minimum_zoom: 2, maximum_zoom: 18, map_type: 0, bearing: 0, tilt: 0,
              gesture_enabled: true, copyrights_visible: true, width: CARD_BODY_W,
              height: 220 do
            map_circle latitude: 37.3349, longitude: -122.009, radius: 900, color: "#5558d7ff",
                       border_color: CYAN, border_width: 2, opacity: 0.8
            map_polyline [{ "latitude" => 37.3349, "longitude" => -122.009 },
                          { "latitude" => 37.3421, "longitude" => -122.021 },
                          { "latitude" => 37.3512, "longitude" => -122.004 }],
                         color: VIOLET, width: 3, opacity: 0.9
            map_rectangle top_left: { "latitude" => 37.352, "longitude" => -122.03 },
                          bottom_right: { "latitude" => 37.340, "longitude" => -122.012 },
                          color: "#335df2b4", border_color: MINT, border_width: 1,
                          opacity: 0.7
            map_polygon [{ "latitude" => 37.3301, "longitude" => -122.001 },
                         { "latitude" => 37.3338, "longitude" => -121.992 },
                         { "latitude" => 37.3272, "longitude" => -121.988 }],
                        color: "#33ffcd6b", border_color: GOLD, border_width: 1, opacity: 0.7
            map_route [{ "latitude" => 37.3349, "longitude" => -122.009 },
                       { "latitude" => 37.3400, "longitude" => -121.995 },
                       { "latitude" => 37.3465, "longitude" => -121.985 }],
                      color: ROSE, width: 4, opacity: 0.85
            map_item_group do
              map_marker latitude: 37.3480, longitude: -122.028, anchor_x: 0.5,
                         anchor_y: 1.0, auto_fade_in: true, width: 18, height: 18 do
                rectangle width: 18, height: 18, radius: 9, color: GOLD
              end
            end
            map_item_view [{ "latitude" => 37.3290, "longitude" => -122.021,
                             "label" => "Depot" },
                           { "latitude" => 37.3375, "longitude" => -122.034,
                             "label" => "Hub" }],
                          latitude_field: :latitude, longitude_field: :longitude,
                          label_field: :label, marker_width: 16, marker_height: 16,
                          marker_color: CYAN
            map_marker latitude: 37.3349, longitude: -122.009, anchor_x: 0.5, anchor_y: 1.0,
                       auto_fade_in: true, width: 26, height: 26 do
              rectangle width: 26, height: 26, radius: 13, color: ROSE
            end
            map_copyright width: CARD_BODY_W, height: 18
          end
        end
        bind(holder, :active) { state.map_loaded == true }
        on(holder, :error) { sc_log("The map could not load; QtLocation may be missing") }
        sc_caption("Maps, places and routing are declared like any other component. They are " \
                   "behind a loader here because QtLocation is an optional Qt module.",
                   size: 10)
        sc_eyebrow("PLACES, GEOCODING AND ROUTING MODELS")
        models = loader width: CARD_BODY_W, height: 1, active: false do
          column spacing: 0, width: CARD_BODY_W do
            geo_json_data nil, command: "", command_revision: 0
            geocode_model "Cupertino", plugin: "osm", limit: 5, auto_update: false,
                          command: "", command_revision: 0
            route_model [{ "latitude" => 37.3349, "longitude" => -122.009 },
                         { "latitude" => 37.3465, "longitude" => -121.985 }],
                        plugin: "osm", travel_mode: :car, optimization: :fastest,
                        alternatives: 1, auto_update: false, command: "",
                        command_revision: 0
            place_search "coffee", plugin: "osm", limit: 10, command: "",
                         command_revision: 0
            place_suggestions "cof", plugin: "osm", limit: 5, command: "",
                              command_revision: 0
            place_categories plugin: "osm", hierarchical: false, command: "",
                             command_revision: 0
            place_details nil, plugin: "osm", command: "", command_revision: 0
            place_category nil, plugin: "osm", command: "", command_revision: 0
          end
        end
        bind(models, :active) { state.map_loaded == true }
        sc_caption("Eight non-visual QtLocation models are declared with the map: geocoding, " \
                   "routing, place search, suggestions, categories and details. They load " \
                   "with the same switch.", size: 10)
      end
    end

    # -------------------------------------------------------------------- web
    def sc_system_web
      sc_card("Web and sockets", "Optional modules, explicit failures", glyph: :link,
              accent: CYAN, tags: %w[web_view web_socket web_socket_server]) do
        switch = toggle "Load a web view", description: "Needs the QtWebView Qt module",
                        checked: false, accent: CYAN, foreground: WHITE, title_size: 12,
                        description_size: 10 do |event|
          state.web_loaded = event["value"] != false
        end
        bind(switch, :checked) { state.web_loaded == true }
        holder = loader width: CARD_BODY_W, height: 200, active: false do
          web_view "https://zui.alkimist.dev", javascript: true, local_storage: false,
                   width: CARD_BODY_W, height: 200
        end
        bind(holder, :active) { state.web_loaded == true }
        on(holder, :error) { sc_log("The web view could not load; QtWebView may be missing") }
        sc_eyebrow("WEB_SOCKET · connect on demand")
        socket = web_socket "wss://echo.websocket.events", active: false, message: "",
                            command: "", command_revision: 0
        bind(socket, :active) { state.socket_on == true }
        on(socket, :message) { |event| state.socket_message = event["value"].to_s }
        on(socket, :status) { |event| state.socket_status = event["value"].to_s }
        on(socket, :error) { |event| sc_log("web_socket: #{event["message"]}") }
        connect = toggle "Open the socket", description: "Connects to a public echo service",
                         checked: false, accent: MINT, foreground: WHITE, title_size: 12,
                         description_size: 10 do |event|
          state.socket_on = event["value"] != false
          sc_log(state.socket_on ? "Socket opening" : "Socket closed")
        end
        bind(connect, :checked) { state.socket_on == true }
        status = sc_kv("Socket status", "closed", accent: MINT, key_width: 110)
        bind(status, :text) { state.socket_status.to_s }
        last = sc_kv("Last frame", "—", accent: CYAN, key_width: 110)
        bind(last, :text) { state.socket_message.to_s }
        web_socket_server host: "127.0.0.1", port: 0, name: "showcase", listen: false,
                          accept: false
        sc_caption("web_socket_server is declared with `listen: false`: the showcase never " \
                   "opens a port unless you ask it to.", size: 10)
      end
    end

    def sc_system_documents
      sc_card("Documents and vector animation", "PDF and Lottie, on demand", glyph: :file,
              accent: GOLD, tags: %w[pdf_view lottie_animation text_to_speech]) do
        sc_eyebrow("TEXT_TO_SPEECH")
        speech = text_to_speech "", volume: 0.8, rate: 0.0, pitch: 0.0, locale: "en_US",
                                auto_speak: false, command: "", command_revision: 0
        bind(speech, :text) do
          "Zui registers #{REGISTRY_COUNT} components across #{CATEGORY_ORDER.size} categories."
        end
        bind(speech, :command) { "say" }
        bind(speech, :command_revision) { state.speech_revision.to_i }
        on(speech, :state) { |event| sc_log("speech #{event["value"]}") }
        on(speech, :error) { |event| sc_log("text_to_speech: #{event["message"]}") }
        button "Speak the catalog size", icon: :volume_high, width: CARD_BODY_W, height: 40,
               bordered: true, foreground: WHITE, background: PANEL_ALT, accent: GOLD,
               font_size: 12 do
          transaction do
            state.speech_revision = state.speech_revision.to_i + 1
            state.activity = "Spoke the catalog size"
          end
        end
        sc_eyebrow("LOTTIE_ANIMATION · PDF_VIEW")
        switch = toggle "Load the document components",
                        description: "Needs the Lottie and QtPdf Qt modules", checked: false,
                        accent: GOLD, foreground: WHITE, title_size: 12,
                        description_size: 10 do |event|
          state.documents_loaded = event["value"] != false
        end
        bind(switch, :checked) { state.documents_loaded == true }
        holder = loader width: CARD_BODY_W, height: 260, active: false do
          column spacing: 10, width: CARD_BODY_W do
            spin = lottie_animation Showcase.asset(:lottie), frame_rate: 30, quality: :high,
                                    auto_play: true, loops: -1, direction: 1, command: "",
                                    command_revision: 0, width: 120, height: 120
            on(spin, :error) { |event| sc_log("lottie: #{event["message"]}") }
            sheet = pdf_view Showcase.asset(:pdf), page: 1, zoom: 0.72, rotation: 0,
                             command: "", command_revision: 0, width: CARD_BODY_W,
                             height: 130
            on(sheet, :error) { |event| sc_log("pdf_view: #{event["message"]}") }
            on(sheet, :page_count) { |event| sc_log("PDF has #{event["value"]} page(s)") }
          end
        end
        bind(holder, :active) { state.documents_loaded == true }
        sc_caption("Both files live in this repository: assets/showcase-spin.json is a small " \
                   "hand-written Lottie animation and assets/showcase-note.pdf is a one-page " \
                   "PDF generated for this showcase.", size: 10)
      end
    end
  end
end

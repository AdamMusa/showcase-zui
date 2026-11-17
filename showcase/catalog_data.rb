# frozen_string_literal: true

# Generated from the Zui framework component coverage catalog.
# Regenerate with: ruby script/generate_catalog.rb /path/to/zui

module Showcase
  CATEGORY_ORDER = [
    "Foundation and layout",
    "Display, content, and media",
    "Buttons and input",
    "Navigation and structure",
    "Menus, dialogs, and feedback",
    "Data and collections",
    "Charts and visualization",
    "Drawing and interaction",
    "Animation, state, and timing",
    "Effects",
    "Multimedia and capture",
    "Models and utilities",
    "Mobile permissions",
    "Mobile virtual keyboard",
    "Mobile sensors",
    "Mobile positioning",
    "Mobile maps",
    "Mobile speech",
    "Mobile web content",
  ].freeze

  COMPONENT_CATEGORIES = {
    "Foundation and layout" => %w[
      control container row column grid row_layout
      column_layout grid_layout flow stack center card
      scroll rectangle border_overlay aspect_ratio constrained_box fitted_box
      wrap split_view stack_layout layout_item_proxy loader flickable
      focus_scope flipable border_image window application_window responsive_view
    ].freeze,
    "Display, content, and media" => %w[
      text icon image spacer separator section_header
      panel_hero optical_glyph tooltip label rich_text selectable_text
      animated_image lottie_animation pdf_view video audio avatar
      badge chip divider markdown vector_image model_view_3d
      font_loader text_metrics
    ].freeze,
    "Buttons and input" => %w[
      abstract_button button action_button bar_icon_button bar_indicator widget_button
      checkbox toggle toggle_switch text_field number_field slider
      dropdown searchable_dropdown multi_select button_group round_button tool_button
      delay_button radio_button radio_group text_area search_field password_field
      range_slider dial spin_box color_picker date_picker time_picker
      file_picker folder_picker font_picker double_spin_box dialog_button_box action
      action_group
    ].freeze,
    "Navigation and structure" => %w[
      list_view key_catcher page pane frame group_box
      tabs tab_bar tab_button page_indicator stack_view swipe_view
      drawer navigation_rail breadcrumb pagination expansion_panel accordion
      tool_bar tool_separator
    ].freeze,
    "Menus, dialogs, and feedback" => %w[
      confirm_dialog progress menu menu_item menu_separator menu_bar
      menu_bar_item context_menu popup dialog alert_dialog message_dialog
      bottom_sheet modal_sheet snackbar banner toast busy_indicator
      progress_ring skeleton
    ].freeze,
    "Data and collections" => %w[
      item_delegate check_delegate radio_delegate switch_delegate swipe_delegate grid_view
      table_view tree_view data_table horizontal_header vertical_header table_view_delegate
      tree_view_delegate horizontal_header_delegate vertical_header_delegate reorderable_list carousel calendar
      calendar_model month_grid week_number_column day_of_week_row tumbler
    ].freeze,
    "Charts and visualization" => %w[
      line_chart area_chart bar_chart stacked_bar_chart pie_chart donut_chart
      scatter_chart bubble_chart radar_chart heatmap sparkline gauge
      radial_gauge histogram candlestick_chart legend
    ].freeze,
    "Drawing and interaction" => %w[
      canvas shape line path circle gradient
      shader_effect shader_effect_source particle_system drag_area drop_area pinch_area
      hover_area tap_area point_handler multi_touch_area wheel_area safe_area
      selection_rectangle scroll_bar scroll_indicator cursor_surface
    ].freeze,
    "Animation, state, and timing" => %w[
      animation number_animation color_animation rotation_animation vector_animation path_animation
      property_animation pause_animation script_action property_action parallel_animation sequential_animation
      spring_animation smoothed_animation anchor_animation parent_animation opacity_animator rotation_animator
      scale_animator x_animator y_animator uniform_animator frame_animation animation_controller
      behavior transition state state_group property_changes anchor_changes
      parent_change timer
    ].freeze,
    "Effects" => %w[
      multi_effect rectangular_shadow opacity_mask blur drop_shadow colorize
      glow
    ].freeze,
    "Multimedia and capture" => %w[
      media_player video_output sound_effect camera capture_session image_capture
      media_recorder audio_input audio_output media_devices screen_capture window_capture
    ].freeze,
    "Models and utilities" => %w[
      list_model delegate_model delegate_model_group sort_filter_proxy_model folder_list_model settings
      standard_paths system_info network_status clipboard
    ].freeze,
    "Mobile permissions" => %w[
      bluetooth_permission calendar_permission camera_permission contacts_permission location_permission microphone_permission
    ].freeze,
    "Mobile virtual keyboard" => %w[
      virtual_keyboard handwriting_input keyboard_context keyboard_settings keyboard_text_field
    ].freeze,
    "Mobile sensors" => %w[
      accelerometer ambient_light_sensor ambient_temperature_sensor compass gyroscope humidity_sensor
      ir_proximity_sensor lid_sensor light_sensor magnetometer orientation_sensor pressure_sensor
      proximity_sensor rotation_sensor tap_sensor tilt_sensor
    ].freeze,
    "Mobile positioning" => %w[
      position_source satellite_source
    ].freeze,
    "Mobile maps" => %w[
      map map_circle map_rectangle map_polygon map_polyline map_route
      map_marker map_item_group map_item_view map_copyright geo_json_data geocode_model
      route_model place_search place_suggestions place_categories place_details place_category
    ].freeze,
    "Mobile speech" => %w[
      text_to_speech
    ].freeze,
    "Mobile web content" => %w[
      web_view web_socket web_socket_server
    ].freeze,
  }.freeze
end

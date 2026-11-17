# frozen_string_literal: true

# Regenerates showcase/catalog_data.rb — the component-to-category map — from a
# Zui checkout's docs/component-coverage.md plus its live registry.
#
#   ruby script/generate_catalog.rb ../zui
#
# The category names and order come from the framework's own coverage catalog,
# so the showcase cannot invent a taxonomy the framework does not use. Any
# component present in the registry but absent from the document is reported and
# must be placed by hand below.

default_root = File.expand_path("../../zui", __dir__)
zui_root = ARGV[0] ? File.expand_path(ARGV[0]) : default_root
coverage = File.join(zui_root, "docs", "component-coverage.md")
abort "no coverage catalog at #{coverage}" unless File.file?(coverage)

$LOAD_PATH.unshift(File.join(zui_root, "lib"))
require "zui"

EXTRA = { "responsive_view" => "Foundation and layout",
          "cursor_surface" => "Drawing and interaction" }.freeze

categories = {}
current = nil
File.readlines(coverage).each do |line|
  if line.start_with?("## ")
    current = line[3..].strip
  elsif (match = line.match(/^- \[[x ]\] ([a-z0-9_]+)/)) && current
    (categories[current] ||= []) << match[1]
  end
end
EXTRA.each { |name, category| (categories[category] ||= []) << name }

registered = Zui::DEFAULT_COMPONENTS.protocol_schema.keys
listed = categories.values.flatten
unplaced = registered - listed
warn "unplaced components (add them to EXTRA): #{unplaced.join(", ")}" unless unplaced.empty?

lines = ["# frozen_string_literal: true", ""]
lines << "# Generated from the Zui framework component coverage catalog."
lines << "# Regenerate with: ruby script/generate_catalog.rb /path/to/zui"
lines << ""
lines << "module Showcase"
lines << "  CATEGORY_ORDER = ["
categories.each_key { |category| lines << "    #{category.inspect}," }
lines << "  ].freeze"
lines << ""
lines << "  COMPONENT_CATEGORIES = {"
categories.each do |category, names|
  lines << "    #{category.inspect} => %w["
  names.each_slice(6) { |slice| lines << "      #{slice.join(" ")}" }
  lines << "    ].freeze,"
end
lines << "  }.freeze"
lines << "end"

target = File.expand_path("../showcase/catalog_data.rb", __dir__)
File.write(target, "#{lines.join("\n")}\n")
puts "wrote #{target}: #{listed.size} components in #{categories.size} categories"

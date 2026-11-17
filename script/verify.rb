# frozen_string_literal: true

# Builds the showcase application without starting the native client and
# reports what it produced. Every component, property, event and binding is
# validated by Zui during the build, so a clean run here means the whole
# component tree is schema-correct.
#
#   ruby -Ilib script/verify.rb      # from a Zui checkout
#   ruby script/verify.rb            # with the zui gem installed

require "json"

# The running application builds one page at a time; this check needs them all.
ENV["ZUI_SHOWCASE_EAGER"] = "1"
require_relative "../app"

def walk(node, counts, ids)
  return unless node.is_a?(Hash)

  type = node["type"]
  if type
    counts[type] = counts.fetch(type, 0) + 1
    ids << node["id"]
  end
  children = node["children"]
  children.each { |child| walk(child, counts, ids) } if children.is_a?(Array)
end

application = Showcase.build
tree = application.tree
counts = {}
ids = []
tree.each_value { |surface| walk(surface, counts, ids) }

missing_pages = Showcase::PAGES.reject do |page|
  Showcase::UI.instance_methods.include?(:"sc_page_#{page[:key]}")
end
duplicate_ids = ids.tally.select { |_, total| total > 1 }.keys
registry = Showcase::SCHEMA.keys
rendered = counts.keys.sort
unknown = rendered - registry

puts "surfaces          #{tree.keys.join(", ")}"
puts "nodes             #{ids.size}"
puts "component types   #{rendered.size} of #{registry.size} registered"
puts "pages             #{Showcase::PAGES.size}"
puts "demo apps         #{Showcase::DEMOS.size}"
puts

missing_demos = Showcase::DEMOS.reject do |demo|
  File.file?(File.join(Showcase::REPO_ROOT, "demos", demo[:slug], "main.rb"))
end
missing_assets = Showcase::ASSETS.reject do |_key, path|
  File.file?(File.join(Showcase::REPO_ROOT, path))
end

# The native client rejects any render above 2000 nodes or any patch batch
# above 256, and the protocol frame itself is capped at 1 MiB. Those ceilings
# are what make the lazy page rendering mandatory rather than merely faster, so
# the budget each page actually has to fit is checked here.
page_limit = 2000
frame_limit = Zui::MAX_MESSAGE_BYTES
stack = nil
find_stack = lambda do |node|
  return if stack
  return unless node.is_a?(Hash)
  stack = node if node["type"] == "stack_layout"
  (node["children"] || []).each { |child| find_stack.call(child) }
end
tree.each_value { |surface| find_stack.call(surface) }
page_nodes = (stack ? stack["children"] : []).map do |child|
  nodes = []
  walk(child, {}, nodes)
  nodes.size
end
chrome_nodes = ids.size - page_nodes.sum
heaviest = page_nodes.max.to_i
schema_bytes = JSON.generate(Showcase::SCHEMA).bytesize

puts "page budget       #{chrome_nodes} chrome + #{heaviest} heaviest page = #{chrome_nodes + heaviest} of #{page_limit} nodes"
puts "registry schema   #{schema_bytes} of #{frame_limit} frame bytes"
puts

failures = []
if chrome_nodes + heaviest > page_limit
  failures << "heaviest page plus chrome is #{chrome_nodes + heaviest} nodes, over the client's #{page_limit}"
end
unless Showcase::COVERAGE_TYPES == rendered
  stale = (rendered - Showcase::COVERAGE_TYPES) + (Showcase::COVERAGE_TYPES - rendered)
  failures << "showcase/coverage_data.rb is stale (#{stale.first(5).join(', ')}); run script/generate_coverage.rb"
end
failures << "pages without a builder method: #{missing_pages.map { |p| p[:key] }.join(", ")}" unless missing_pages.empty?
failures << "duplicate node ids: #{duplicate_ids.first(5).join(", ")}" unless duplicate_ids.empty?
failures << "unknown component types: #{unknown.join(", ")}" unless unknown.empty?
failures << "demos missing main.rb: #{missing_demos.map { |d| d[:slug] }.join(", ")}" unless missing_demos.empty?
failures << "assets not found: #{missing_assets.keys.join(", ")}" unless missing_assets.empty?

top = counts.sort_by { |type, total| [-total, type] }.first(8)
puts "most used         #{top.map { |type, total| "#{type} x#{total}" }.join(", ")}"
puts "never rendered    #{(registry - rendered).size} components are catalogued only"
puts

if failures.empty?
  puts "OK — the showcase builds clean"
  exit 0
end

failures.each { |failure| puts "FAIL #{failure}" }
exit 1

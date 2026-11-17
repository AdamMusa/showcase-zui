# frozen_string_literal: true

source "https://rubygems.org"

# The showcase renders the complete component catalog, so it prefers a local Zui
# checkout (normally a sibling directory) and falls back to the published gem.
zui_path = ENV["ZUI_PATH"] || File.expand_path("../zui", __dir__)

if File.directory?(zui_path)
  gem "zui", path: zui_path
else
  gem "zui", ">= 0.0.9"
end

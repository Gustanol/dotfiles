local settings = require("settings")

if settings and settings.window then
	settings.window.home_page = "about:blank"
	settings.window.zoom_step = 0.1
	settings.window.scroll_step = 40
end

if settings and settings.webview then
	settings.webview.user_agent = "Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0 Chrome/120.0"
	settings.webview.enable_javascript = true
	settings.webview.enable_webgl = false
end

if settings and settings.window and settings.window.search_engines then
	local engines = settings.window.search_engines
	engines.duckduckgo = "https://duckduckgo.com/?q=%s"
	engines.google = "https://www.google.com/search?q=%s"
	engines.github = "https://github.com/search?q=%s"
	engines.default = engines.duckduckgo
end

if settings and settings.soup then
	settings.soup.accept_policy = "no_third_party"
	settings.soup.cookies_storage = luakit.data_dir .. "/cookies.db"
end

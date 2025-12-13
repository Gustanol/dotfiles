# qutebrowser minimal, "suckless-like" config
# Drop this file in ~/.config/qutebrowser/config.py
# Keep it small, declarative and keyboard-centric.

# --- Core behavior ---------------------------------------------------------
config.load_autoconfig(False)  # only this file controls settings

# Use no GUI clutter: hide statusbar and tabs to keep the chrome minimal.
# You can toggle these values later if you want small indicators.
c.statusbar.show = 'never'
c.tabs.show = 'never'
c.tabs.favicons.show = 'never'

# Make the browser strictly keyboard-first if you like
# (set to True only if you are comfortable without mouse input)
c.input.mouse.rocker_gestures = False

# --- Performance / external handling --------------------------------------
# Use external programs for heavy/auxiliary tasks
c.downloads.open_dispatcher = "xdg-open {}"
# spawn mpv for media, sioyek / zathura for PDFs, xdg-open for other files
config.bind('m', 'hint links spawn mpv {hint-url}')
config.bind('M', 'spawn mpv {url}')
config.bind('p', 'open --tab {url}')
config.bind('P', 'open {url}')

# Keep downloads simple
c.downloads.position = 'bottom'
c.downloads.location.directory = '~/downloads'

# --- Privacy / reduced surface area --------------------------------------
# Disable features that add surface area or bloat
c.content.autoplay = False
c.content.notifications.enabled = False
c.content.pdfjs = False  # prefer system PDF viewer
c.content.geolocation = False
c.content.webrtc_ip_handling_policy = 'default-public-interface-only'
# limit cookies to reduce tracking while staying usable
c.content.cookies.accept = 'no-3rdparty'
# disable webfonts for a consistent, fast look
# optionally disable JavaScript by default (many sites will break)
c.content.javascript.enabled = True

# Disable WebGL to avoid GPU surprises
c.content.webgl = False

# --- Minimal visuals / colors --------------------------------------------
# Clean monochrome/dark palette; few variables only
base = '#0b0b0b'
fg = '#dcdcdc'
muted = '#4a4a4a'
accent = '#8ab4f8'  # subtle accent; change to taste

c.colors.completion.fg = fg
c.colors.completion.odd.bg = base
c.colors.completion.even.bg = base
c.colors.completion.category.fg = accent

c.colors.statusbar.normal.fg = fg
c.colors.statusbar.normal.bg = base
c.colors.statusbar.command.fg = fg
c.colors.statusbar.command.bg = base

c.colors.tabs.bar.bg = base
c.colors.tabs.selected.odd.bg = muted
c.colors.tabs.selected.even.bg = muted
c.colors.tabs.odd.bg = base
c.colors.tabs.even.bg = base

# Hints: small border, minimal box to preserve visibility
c.hints.border = '1px solid #222'
#c.hints.mode = 2000
c.hints.min_chars = 1

# --- Fonts ---------------------------------------------------------------
c.fonts.default_family = ['monospace']
c.fonts.web.family.standard = 'sans-serif'
c.fonts.default_size = '12pt'

# --- Keybindings (small, vi-like and focused) -----------------------------
# navigation
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('x', 'tab-close')
config.bind('X', 'undo')
config.bind('o', 'set-cmd-text -s :open ')  # quick open
config.bind('O', 'set-cmd-text -s :open -t ')  # open in new tab

# history / scroll
config.bind('H', 'back')
config.bind('L', 'forward')
config.bind('gg', 'scroll-to-perc 0')
config.bind('G', 'scroll-to-perc 100')

# hints & copy
config.bind('f', 'hint all')
config.bind('F', 'hint all tab')
config.bind('yy', 'yank')
config.bind('Y', 'yank -s')  # copy title + url

# quick search
config.bind('/', 'set-cmd-text /')
config.bind('n', 'search-next')
config.bind('N', 'search-prev')

# spawn terminal and external actions
config.bind('t', 'spawn alacritty -e $SHELL')
config.bind('d', 'hint links download')

# tiny helper to view page source quickly
config.bind('ps', 'view-source')

# --- Minimal but useful command aliases ----------------------------------
c.aliases = {
    'q': 'quit',
    'wq': 'quit --save',
    'mu': 'spawn mpv {url}',
}

# --- Search engines ------------------------------------------------------
# Keep a minimal set; use your system-wide search for others
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'g': 'https://www.google.com/search?q={}',
    'w': 'https://en.wikipedia.org/wiki/{}',
}

# --- Content blocking / adblocking ---------------------------------------
# qutebrowser can use adblock; keep rules minimal or use uBlock externally
# If you want to use a small blocklist, point it here (commented by default):
# c.content.blocking.enabled = True
# c.content.blocking.method = 'both'
# c.content.blocking.whitelist = []

# --- Session / tabs behaviour --------------------------------------------
c.session.lazy_restore = True
c.tabs.last_close = 'close'  # exit qutebrowser when final tab closed
c.new_instance_open_target = 'tab'  # external opens use a new tab

# --- Small UX touches to avoid surprises -------------------------------
c.confirm_quit = ['downloads']  # only confirm on downloads
c.auto_save.session = True

# --- Tiny userscript hook example (very small) ---------------------------
# Keep userscripts few & tiny. Example: pass integration to fill logins via pass
# Save a script into qutebrowser userscripts dir (e.g. ~/.local/bin/qute-pass)
# and bind it when needed. We don't include the script content here.
# config.bind('P', 'spawn --userscript qute-pass')

# --- Final: safety & notes ------------------------------------------------
# This config intentionally leaves JavaScript on because many modern sites
# will break otherwise. If you prefer maximal minimalism and privacy, set
# c.content.javascript.enabled = False and rely on :open with search engines

# End of file


import os
config.load_autoconfig(False)

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-hsl'
c.colors.webpage.darkmode.contrast = 0.6
c.colors.webpage.darkmode.threshold.foreground = 130
c.colors.webpage.darkmode.threshold.background = 200
c.colors.webpage.darkmode.policy.images = 'smart'
c.colors.webpage.darkmode.policy.page = 'smart'
config.set('colors.webpage.darkmode.enabled', False, 'https://*.monkeytype.com/*')

c.input.forward_unbound_keys = 'all'
c.input.insert_mode.auto_enter = False
c.input.insert_mode.auto_leave = False
c.input.insert_mode.auto_load = False

c.tabs.mousewheel_switching = True

config.bind('f', 'hint links')
config.bind('o', 'open {url}')
config.bind('t', 'open -t')
config.bind('gg', 'scroll-perc 0')
config.bind('G',  'scroll-perc 100')
config.bind('dd', 'tab-close')
config.bind('j', 'tab-prev')
config.bind('k', 'tab-next')
config.bind('<Alt+Tab>', 'tab-focus last')
config.bind('gt', 'set-cmd-text -s :tab-select ')

c.editor.command = ['emacsclient', '--no-wait', '+{line}:{column}:{file}']
c.qt.chromium.low_end_device_mode = 'always'
c.qt.args = [
    'ignore-gpu-blocklist',
    'enable-gpu-rasterization',
    'enable-accelerated-video-decode',
    'num-raster-threads=4'
]

config.bind('<Up>',   "jseval document.querySelector('video').playbackRate += 0.25;")
config.bind('<Down>', "jseval document.querySelector('video').playbackRate -= 0.25;")
config.bind('cm',     'clear-messages')

config.set(
    'content.headers.user_agent',
    'Mozilla/5.0 (X11; Linux x86_64; rv:70.0) Gecko/20100101 Firefox/70.0',
    'https://accounts.google.com/*'
)

c.backend = 'webengine'
c.content.javascript.enabled = True
c.content.cookies.accept = 'all'
c.content.cookies.store = True

c.auto_save.session = False
c.tabs.last_close = 'default-page'
c.url.start_pages = ['https://duckduckgo.com/?q=']

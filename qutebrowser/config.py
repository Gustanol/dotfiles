import sys
config.load_autoconfig(False)

c.backend = 'webengine'
c.qt.chromium.low_end_device_mode = 'always'

c.qt.args = [
    'ignore-gpu-blocklist',
    'enable-gpu-rasterization',
    'enable-accelerated-video-decode',
    'enable-zero-copy',
    'enable-features=VaapiVideoDecoder',
    'disable-features=UseChromeOSDirectVideoDecoder',
    # 'enable-features=VaapiVideoDecodeLinuxGL'
]

c.content.canvas_reading = False
c.content.webgl = False
c.content.plugins = False
c.content.persistent_storage = 'ask'
c.content.dns_prefetch = False
c.content.prefers_reduced_motion = True

# c.qt.workarounds.remove_service_workers = True

c.completion.web_history.max_items = 2500
c.completion.cmd_history_max_items = 1000
c.session.lazy_restore = False

c.content.blocking.enabled = True
c.content.blocking.method = 'hosts'
c.content.blocking.adblock.lists = [
    'https://easylist.to/easylist/easylist.txt',
    'https://easylist.to/easylist/easyprivacy.txt',
    'https://secure.fanboy.co.nz/fanboy-annoyance.txt'
]

c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
# c.colors.webpage.darkmode.contrast = 0.6
c.colors.webpage.darkmode.threshold.foreground = 130
c.colors.webpage.darkmode.threshold.background = 200
c.colors.webpage.darkmode.policy.images = 'smart'
c.colors.webpage.darkmode.policy.page = 'smart'
# config.set('colors.webpage.darkmode.enabled', True, 'https://*.github.com/*')

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
config.bind('<Up>',
    "jseval document.querySelector('video') && (document.querySelector('video').playbackRate ||= 0) && (document.querySelector('video').playbackRate += 0.25);")
config.bind('<Down>',
    "jseval document.querySelector('video') && (document.querySelector('video').playbackRate ||= 0) && (document.querySelector('video').playbackRate -= 0.25);")
config.bind('cm', 'clear-messages')

c.editor.command = ['nvim', '--no-wait', '+{line}:{column}:{file}']

config.set(
    'content.headers.user_agent',
    'Mozilla/5.0 (X11; Linux x86_64; rv:70.0) Gecko/20100101 Firefox/70.0',
    'https://accounts.google.com/*'
)

c.auto_save.session = False
c.tabs.last_close = 'default-page'
c.url.start_pages = ['https://duckduckgo.com/?q=']

/**
 * @name ChannelsPreview
 * @author arg0NNY
 * @authorId 224538553944637440
 * @invite M8DBtcZjXD
 * @version 1.4.0
 * @description Allows you to view recent messages in channels without switching to it.
 * @website https://github.com/arg0NNY/DiscordPlugins/tree/master/ChannelsPreview
 * @source https://raw.githubusercontent.com/arg0NNY/DiscordPlugins/master/ChannelsPreview/ChannelsPreview.plugin.js
 * @updateUrl https://raw.githubusercontent.com/arg0NNY/DiscordPlugins/master/ChannelsPreview/ChannelsPreview.plugin.js
 */

module.exports = (() => {
    const config = {
        "info": {
            "name": "ChannelsPreview",
            "authors": [
                {
                    "name": "arg0NNY",
                    "discord_id": '224538553944637440',
                    "github_username": 'arg0NNY'
                }
            ],
            "version": "1.4.0",
            "description": "Allows you to view recent messages in channels without switching to it.",
            github: "https://github.com/arg0NNY/DiscordPlugins/tree/master/ChannelsPreview",
            github_raw: "https://raw.githubusercontent.com/arg0NNY/DiscordPlugins/master/ChannelsPreview/ChannelsPreview.plugin.js"
        },
        "changelog": [
            {
                "type": "improved",
                "title": "Improvements",
                "items": [
                    "Added support for stage voices.",
                    "Got rid of manual messages handling in favour of Discord's internal one."
                ]
            },
            {
                "type": "fixed",
                "title": "Fixed",
                "items": [
                    "Plugin has been fixed and adjusted for the latest Discord update."
                ]
            }
        ],
        "defaultConfig": [
            {
                type: 'category',
                id: 'trigger',
                name: 'Trigger',
                collapsible: true,
                shown: true,
                settings: [
                    {
                        type: "radio",
                        id: "displayOn",
                        name: "Display Preview On",
                        value: "hover",
                        options: [
                            {name: "Hover", value: "hover"},
                            {name: "Mouse Wheel Click", value: "mwheel"}
                        ]
                    },
                    {
                        type: 'slider',
                        id: 'hoverDelay',
                        name: 'Hover Delay',
                        note: 'NOTE: Messages fetching time is unsteady and not included in this option.',
                        value: .2,
                        initialValue: .2,
                        defaultValue: .2,
                        markers: [...Array(50).keys()].map(n => (n + 1) / 10),
                        stickToMarkers: true,
                        onMarkerRender: m => m%.5 === 0 || m === .2 ? m + 's' : ''
                    },
                ]
            },
            {
                type: 'category',
                id: 'appearance',
                name: 'Appearance',
                collapsible: true,
                settings: [
                    {
                        type: "radio",
                        id: "displayMode",
                        name: "Message Display",
                        value: "cozy",
                        options: [
                            {name: "Cozy", value: "cozy"},
                            {name: "Compact", value: "compact"}
                        ]
                    },
                    {
                        type: 'switch',
                        id: 'groupSpacingSync',
                        name: 'Sync Space Between Message Groups with app settings',
                        note: 'Sets Space Between Message Groups option equal to global Discord settings (Appearance tab). Option below will be ignored.',
                        value: true
                    },
                    {
                        type: 'slider',
                        id: 'groupSpacing',
                        name: 'Space Between Message Groups',
                        value: 16,
                        initialValue: 16,
                        defaultValue: 16,
                        markers: [0, 4, 8, 16, 24],
                        stickToMarkers: true,
                        onMarkerRender: m => m + 'px'
                    },
                    {
                        type: 'switch',
                        id: 'darkenChat',
                        name: 'Darken chat behind popout',
                        note: 'Darkens chat when popout appears for better contrast.',
                        value: true
                    },
                    {
                        type: 'slider',
                        id: 'darkenLevel',
                        name: 'Darken level',
                        note: 'Sets the opacity level of darkening layer.',
                        value: .3,
                        initialValue: .3,
                        defaultValue: .3,
                        markers: [.1, .2, .3, .4, .5, .6, .7, .8, .9, 1],
                        stickToMarkers: true
                    },
                    {
                        type: 'switch',
                        id: 'dateDividers',
                        name: 'Show date dividers',
                        note: 'Shows date dividers between messages in preview popout.',
                        value: true
                    },
                    {
                        type: 'switch',
                        id: 'typingUsers',
                        name: 'Show typing users',
                        note: 'Shows who\'s typing in previewed channel.',
                        value: true
                    },
                    {
                        type: 'slider',
                        id: 'popoutHeight',
                        name: 'Popout height',
                        note: 'Sets popouts\'s window height in percentages relative to Discord\'s window height.',
                        value: 30,
                        initialValue: 30,
                        defaultValue: 30,
                        markers: [...Array(20).keys()].map(n => (n + 1) * 5).slice(1),
                        stickToMarkers: true,
                        onMarkerRender: m => m % 10 === 0 ? m + '%' : ''
                    },
                    {
                        type: 'slider',
                        id: 'messagesCount',
                        name: 'Messages count limit',
                        note: 'Sets the number of messages to fetch and display in preview (the more messages, the more fetching time, the longer popout takes to open).',
                        value: 20,
                        initialValue: 20,
                        defaultValue: 20,
                        markers: [...Array(10).keys()].map(n => (n + 1) * 10),
                        stickToMarkers: true
                    },
                ]
            }
        ]
    };

    return !global.ZeresPluginLibrary ? class {
        constructor() {
            this._config = config;
        }

        getName() {
            return config.info.name;
        }

        getAuthor() {
            return config.info.authors.map(a => a.name).join(", ");
        }

        getDescription() {
            return config.info.description;
        }

        getVersion() {
            return config.info.version;
        }

        load() {
            BdApi.UI.showConfirmationModal("Library Missing", `The library plugin needed for ${config.info.name} is missing. Please click Download Now to install it.`, {
                confirmText: "Download Now",
                cancelText: "Cancel",
                onConfirm: () => {
                    require("request").get("https://rauenzi.github.io/BDPluginLibrary/release/0PluginLibrary.plugin.js", async (error, response, body) => {
                        if (error) return require("electron").shell.openExternal("https://betterdiscord.app/Download?id=9");
                        await new Promise(r => require("fs").writeFile(require("path").join(BdApi.Plugins.folder, "0PluginLibrary.plugin.js"), body, r));
                    });
                }
            });
        }

        start() {
        }

        stop() {
        }
    } : (([Plugin, Api]) => {
        const plugin = (Plugin, Api) => {
            const {
                DOM,
                Webpack: { Filters }
            } = BdApi;
            const {
                Patcher,
                WebpackModules,
                DiscordModules,
                Popouts,
                Toasts,
                Utilities
            } = Api;
            const {
                React,
                MessageActions,
                MessageStore,
                ChannelStore,
                SelectedChannelStore,
                DiscordPermissions,
                GuildPermissions
            } = DiscordModules;

            const Dispatcher = WebpackModules.getByProps('_subscriptions', '_waitQueue');

            const ChannelTypes = WebpackModules.getModule(Filters.byKeys('GUILD_TEXT'), { searchExports: true });
            const MessageTypes = WebpackModules.getModule(Filters.byKeys('REPLY', 'USER_JOIN'), { searchExports: true });

            const Selectors = {
                Messages: WebpackModules.getByProps('message', 'cozyMessage'),
                MessageDividers: WebpackModules.getByProps('divider', 'unreadPill'),
                EmptyMessage: WebpackModules.getByProps('emptyChannelIcon', 'locked'),
                Chat: WebpackModules.getByProps('chat', 'channelName'),
                Popout: WebpackModules.getByProps('messagesPopoutWrap'),
                ChannelItem: {
                    ...WebpackModules.getByProps('containerDefault', 'channelInfo'),
                    ...WebpackModules.getByProps('link', 'notInteractive')
                },
                Channel: WebpackModules.getByProps('channel', 'interactive'),
                Typing: WebpackModules.getByProps('typing', 'ellipsis'),
                ChatLayout: WebpackModules.getByProps('sidebar', 'guilds')
            };

            let settings = {};
            let MESSAGES_FETCHING_LIMIT = 20;
            const MESSAGE_GROUP_INTERVAL = 420000;
            let displayedSettingsNotice = false;

            const Common = WebpackModules.getByProps('Shakeable', 'List');
            const ChannelItem = WebpackModules.getByProps('ChannelItemIcon');
            const AppearanceSettingsStore = WebpackModules.getByProps('fontSize', 'fontScale');
            const VoiceChannelActions = WebpackModules.getByProps('updateChatOpen');
            const { default: MessageComponent, ThreadStarterChatMessage: ThreadStarterMessage } = WebpackModules.getByProps('ThreadStarterChatMessage');
            const EmptyMessage = WebpackModules.getByString('SYSTEM_DM_EMPTY_MESSAGE', 'BEGINNING_CHANNEL_WELCOME');
            const FluxTypingUsers = WebpackModules.getByString('getTypingUsers', 'isBypassSlowmode');
            const { useStateFromStores } = WebpackModules.getByProps('useStateFromStores');

            function ChannelsPreviewPopout({ channel }) {
                const messages = useStateFromStores([MessageStore], () => MessageStore.getMessages(channel.id).toArray().slice(-MESSAGES_FETCHING_LIMIT));

                let currentGroupId = null;

                function getPreviousMessage(message) {
                    const index = messages.indexOf(message);
                    if (index === 0) return null;

                    return messages[index - 1];
                }

                function getGroupId(message) {
                    const INTERVAL = MESSAGE_GROUP_INTERVAL / 1000;
                    const Types = MessageTypes;
                    const previousMessage = getPreviousMessage(message);
                    if (!previousMessage) return currentGroupId = message.id;

                    return message.author.id !== previousMessage.author.id
                    || message.type !== Types.DEFAULT
                    || ![Types.DEFAULT, Types.REPLY].includes(previousMessage.type)
                    || Math.abs(previousMessage.timestamp.unix() - message.timestamp.unix()) > INTERVAL
                    || !message.timestamp.isSame(previousMessage.timestamp, 'day')
                      ? currentGroupId = message.id : currentGroupId;
                }

                function buildDateDivider(timestamp) {
                    const formatted = timestamp.format('LL');

                    return React.createElement(
                      'div',
                      {
                          className: `${Selectors.Messages.divider} ${Selectors.Messages.hasContent} ${Selectors.MessageDividers.divider} ${Selectors.MessageDividers.hasContent}`,
                          role: 'separator',
                          'aria-label': formatted
                      },
                      React.createElement('span', {className: Selectors.MessageDividers.content}, formatted)
                    );
                }

                const messagesElements = [];
                if (MessageComponent)
                    messages.forEach(message => {
                        if (message.type === MessageTypes.THREAD_STARTER_MESSAGE && !ThreadStarterMessage) return;

                        if (settings.appearance.dateDividers) {
                            const previousMessage = getPreviousMessage(message);
                            if (!previousMessage || !message.timestamp.isSame(previousMessage.timestamp, 'day'))
                                messagesElements.push(buildDateDivider(message.timestamp));
                        }

                        messagesElements.push(React.createElement(message.type === MessageTypes.THREAD_STARTER_MESSAGE ? ThreadStarterMessage : MessageComponent, {
                            channel: channel,
                            message: message,
                            groupId: getGroupId(message),
                            id: `chat-messages-${message.id}`,
                            compact: settings.appearance.displayMode === 'compact'
                        }));
                    });

                if (EmptyMessage && messagesElements.filter(m => !!m.props?.message).length < MESSAGES_FETCHING_LIMIT)
                    messagesElements.unshift(React.createElement(EmptyMessage, {
                        channel
                    }));

                const messageGroupSpacing = settings.appearance.groupSpacingSync ? (AppearanceSettingsStore.messageGroupSpacing ?? 16) : settings.appearance.groupSpacing;

                return React.createElement(
                  'div',
                  {
                      id: 'ChannelsPreview',
                      className: `group-spacing-${messageGroupSpacing} ${Selectors.Popout.messagesPopoutWrap} show`
                  },
                  React.createElement(
                    'div',
                    {
                        id: 'ChannelsPreview-container'
                    },
                    [
                        ...messagesElements,
                        ...(FluxTypingUsers && settings.appearance.typingUsers !== false ? [React.createElement(FluxTypingUsers, {channel})] : [])
                    ]
                  )
                );
            }

            const PopoutManager = new class {
                constructor() {
                    this.hoverTimeout = null;
                    this.current = null;
                    this.popouts = [];
                    this.darkenNode = null;
                }

                darken() {
                    if (!settings.appearance.darkenChat) return;

                    if (this.darkenNode) this.undarken();
                    this.darkenNode = document.createElement('div');
                    this.darkenNode.id = 'ChannelsPreview-darken';
                    this.darkenNode.style.setProperty('left', document.querySelector(`.${Selectors.ChatLayout.sidebar}`)?.clientWidth + 'px');
                    document.querySelector(`.${Selectors.ChatLayout.content}`)?.appendChild(this.darkenNode);
                    setTimeout(() => this.darkenNode.style.opacity = settings.appearance.darkenLevel);
                }

                undarken() {
                    if (!this.darkenNode) return;

                    this.darkenNode.style.opacity = 0;
                    this.darkenNode.addEventListener('transitionend', e => e.currentTarget.remove());
                    this.darkenNode = null;
                }

                open(event, channel) {
                    if (this.current && this.current.channel.id === channel.id) return;

                    this.close();
                    this.current = {event, channel};
                    this.display();
                }

                close(all = false) {
                    if (!this.current) return;
                    this.current = null;

                    this.popouts.forEach(id => Popouts.closePopout(id));
                    this.popouts = [];
                    this.undarken();
                }

                forceClose() {
                    clearTimeout(this.hoverTimeout);
                    this.close();
                }

                async display() {
                    const {channel, event} = this.current;

                    MESSAGES_FETCHING_LIMIT = settings.appearance.messagesCount ?? 20;

                    await MessageActions.fetchMessages({channelId: channel.id, limit: MESSAGES_FETCHING_LIMIT});
                    if (this.current?.channel !== channel) return;

                    const messages = MessageStore.getMessages(channel.id).toArray().slice(0, MESSAGES_FETCHING_LIMIT)
                    const storedChannel = ChannelStore.getChannel(channel.id);

                    const parentChannelElem = event.target.closest(`.${Selectors.ChannelItem.containerDefault}`) ?? event.target.closest(`.${Selectors.Channel.channel}`);

                    const popoutId = Popouts.openPopout(parentChannelElem, {
                        position: "right",
                        align: "center",
                        spacing: 20,
                        autoInvert: true,
                        nudgeAlignIntoViewport: true,
                        render: () => {
                            return React.createElement(ChannelsPreviewPopout, {
                                messages,
                                channel: storedChannel,
                                patcher: Dispatcher
                            });
                        }
                    });
                    this.popouts.push(popoutId);

                    this.darken();
                }

                hover(...params) {
                    this.forceClose();
                    this.hoverTimeout = setTimeout(() => {
                        this.open(...params);
                    }, settings.trigger.hoverDelay * 1000);
                }

                leave() {
                    clearTimeout(this.hoverTimeout);
                    this.close(true);
                }
            }();

            return class ChannelsPreview extends Plugin {
                onStart() {
                    this.css();
                    settings = this.settings;
                    displayedSettingsNotice = false;

                    this.patchChannelItems();
                }

                patchChannelItems() {
                    const modifyOnClick = (props) => {
                        if (props.onClickOriginal) return;

                        props.onClickOriginal = props.onClick;
                        props.onClick = (...attrs) => {
                            PopoutManager.forceClose();
                            props.onClickOriginal(...attrs);
                        }
                    }

                    const before = (that, [props], isSelected = null) => {
                        if (props.selected && !isSelected) return;

                        const wrap = f => (isSelected === null ? f : (...p) => {
                            if (!isSelected()) f(...p);
                        });

                        const channel = props.channel;
                        if (channel && [ChannelTypes.GUILD_TEXT, ChannelTypes.GUILD_ANNOUNCEMENT, ChannelTypes.DM, ChannelTypes.GROUP_DM,
                            ChannelTypes.PUBLIC_THREAD, ChannelTypes.PRIVATE_THREAD, ChannelTypes.GUILD_VOICE, ChannelTypes.GUILD_STAGE_VOICE].includes(channel.type)) {
                            if ([ChannelTypes.GUILD_VOICE, ChannelTypes.GUILD_STAGE_VOICE].includes(channel.type)  && !GuildPermissions.can(DiscordPermissions.CONNECT, channel)) return

                            props.onMouseLeave = wrap(() => PopoutManager.leave());

                            switch (settings.trigger.displayOn) {
                                case 'hover':
                                    props.onMouseEnter = wrap(e => PopoutManager.hover(e, channel));
                                    break;
                                case 'mwheel':
                                    props.onMouseDown = wrap(e => {
                                        e.preventDefault()
                                        if (e.button === 1) PopoutManager.open(e, channel);
                                    });
                                    break;
                            }
                        }
                    };

                    const after = (that, [props], value) => {
                        const clickable = this.getClickable(value);
                        if (clickable?.props.onClick) modifyOnClick(clickable.props);

                        if (settings.trigger.displayOn !== 'mwheel') return;
                        setTimeout(() => {
                            if (clickable?.ref?.current) clickable.ref.current.onauxclick = e => e.preventDefault();
                        }, 0);
                    };

                    Patcher.before(ChannelItem, 'default', before);
                    Patcher.after(ChannelItem, 'default', after);

                    // For DMs
                    Patcher.after(Common, 'Interactive', (self, [props], value) => {
                        const e = Utilities.findInTree(value, e => e?.props?.to);
                        if (!e || !e.props?.to?.includes || !e.props?.to?.includes('/channels/@me/')) return;

                        modifyOnClick(props);

                        e.props.selected = props.selected;
                        e.props.channel = ChannelStore.getChannel(e.props.to.split('@me/')[1]);
                        before(e, [e.props]);


                        if (settings.trigger.displayOn !== 'mwheel') return;
                        setTimeout(() => {
                            e.props.innerRef.current.onauxclick = e => e.preventDefault();
                        });
                    });

                    // For threads
                    Patcher.before(Common.Clickable.prototype, 'render', (self) => {
                        if (self.props?.className !== Selectors.ChannelItem.link) return;
                        const { props } = self;
                        const itemId = props['data-list-item-id']?.split('_');
                        const channel = ChannelStore.getChannel(itemId?.[itemId.length - 1]);
                        if (!channel) return;

                        modifyOnClick(props);

                        props.selected = SelectedChannelStore.getChannelId() === channel.id;
                        props.channel = channel;
                        before(self, [props], () => SelectedChannelStore.getChannelId() === channel.id);
                    });

                    // For voice chats
                    Patcher.before(VoiceChannelActions, 'updateChatOpen', (self, [channelId]) => {
                        if (PopoutManager.current?.channel?.id === channelId) PopoutManager.forceClose();
                    });
                }

                getClickable(obj) {
                    let result = null;
                    for (const key in obj)
                        if (obj[key] && typeof obj[key] === 'object')
                            if (obj[key].props?.onClick && obj[key].props?.role === 'link') result = obj[key] ?? result;
                            else if (this.shouldDescend(key)) result = this.getClickable(obj[key]) ?? result;

                    return result;
                }

                shouldDescend(key) {
                    return key === 'props' || key === 'children' || !isNaN(key);
                }

                css() {
                    DOM.addStyle('ChannelsPreviewStyles', `
#ChannelsPreview {
  pointer-events: none;
  background: var(--background-primary);
  border-radius: 10px;
  height: ${this.settings.appearance.popoutHeight ?? 30}vh;
  min-height: 150px;
  width: 50vw;
  min-width: 350px;
  overflow: hidden;
}
#ChannelsPreview * {
  pointer-events: none !important;
}
#ChannelsPreview::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 50px;
  background: linear-gradient(to bottom, var(--background-primary), transparent);
  z-index: 20;
}
#ChannelsPreview-container {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  padding-bottom: 25px;
}
#ChannelsPreview-container > * {
  list-style: none;
}
#ChannelsPreview-darken {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: #000;
  pointer-events: none;
  opacity: 0;
  transition: .3s opacity;
  z-index: 1000;
}

#${this.getSettingsPanelId()} .plugin-inputs {
    box-sizing: border-box;
    padding: 0 10px;
}
        `);
                }

                clearCss() {
                    DOM.removeStyle('ChannelsPreviewStyles');
                }

                onStop() {
                    PopoutManager.undarken();
                    this.clearCss();
                    Patcher.unpatchAll();
                }

                getSettingsPanelId() {
                    return `${this.getName()}-settings`;
                }

                getSettingsPanel() {
                    const panel = this.buildSettingsPanel();
                    panel.addListener((section, id, value) => {
                        if (!displayedSettingsNotice) {
                            Toasts.warning('Switch guild for settings to apply!');
                            displayedSettingsNotice = true;
                        }

                        if (id === 'popoutHeight') {
                            this.clearCss();
                            this.css();
                        }
                    });

                    const element = panel.getElement();
                    element.id = this.getSettingsPanelId();
                    // element.prepend(new Settings.SettingField(null, React.createElement(DiscordModules.TextElement, {
                    //     children: [
                    //         'Not your language? Help translate the plugin on the ',
                    //         React.createElement(Anchor, {
                    //             children: 'Crowdin page',
                    //             href: 'https://crwd.in/betterdiscord-channelspreview'
                    //         }),
                    //         '.'
                    //     ],
                    //     className: `${DiscordModules.TextElement.Colors.STANDARD} ${DiscordModules.TextElement.Sizes.SIZE_14}`
                    // }), () => {}, document.createElement('div')).inputWrapper);

                    return element;
                }
            }
        }

        return plugin(Plugin, Api);
    })(global.ZeresPluginLibrary.buildPlugin(config));
})();

/**
 * @name RemoveChatButtons
 * @displayName RemoveChatButtons
 * @description Remove annoying stuff from your Discord clients.
 * @author Qb
 * @authorId 133659541198864384
 * @version 1.6.0
 * @invite gj7JFa6mF8
 * @source https://github.com/BleedingBD/plugin-RemoveChatButtons
 * @updateUrl https://raw.githubusercontent.com/BleedingBD/plugin-RemoveChatButtons/main/RemoveChatButtons.plugin.js
 */
/*@cc_on
@if (@_jscript)

var shell = WScript.CreateObject("WScript.Shell");
shell.Popup("It looks like you've mistakenly tried to run me directly. That's not how you install plugins. \n(So don't do that!)", 0, "I'm a plugin for BetterDiscord", 0x30);

@else@*/
class Styler {
    pluginName = '';
    styles = new Set();
    index = 0;

    constructor(pluginName) {
        this.pluginName = pluginName;
    }

    /**
     * Add a stylesheet to the document.
     * @param name The name of the stylesheet, can be used to remove it later.
     * @param style The css string to add as a stylesheet.
     * @returns A function that removes the stylesheet from the document.
     */
    add(name, style) {
        if (!style) {
            style = name;
            name = `${this.index++}`;
        }
        const key = `${this.pluginName}--Styler--${name}`;
        BdApi.injectCSS(key, style);
        this.styles.add(key);
        return () => {
            this.remove(name);
        };
    }

    /**
     * Remove a stylesheet with the given name from the document.
     * @param name The name of the stylesheet to remove.
     */
    remove(name) {
        const key = `${this.pluginName}--Styler--${name}`;
        BdApi.clearCSS(key);
        this.styles.delete(key);
    }

    /**
     * Remove all stylesheets that were added by this Styler instance from the document.
     */
    removeAll() {
        for (const key of this.styles) {
            BdApi.clearCSS(key);
        }
        this.styles.clear();
        this.index = 0;
    }
}

module.exports = (() => {
    const config = {
        info: {
            name: 'RemoveChatButtons',
            authors: [
                {
                    name: 'Qb',
                    discord_id: '133659541198864384',
                    github_username: 'QbDesu',
                },
            ],
            version: '1.6.0',
            description: 'Hide annoying stuff from your Discord client.',
            github: 'https://github.com/BleedingBD/plugin-RemoveChatButtons',
            github_raw: 'https://raw.githubusercontent.com/BleedingBD/plugin-RemoveChatButtons/main/RemoveChatButtons.plugin.js',
        },
        defaultConfig: [
            {
                type: 'switch',
                id: 'emojiButton',
                name: 'Remove Emoji Button',
                note: 'Removes the Emoji button from the chat.',
                value: false,
            },
            {
                type: 'switch',
                id: 'stickerButton',
                name: 'Remove Sticker Button',
                note: 'Removes the Sticker button from the chat.',
                value: true,
            },
            {
                type: 'switch',
                id: 'gifButton',
                name: 'Remove GIF Button',
                note: 'Removes the GIF button from the chat.',
                value: true,
            },
            {
                type: 'switch',
                id: 'giftButton',
                name: 'Remove Gift/Boost Button',
                note: 'Removes the Gift Nitro/Boost Server button from the chat.',
                value: true,
            },
            {
                type: 'switch',
                id: 'attachButton',
                name: 'Remove Attach Button',
                note: 'Removes the Attach button from the chat.',
                value: false,
            },
            {
                type: 'category',
                name: 'Message Actions',
                id: 'messageActions',
                settings: [
                    {
                        type: 'switch',
                        id: 'reactionButton',
                        name: 'Remove Reaction Button',
                        note: 'Removes the "Add Reaction" button from messages.',
                        value: false,
                    },
                    {
                        type: 'switch',
                        id: 'superReactionButton',
                        name: 'Remove Super Reaction Button',
                        note: 'Removes the "Add Super Reaction" button from messages.',
                        value: false,
                    },
                    {
                        type: 'switch',
                        id: 'editButton',
                        name: 'Remove Edit Button',
                        note: 'Removes the "Edit" button from messages.',
                        value: false,
                    },
                    {
                        type: 'switch',
                        id: 'replyButton',
                        name: 'Remove Reply Button',
                        note: 'Removes the "Reply" button from messages.',
                        value: false,
                    },
                ],
            },
            {
                type: 'category',
                name: 'Direct Messages',
                id: 'dms',
                settings: [
                    {
                        type: 'switch',
                        id: 'friendsTab',
                        name: 'Remove Friends Tab',
                        note: 'Removes the friends tab button from the DM list.',
                        value: false,
                    },
                    {
                        type: 'switch',
                        id: 'premiumTab',
                        name: 'Remove Nitro Tab',
                        note: 'Removes the nitro tab button from the DM list.',
                        value: true,
                    },
                    {
                        type: 'switch',
                        id: 'snowsgivingTab',
                        name: 'Remove Snowsgiving Tab',
                        note: 'Removes the seasonal "Snowsgiving" tab button from the DM list.',
                        value: false,
                    },
                    {
                        type: 'switch',
                        id: 'discordBirthdayTab',
                        name: 'Remove Discord\'s Birthday Tab',
                        note: 'Removes the seasonal "Discord\'s Birthday" tab button from the DM list.',
                        value: true,
                    },
                ],
            },
            {
                type: 'category',
                name: 'Channel List',
                id: 'channels',
                settings: [
                    {
                        type: 'switch',
                        id: 'publicBadge',
                        name: 'Remove Public Badge',
                        note: 'Removes the "public" badge that covers part of server\'s banner.',
                        value: false,
                    },
                    {
                        type: 'switch',
                        id: 'boostBar',
                        name: 'Remove Boost Bar',
                        note: 'Removes the boost progress bar from the channel list.',
                        value: true,
                    },
                    {
                        type: 'switch',
                        id: 'inviteButton',
                        name: 'Remove Invite Button',
                        note: "Removes the invite button from the channel list entries. (It's also available in the context menu and the server settings anyway.)",
                        value: false,
                    },
                ],
            },
            {
                type: 'category',
                name: 'Voice',
                id: 'voice',
                settings: [
                    {
                        type: 'switch',
                        id: 'cameraPanelButton',
                        name: 'Remove Camera Panel Button',
                        note: 'Removes the camera button from the voice chat panel in the bottom left.',
                        value: false,
                    },
                    {
                        type: 'switch',
                        id: 'screensharePanelButton',
                        name: 'Remove Screenshare Panel Button',
                        note: 'Removes the screenshare button from the voice chat panel in the bottom left.',
                        value: false,
                    },
                    {
                        type: 'switch',
                        id: 'activityPanelButton',
                        name: 'Remove Activity Panel Button',
                        note: 'Removes the activity button from the voice chat panel in the bottom left.',
                        value: false,
                    },
                ],
            },
            {
                type: 'category',
                name: 'Compatibility',
                id: 'compatibility',
                settings: [
                    {
                        type: 'switch',
                        id: 'invisibleTypingButton',
                        name: 'Remove Invisible Typing Button',
                        note: "Removes the button added by Strencher's InvisibleTyping plugin from the chat.",
                        value: false,
                    },
                ],
            },
        ],
        changelog: [
            {
                title: 'Added',
                type: 'added',
                items: ['Added support for message action buttons like the super reaction button. Also added support for the seasonal Discord\'s Birthday tab. Unfortunately you will have to modify the settings manually in the JSON file because settings are currently broken in ZLibrary.'],
            },
        ],
    };
    if (!global.ZeresPluginLibrary) {
        return class {
            constructor() { }
            load() {
                BdApi.showConfirmationModal(
                    'Library plugin is needed',
                    [`The library plugin needed for ${config.info.name} is missing. Please click Download Now to install it.`],
                    {
                        confirmText: 'Download',
                        cancelText: 'Cancel',
                        onConfirm: () => {
                            require('request').get(
                                'https://rauenzi.github.io/BDPluginLibrary/release/0PluginLibrary.plugin.js',
                                async (error, response, body) => {
                                    if (error) return require('electron').shell.openExternal('https://betterdiscord.app/Download?id=9');
                                    await new Promise((r) =>
                                        require('fs').writeFile(
                                            require('path').join(BdApi.Plugins.folder, '0PluginLibrary.plugin.js'),
                                            body,
                                            r,
                                        ),
                                    );
                                    window.location.reload();
                                },
                            );
                        },
                    },
                );
            }
            start() { }
            stop() { }
        };
    }
    return (([Plugin, Api]) => {
        const plugin = (Plugin, Api) => {
            const {
                DiscordModules: { LocaleManager },
                Logger,
            } = Api;
            const {
                Webpack: { Filters, getModule },
            } = new BdApi(config.info.name);

            const toSelector = (classString) => {
                return classString ? '.' + classString.replace(/ /g, '.') : '';
            };

            const buttonClasses = getModule(Filters.byProps('emojiButton', 'stickerButton'));
            const channelTextAreaSelector = toSelector(buttonClasses.channelTextArea);
            const emojiButtonSelector = toSelector(buttonClasses.emojiButton);
            const stickerButtonSelector = toSelector(buttonClasses.stickerButton);
            const attachButtonSelector = toSelector(buttonClasses.attachButton);

            const messageActionButtonsClass = getModule(Filters.byProps('buttons', 'cozyMessage'))?.buttons;
            const messageActionButtonsSelector = toSelector(messageActionButtonsClass);

            const privateChannelsClass = getModule(Filters.byProps('privateChannels'))?.privateChannels;
            const privateChannelsSelector = toSelector(privateChannelsClass);
            const communityInfoPillClass = getModule(Filters.byProps('communityInfoPill'))?.communityInfoPill;
            const communityInfoPillSelector = toSelector(communityInfoPillClass);
            const iconItemClass = getModule(Filters.byProps('iconBase', 'iconItem'))?.iconItem;
            const iconItemSelector = toSelector(iconItemClass);

            const voiceActionButtonsClass = getModule(Filters.byProps('actionButtons', 'voiceUsers'))?.actionButtons;
            const voiceActionButtonsSelector = toSelector(voiceActionButtonsClass);

            const getCssRule = (selector) => `${selector} { display: none !important; }`;
            const getTextAreaCssRule = (child) => getCssRule(`${channelTextAreaSelector} ${child}`);
            const getAriaLabelSelector = (label) => `[aria-label="${label}"]`;
            const getAriaLabelRule = (pre, ...labels) =>
                getCssRule(labels.map((label) => `${pre || ''}${getAriaLabelSelector(label)}`).join(', '));

            const createMessagesProxy = () => {
                if (!LocaleManager) {
                    Logger.warn('LocaleManager not found!');
                    return {};
                }
                if (!LocaleManager.Messages) {
                    Logger.warn('Messages not found!');
                    return {};
                }

                return new Proxy(LocaleManager.Messages, {
                    get: (target, prop) => {
                        const message = target[prop];
                        if (typeof message === 'string') return message;
                        if (message?.message) return message.message;
                        Logger.error(`Translation not found: ${prop}`);
                        return prop;
                    },
                });
            }

            return class RemoveChatButtons extends Plugin {
                styler = new Styler(config.info.name);

                constructor() {
                    super();
                    this.refreshLocaleFn = this.refreshLocaleFn.bind(this);
                }

                addStyles() {
                    const Messages = createMessagesProxy();

                    // Chat Buttons
                    if (Messages) {
                        const { PREMIUM_GIFT_BUTTON_LABEL, GIF_BUTTON_LABEL, PREMIUM_GUILD_BOOST_THIS_SERVER } = Messages;

                        if (this.settings.giftButton)
                            this.styler.add(
                                getAriaLabelRule(channelTextAreaSelector + ' ', PREMIUM_GIFT_BUTTON_LABEL, PREMIUM_GUILD_BOOST_THIS_SERVER),
                            );
                        if (this.settings.gifButton) this.styler.add(getAriaLabelRule(channelTextAreaSelector + ' ', GIF_BUTTON_LABEL));
                    }
                    if (this.settings.emojiButton) this.styler.add(getTextAreaCssRule(emojiButtonSelector));
                    if (this.settings.stickerButton) this.styler.add(getTextAreaCssRule(stickerButtonSelector));
                    if (this.settings.attachButton) this.styler.add(getTextAreaCssRule(attachButtonSelector));

                    // Message Actions
                    if (Messages) {
                        const { ADD_REACTION, ADD_BURST_REACTION, EDIT, MESSAGE_ACTION_REPLY } = Messages;
                        if (this.settings.messageActions.reactionButton) this.styler.add(getAriaLabelRule(messageActionButtonsSelector + ' ', ADD_REACTION));
                        if (this.settings.messageActions.superReactionButton) this.styler.add(getAriaLabelRule(messageActionButtonsSelector + ' ', ADD_BURST_REACTION));
                        if (this.settings.messageActions.editButton) this.styler.add(getAriaLabelRule(messageActionButtonsSelector + ' ', EDIT));
                        if (this.settings.messageActions.replyButton) this.styler.add(getAriaLabelRule(messageActionButtonsSelector + ' ', MESSAGE_ACTION_REPLY));
                    }

                    // DMs
                    if (this.settings.dms.friendsTab) this.styler.add(getCssRule(`${privateChannelsSelector} [href="/channels/@me"]`));
                    if (this.settings.dms.premiumTab) this.styler.add(getCssRule(`${privateChannelsSelector} [href="/store"]`));
                    if (this.settings.dms.snowsgivingTab)
                        this.styler.add(getCssRule(`${privateChannelsSelector} [href="//discord.com/snowsgiving"]`));
                    if (this.settings.dms.discordBirthdayTab)
                        this.styler.add(getCssRule(`${privateChannelsSelector} [href="/activities"]`));

                    // Channels
                    if (Messages) {
                        if (this.settings.channels.publicBadge) {
                            const { DISCOVERABLE_GUILD_HEADER_PUBLIC_INFO } = Messages;
                            this.styler.add(getAriaLabelRule(communityInfoPillSelector, DISCOVERABLE_GUILD_HEADER_PUBLIC_INFO));
                        }

                        if (this.settings.channels.boostBar) {
                            const {
                                PREMIUM_GUILD_SUBSCRIPTIONS_NUDGE_TOOLTIP_COMPLETE,
                                PREMIUM_GUILD_SUBSCRIPTIONS_NUDGE_TOOLTIP,
                                PREMIUM_GUILD_TIER_1,
                                PREMIUM_GUILD_TIER_2,
                                PREMIUM_GUILD_TIER_3,
                            } = Messages;

                            const selectors = [
                                PREMIUM_GUILD_SUBSCRIPTIONS_NUDGE_TOOLTIP_COMPLETE,
                                PREMIUM_GUILD_SUBSCRIPTIONS_NUDGE_TOOLTIP.replace('{levelName}', PREMIUM_GUILD_TIER_1),
                                PREMIUM_GUILD_SUBSCRIPTIONS_NUDGE_TOOLTIP.replace('{levelName}', PREMIUM_GUILD_TIER_2),
                                PREMIUM_GUILD_SUBSCRIPTIONS_NUDGE_TOOLTIP.replace('{levelName}', PREMIUM_GUILD_TIER_3),
                            ];
                            this.styler.add(getAriaLabelRule('', ...selectors));
                        }

                        if (this.settings.channels.inviteButton) {
                            const { CREATE_INSTANT_INVITE } = Messages;

                            this.styler.add(getAriaLabelRule(iconItemSelector, CREATE_INSTANT_INVITE));
                        }
                    }

                    // Voice
                    if (Messages) {
                        const { CAMERA_ON, CAMERA_OFF, SHARE_YOUR_SCREEN, EMBEDDED_ACTIVITIES_ROCKET_BUTTON_A11Y_LABEL, EMBEDDED_ACTIVITIES_INVALID_PERMISSIONS } = Messages;

                        const actionButtons = voiceActionButtonsSelector + ' ';

                        if (this.settings.voice.cameraPanelButton) this.styler.add(getAriaLabelRule(actionButtons, CAMERA_ON, CAMERA_OFF));
                        if (this.settings.voice.screensharePanelButton) this.styler.add(getAriaLabelRule(actionButtons, SHARE_YOUR_SCREEN));
                        if (this.settings.voice.activityPanelButton)
                            this.styler.add(getAriaLabelRule(actionButtons, EMBEDDED_ACTIVITIES_ROCKET_BUTTON_A11Y_LABEL, EMBEDDED_ACTIVITIES_INVALID_PERMISSIONS));
                    }

                    // Compatibility
                    if (this.settings.compatibility.invisibleTypingButton) this.styler.add(getTextAreaCssRule('.invisible-typing-button'));
                }

                refreshStyles() {
                    this.styler.removeAll();
                    this.addStyles();
                    Logger.info('Refreshed styles.');
                }

                refreshLocaleFn() {
                    // Doesn't seem to work... Messages still holds the old value for some reason.
                    // Keeping this anyway for now.
                    setTimeout(this.refreshStyles(), 1000);
                }

                onStart() {
                    this.addStyles();
                    if (LocaleManager) LocaleManager.on('locale', this.refreshLocaleFn);
                }

                onStop() {
                    this.styler.removeAll();
                    if (LocaleManager) LocaleManager.off('locale', this.refreshLocaleFn);
                }

                getSettingsPanel() {
                    const panel = this.buildSettingsPanel();
                    panel.addListener(() => {
                        this.refreshStyles();
                    });
                    return panel.getElement();
                }
            };
        };
        return plugin(Plugin, Api);
    })(global.ZeresPluginLibrary.buildPlugin(config));
})();
/*@end@*/

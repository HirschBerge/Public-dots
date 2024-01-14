/**
* @name RemoveChatButtons
* @displayName RemoveChatButtons
* @description Remove annoying buttons like the Gift button from the chat box.
* @author Qb
* @authorId 133659541198864384
* @version 1.2.3
* @invite gj7JFa6mF8
* @source https://github.com/QbDesu/BetterDiscordAddons/blob/potato/Plugins/RemoveChatButtons
* @updateUrl https://raw.githubusercontent.com/QbDesu/BetterDiscordAddons/potato/Plugins/RemoveChatButtons/RemoveChatButtons.plugin.js
*/
/*@cc_on
@if (@_jscript)

var shell = WScript.CreateObject("WScript.Shell");
shell.Popup("It looks like you've mistakenly tried to run me directly. That's not how you install plugins. \n(So don't do that!)", 0, "I'm a plugin for BetterDiscord", 0x30);

@else@*/
module.exports = (() => {
    const config = {
        info: {
            name: "RemoveChatButtons",
            authors: [
                {
                    name: "Qb",
                    discord_id: "133659541198864384",
                    github_username: "QbDesu"
                }
            ],
            version: "1.2.3",
            description: "Remove annoying buttons like the Gift button from the chat box.",
            github: "https://github.com/QbDesu/BetterDiscordAddons/blob/potato/Plugins/RemoveChatButtons",
            github_raw: "https://raw.githubusercontent.com/QbDesu/BetterDiscordAddons/potato/Plugins/RemoveChatButtons/RemoveChatButtons.plugin.js"
        },
        defaultConfig: [
            {
                type: "switch",
                id: "giftButton",
                name: "Remove Gift/Boost Button",
                note: "Removes the Gift Nitro/Boost Server button from the chat.",
                value: true,
            },
            {
                type: "switch",
                id: "gifButton",
                name: "Remove GIF Button",
                note: "Removes the GIF button from the chat.",
                value: true,
            },
            {
                type: "switch",
                id: "stickerButton",
                name: "Remove Sticker Button",
                note: "Removes the Sticker button from the chat.",
                value: true,
            },
            {
                type: "switch",
                id: "emojiButton",
                name: "Remove Emoji Button",
                note: "Removes the Emoji button from the chat.",
                value: false,
            },
            {
                type: "switch",
                id: "attachButton",
                name: "Attach Button",
                note: "Removes the Attach button from the chat.",
                value: false,
            },
            {
                type: "switch",
                id: "cssOnly",
                name: "CSS-Only Mode",
                note: "This is useful in case there is incompatibilities with plugins or themes.",
                value: false,
            },
            {
                type: "category",
                name: "Server List",
                id: "guildList",
                settings: [
                    {
                        type: "switch",
                        name: "Nitro Button (experimental)",
                        note: "Removes the obnoxious sticky nitro button from the bottom of the server list. Fuck you Discord.",
                        id: "nitroButton",
                        value: true
                    }
                ]
            },
            {
                type: "category",
                name: "Direct Messages",
                id: "dms",
                settings: [
                    {
                        type: "switch",
                        name: "Friends Tab",
                        note: "Removes the friends tab button from the DM list.",
                        id: "friendsTab",
                        value: false
                    },
                    {
                        type: "switch",
                        name: "Nitro Tab",
                        note: "Removes the nitro tab button from the DM list.",
                        id: "premiumTab",
                        value: true
                    }
                ]
            }
        ],
        changelog: [
            {
                title: "Changes", type: "changed", items: [
                    "Adds experimental support to remove the most obnoxious STICKY variant of the nitro button in the guild list. May be a little flaky, won't make any promises nothing else breaks... Fuck you Discord."
                ]
            }
        ]
    };
    return !global.ZeresPluginLibrary ? class {
        constructor() { this._config = config; }
        load() {
            BdApi.showConfirmationModal("Library plugin is needed",
                [`The library plugin needed for ${config.info.name} is missing. Please click Download Now to install it.`], {
                confirmText: "Download",
                cancelText: "Cancel",
                onConfirm: () => {
                    require("request").get("https://rauenzi.github.io/BDPluginLibrary/release/0PluginLibrary.plugin.js", async (error, response, body) => {
                        if (error) return require("electron").shell.openExternal("https://betterdiscord.app/Download?id=9");
                        await new Promise(r => require("fs").writeFile(require("path").join(BdApi.Plugins.folder, "0PluginLibrary.plugin.js"), body, r));
                        window.location.reload();
                    });
                }
            });
        }
        start() { }
        stop() { }
    }
        : (([Plugin, Api]) => {
            const plugin = (Plugin, Api) => {
                const {
                    Patcher,
                    DOMTools,
                    WebpackModules,
                    PluginUtilities,
                    Logger
                } = Api;

                const ChannelTextAreaButtons = WebpackModules.find(m => m.type?.displayName === "ChannelTextAreaButtons")
                const ChannelTextAreaContainer = WebpackModules.find(m => m?.type?.render?.displayName === "ChannelTextAreaContainer")?.type;
                const ConnectedPrivateChannelsList = WebpackModules.find(m => m.default?.displayName === "ConnectedPrivateChannelsList");
                const HelpButton = WebpackModules.find(m => m.default?.displayName === "HelpButton");

                const Messages = WebpackModules.getByProps("PREMIUM_GIFT_BUTTON_LABEL");

                const buttonClasses = WebpackModules.getByProps("emojiButton", "stickerButton");
                const channelTextAreaSelector = new DOMTools.Selector(buttonClasses.channelTextArea);
                const emojiButtonSelector = new DOMTools.Selector(buttonClasses.emojiButton);
                const stickerButtonSelector = new DOMTools.Selector(buttonClasses.stickerButton);
                const attachButtonSelector = new DOMTools.Selector(buttonClasses.attachButton);
                const getCssKey = name => `${config.info.name}--${name}`;
                const getCssRule = child => `${channelTextAreaSelector} ${child} { display: none; }`;

                const fixedBottomListClasses = WebpackModules.getByProps("fixedBottomList");
                const listItemClasses = WebpackModules.find(m => m?.listItem && m?.tutorialContainer && !(m?.pill));

                return class RemoveChatButtons extends Plugin {
                    hideGiftKey = getCssKey("hideGiftButton");
                    hideGifKey = getCssKey("hideGifButton");
                    hideEmojiKey = getCssKey("hideEmojiButton");
                    hideStickerKey = getCssKey("hideStickerButton");
                    hideAttachKey = getCssKey("hideAttachButton");
                    //
                    hideEmojiButtonCss = getCssRule(emojiButtonSelector);
                    hideStickerButtonCss = getCssRule(stickerButtonSelector);
                    hideAttachButtonCss = getCssRule(attachButtonSelector);
                    //
                    hideGuildListNitroButtonKey = getCssKey("hideGuildListNitroButton");

                    addStyles() {
                        if (this.settings.guildList.nitroButton) {
                            if (fixedBottomListClasses?.fixedBottomList){
                                if (listItemClasses?.listItem) {
                                    PluginUtilities.addStyle(
                                        this.hideGuildListNitroButtonKey,
                                        `.${fixedBottomListClasses?.fixedBottomList} > .${listItemClasses?.listItem} { display: none; }`
                                    )
                                } else {
                                    PluginUtilities.addStyle(
                                        this.hideGuildListNitroButtonKey,
                                        `.${fixedBottomListClasses?.fixedBottomList} > * { display: none; }`
                                    )
                                }
                            } else {
                                Toasts.warn("Couldn't find class to hide nitro button from guild list.");
                            }
                        }

                        if (!this.settings.cssOnly) return;
                        if (Messages) {
                            const {PREMIUM_GIFT_BUTTON_LABEL, GIF_BUTTON_LABEL, PREMIUM_GUILD_BOOST_THIS_SERVER} = Messages;
                        
                            if (this.settings.giftButton) {
                                PluginUtilities.addStyle(
                                    this.hideGiftKey,
                                    `
                                    ${getCssRule(`[aria-label="${PREMIUM_GIFT_BUTTON_LABEL}"]`)}
                                    ${getCssRule(`[aria-label="${PREMIUM_GUILD_BOOST_THIS_SERVER}"]`)}
                                    `
                                );
                            }
                            if (this.settings.gifButton) {
                                PluginUtilities.addStyle(
                                    this.hideGifKey,
                                    getCssRule(`[aria-label="${GIF_BUTTON_LABEL}"]`)
                                );
                            }
                        }
                        if (this.settings.emojiButton) PluginUtilities.addStyle(this.hideEmojiKey, this.hideEmojiButtonCss);
                        if (this.settings.stickerButton) PluginUtilities.addStyle(this.hideStickerKey, this.hideStickerButtonCss);
                        if (this.settings.attachButton) PluginUtilities.addStyle(this.hideAttachKey, this.hideAttachButtonCss);
                    }

                    patch() {
                        Patcher.before(ChannelTextAreaContainer, "render", (_, [props]) => {
                            if (!this.settings.cssOnly && this.settings.attachButton) props.renderAttachButton = () => { };
                        });
                        Patcher.after(ChannelTextAreaButtons, "type", (_, args, ret) => {
                            if (this.settings.cssOnly) return;

                            const children = ret?.props?.children;
                            if (!children) return Logger.error("Couldn't find ChannelTextAreaButtons children.");

                            if (this.settings.giftButton) {
                                const idx = children.findIndex((e)=>e.key=="gift");
                                if (idx !== -1) children.splice(idx, 1);
                            }
                            if (this.settings.gifButton) {
                                const idx = children.findIndex((e)=>e.key=="gif");
                                if (idx !== -1) children.splice(idx, 1);
                            }
                            if (this.settings.stickerButton) {
                                const idx = children.findIndex((e)=>e.key=="sticker");
                                if (idx !== -1) children.splice(idx, 1);
                            }
                            if (this.settings.emojiButton) {
                                const idx = children.findIndex((e)=>e.key=="emoji");
                                if (idx !== -1) children.splice(idx, 1);
                            }
                        });
                        Patcher.after(ConnectedPrivateChannelsList, "default", (_, [props], ret) => {
                            const children = props?.children;

                            if (this.settings.dms.friendsTab) {
                                const idx = children.findIndex((e)=>e?.key=="friends");
                                if (idx !== -1) children.splice(idx, 1);
                            }
                            if (this.settings.dms.premiumTab) {
                                // doesn't seem to be doing anything but the prop is there, so still doing it for good measure
                                props.showNitroTab = false;
                                
                                const idx = children.findIndex((e)=>e?.key=="premium");
                                if (idx !== -1) children.splice(idx, 1);
                            }
                        });
                        Patcher.after(HelpButton, "default", (_, [props], ret) => {
                            Logger.info("HelpButton", props, ret);
                        });
                    }

                    cleanup() {
                        Patcher.unpatchAll();
                        this.removeStyles();
                    }

                    removeStyles() {
                        PluginUtilities.removeStyle(this.hideGiftKey);
                        PluginUtilities.removeStyle(this.hideGifKey);
                        PluginUtilities.removeStyle(this.hideEmojiKey);
                        PluginUtilities.removeStyle(this.hideStickerKey);
                        PluginUtilities.removeStyle(this.hideAttachKey);
                    }

                    onStart() {
                        try {
                            this.patch();
                        } catch (e) {
                            Toasts.warn(`${config.info.name}: An error occured during intialiation, falling back to CSS-Only mode.`);
                            Logger.error(`Error while patching: ${e}`);
                            console.error(e);
                            this.settings.cssOnly = true;
                            Patcher.unpatchAll();
                        }
                        this.addStyles();
                    }

                    onStop() {
                        this.cleanup();
                    }

                    getSettingsPanel() {
                        const panel = this.buildSettingsPanel();
                        panel.addListener(() => {
                            this.removeStyles();
                            this.addStyles();
                        });
                        return panel.getElement();
                    }
                };
            };
            return plugin(Plugin, Api);
        })(global.ZeresPluginLibrary.buildPlugin(config));
})();
/*@end@*/

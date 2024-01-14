/**
 * @name ClickToChat
 * @version 0.0.1
 * @description Click to open direct message
 * @website https://github.com/hobbica98/ClickToChat-BetterDiscord-Plugin
 * @source https://github.com/hobbica98/ClickToChat-BetterDiscord-Plugin/blob/master/ClickToChat.plugin.js
 */
/*@cc_on
@if (@_jscript)

    // Offer to self-install for clueless users that try to run this directly.
    var shell = WScript.CreateObject("WScript.Shell");
    var fs = new ActiveXObject("Scripting.FileSystemObject");
    var pathPlugins = shell.ExpandEnvironmentStrings("%APPDATA%\\BetterDiscord\\plugins");
    var pathSelf = WScript.ScriptFullName;
    // Put the user at ease by addressing them in the first person
    shell.Popup("It looks like you've mistakenly tried to run me directly. \n(Don't do that!)", 0, "I'm a plugin for BetterDiscord", 0x30);
    if (fs.GetParentFolderName(pathSelf) === fs.GetAbsolutePathName(pathPlugins)) {
        shell.Popup("I'm in the correct folder already.", 0, "I'm already installed", 0x40);
    } else if (!fs.FolderExists(pathPlugins)) {
        shell.Popup("I can't find the BetterDiscord plugins folder.\nAre you sure it's even installed?", 0, "Can't install myself", 0x10);
    } else if (shell.Popup("Should I copy myself to BetterDiscord's plugins folder for you?", 0, "Do you need some help?", 0x34) === 6) {
        fs.CopyFile(pathSelf, fs.BuildPath(pathPlugins, fs.GetFileName(pathSelf)), true);
        // Show the user where to put plugins in the future
        shell.Exec("explorer " + pathPlugins);
        shell.Popup("I'm installed!", 0, "Successfully installed", 0x40);
    }
    WScript.Quit();

@else@*/

module.exports = (() => {
    const config = {
        info: {
            name: "ClickToChat",
            authors: [{name: "hobbica", discord_id: "83806103388815360", github_username: "hobbica98"}],
            version: "0.0.1",
            github: 'https://github.com/hobbica98',
            github_raw: 'https://raw.githubusercontent.com/hobbica98/ClickToChat-BetterDiscord-Plugin/master/ClickToChat.plugin.js',
            github_source: 'https://github.com/hobbica98/ClickToChat-BetterDiscord-Plugin/blob/master/ClickToChat.plugin.js',
            description: "Click to open direct message"
        }
    }
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
            BdApi.showConfirmationModal("Library Missing", `The library plugin needed for ${config.info.name} is missing. Please click Download Now to install it.`, {
                confirmText: "Download Now",
                cancelText: "Cancel",
                onConfirm: () => {
                    require("request").get("https://rauenzi.github.io/BDPluginLibrary/release/0PluginLibrary.plugin.js", async (error, response, body) => {
                        if (error) return require("electron").shell.openExternal("https://betterdiscord.net/ghdl?url=https://raw.githubusercontent.com/rauenzi/BDPluginLibrary/master/release/0PluginLibrary.plugin.js");
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
            const {WebpackModules, DiscordModules, Patcher} = Api;
            const {
                React,
                ChannelStore, PrivateChannelActions,

            } = DiscordModules;
            return class ClickToChat extends Plugin {


                onStart() {
                    this.patchConnectedUser()
                }

                onStop() {
                    Patcher.unpatchAll();
                }

                async patchConnectedUser() {
                    const VoiceUser = WebpackModules.findByDisplayName('VoiceUser');
                    Patcher.after(VoiceUser.prototype, "render", (thisObject, [props], returnValue) => {
                        const user = thisObject.props.user
                        if(!returnValue.props.children.props.children || !(returnValue.props.children.props.children.find(c=> c?.props.className.includes('click-to-chat-btn')))){
                            returnValue.props.children.props.children.push(React.createElement('i', {
                                onClick: () => {
                                    PrivateChannelActions.openPrivateChannel(user.id)
                                }, style: {padding: '0 10px'},
                                className: "fas fa-arrow-right click-to-chat-btn"
                            }, React.createElement('svg',
                                {
                                    'aria-hidden': "true",
                                    'focusable': "false",
                                    'data-prefix': "far",
                                    'data-icon': "arrow-to-right",
                                    'className': "svg-inline--fa fa-arrow-to-right fa-w-14",
                                    'role': "img",
                                    'xmlns': "http://www.w3.org/2000/svg",
                                    style:{width:'18px', color:'#848181'},
                                    'viewBox': "0 0 512 512",
                                }, React.createElement('path',
                                    {
                                        fill: "currentColor",
                                        d:"M448 0H64C28.7 0 0 28.7 0 64v288c0 35.3 28.7 64 64 64h96v84c0 7.1 5.8 12 12 12 2.4 0 4.9-.7 7.1-2.4L304 416h144c35.3 0 64-28.7 64-64V64c0-35.3-28.7-64-64-64zm32 352c0 17.6-14.4 32-32 32H293.3l-8.5 6.4L192 460v-76H64c-17.6 0-32-14.4-32-32V64c0-17.6 14.4-32 32-32h384c17.6 0 32 14.4 32 32v288zM128 184c-13.3 0-24 10.7-24 24s10.7 24 24 24 24-10.7 24-24-10.7-24-24-24zm128 0c-13.3 0-24 10.7-24 24s10.7 24 24 24 24-10.7 24-24-10.7-24-24-24zm128 0c-13.3 0-24 10.7-24 24s10.7 24 24 24 24-10.7 24-24-10.7-24-24-24z" }, null)
                            )));
                        }
                    })
                }
            }


        };
        return plugin(Plugin, Api);
    })(global.ZeresPluginLibrary.buildPlugin(config));
})();
/*@end@*/

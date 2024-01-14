/**
 * @name NotificationWhitelist
 * @description Allows servers and channels to be added to a notification whitelist
 * @version 0.0.2
 * @author DeathByPrograms
 * @authorId 234086939102281728
 * @website https://github.com/deathbyprograms/BetterDiscordAddons/tree/main/dist/NotificationWhitelist
 * @source https://github.com/deathbyprograms/BetterDiscordAddons/blob/main/dist/NotificationWhitelist/NotificationWhitelist.plugin.js
 */
const config = {
    main: "index.js",
    id: "NotificationWhitelist",
    name: "NotificationWhitelist",
    author: "DeathByPrograms",
    authorId: "234086939102281728",
    authorLink: "",
    version: "0.0.2",
    description: "Allows servers and channels to be added to a notification whitelist",
    website: "https://github.com/deathbyprograms/BetterDiscordAddons/tree/main/dist/NotificationWhitelist",
    source: "https://github.com/deathbyprograms/BetterDiscordAddons/blob/main/dist/NotificationWhitelist/NotificationWhitelist.plugin.js",
    patreon: "",
    donate: "",
    invite: "",
    changelog: [],
    defaultConfig: []
};
class Dummy {
    constructor() {this._config = config;}
    start() {}
    stop() {}
}
 
if (!global.ZeresPluginLibrary) {
    BdApi.showConfirmationModal("Library Missing", `The library plugin needed for ${config.name ?? config.info.name} is missing. Please click Download Now to install it.`, {
        confirmText: "Download Now",
        cancelText: "Cancel",
        onConfirm: () => {
            require("request").get("https://betterdiscord.app/gh-redirect?id=9", async (err, resp, body) => {
                if (err) return require("electron").shell.openExternal("https://betterdiscord.app/Download?id=9");
                if (resp.statusCode === 302) {
                    require("request").get(resp.headers.location, async (error, response, content) => {
                        if (error) return require("electron").shell.openExternal("https://betterdiscord.app/Download?id=9");
                        await new Promise(r => require("fs").writeFile(require("path").join(BdApi.Plugins.folder, "0PluginLibrary.plugin.js"), content, r));
                    });
                }
                else {
                    await new Promise(r => require("fs").writeFile(require("path").join(BdApi.Plugins.folder, "0PluginLibrary.plugin.js"), body, r));
                }
            });
        }
    });
}
 
module.exports = !global.ZeresPluginLibrary ? Dummy : (([Plugin, Api]) => {
     const plugin = (Plugin, Library) => {

    const {Logger, Settings} = Library;
    
    return class extends Plugin {

        constructor() {
            super();

            // Set the default settings for the plugin
            this.defaultSettings = {};
            this.defaultSettings.serverWhitelist = [];
            this.defaultSettings.folderWhitelist = [];
            this.defaultSettings.channelWhitelist = [];
            this.defaultSettings.enableWhitelisting = true;
            this.defaultSettings.allowNonMessageNotifications = false;
            
            this.cachedModules = {};
        }

        onStart() {
            Logger.info("Plugin enabled!");
            this.contextPatchRemovers = [];

            // Add the whitelist option to the server and folder context menu.
            this.contextPatchRemovers.push(BdApi.ContextMenu.patch('guild-context', (res, props) => {
                res.props.children.push(BdApi.ContextMenu.buildItem({type: "separator"}));
                
                if(props.guild) {   // Check if the context menu is for a server.

                    res.props.children.push(BdApi.ContextMenu.buildItem({type: "toggle", label: "Notifications Whitelisted", 
                    checked: this.settings.serverWhitelist.includes(props.guild.id), action: (_) => {
                        this.toggleWhitelisted(props.guild.id, this.settings.serverWhitelist);
                    }}));

                } else if(props.folderId){  // Check if the context menu is for a folder.

                    res.props.children.push(BdApi.ContextMenu.buildItem({type: "toggle", label: "Notifications Whitelisted", 
                    checked: this.settings.folderWhitelist.includes(props.folderId), action: (_) => {
                        this.toggleWhitelisted(props.folderId, this.settings.folderWhitelist);
                    }}));

                }
            }));

            // Add the whitelist option to the channel context menu.
            this.contextPatchRemovers.push(BdApi.ContextMenu.patch('channel-context', (res, props) => {
                res.props.children.push(BdApi.ContextMenu.buildItem({type: "separator"}));
                res.props.children.push(BdApi.ContextMenu.buildItem({type: "toggle", label: "Notifications Whitelisted", 
                checked: this.settings.channelWhitelist.includes(props.channel.id), action: (_) => {
                    this.toggleWhitelisted(props.channel.id, this.settings.channelWhitelist);
                }}));
            }));

            // Add the whitelist option to the DM context menu for single users.
            this.contextPatchRemovers.push(BdApi.ContextMenu.patch('user-context', (res, props) => {
                res.props.children.push(BdApi.ContextMenu.buildItem({type: "separator"}));
                res.props.children.push(BdApi.ContextMenu.buildItem({type: "toggle", label: "Notifications Whitelisted", 
                checked: this.settings.channelWhitelist.includes(props.channel.id), action: (_) => {
                    this.toggleWhitelisted(props.channel.id, this.settings.channelWhitelist);
                }}));
            }));

            // Add the whitelist option to the group DM context menu.
            this.contextPatchRemovers.push(BdApi.ContextMenu.patch('gdm-context', (res, props) => {
                res.props.children.push(BdApi.ContextMenu.buildItem({type: "separator"}));
                res.props.children.push(BdApi.ContextMenu.buildItem({type: "toggle", label: "Notifications Whitelisted", 
                checked: this.settings.channelWhitelist.includes(props.channel.id), action: (_) => {
                    this.toggleWhitelisted(props.channel.id, this.settings.channelWhitelist);
                }}));
            }));


            var notifModule = BdApi.Webpack.getModule((m) => m.showNotification && m.requestPermission);

            // Patch the showNotification function to intercept notifications if they are not whitelisted while whitelisting is enabled.
            BdApi.Patcher.instead("NotificationWhitelist", notifModule, "showNotification", (_, args, orig) => {
                if(!this.settings.enableWhitelisting)return orig(...args);  // If whitelisting is disabled, allow the notification.
                if(!args[3])return orig(...args);   // If the showNotification function is somehow called without the proper information, allow the notification.
                if(this.settings.allowNonMessageNotifications && !args[3].channel_id && !args[3].guild_id)return orig(...args);   // If the notification is not for a channel or server (e.g. friend requests) and such notifications are allowed, allow the notification.
                if(this.settings.channelWhitelist.includes(args[3].channel_id))return orig(...args);    // If the channel is whitelisted, allow the notification.
                if(args[3].guild_id && this.settings.serverWhitelist.includes(args[3].guild_id))return orig(...args);   // If the notification is from a whitelisted server, allow the notificaiton.
                if(args[3].guild_id && this.checkIfGuildInFolderWhitelist(args[3].guild_id))return orig(...args);   // If the notification is from a whitelisted folder, allow the notification.
                Logger.debug("Blocked notification: ", args[3]);
            });
        }

        onStop() {
            Logger.info("Plugin disabled!");

            // Unpatch all the patches we made.
            BdApi.Patcher.unpatchAll("NotificationWhitelist");
            for(var patchRemover of this.contextPatchRemovers)patchRemover();
            this.contextPatchRemovers = [];
        }

        /**
         * Toggles the whitelisted status of the given id
         * 
         * @param {string} id - The id of the channel/server/folder to toggle
         * @param {Array<string>} arr - The whitelist array to toggle the id in
         */
        toggleWhitelisted(id, arr){
            if(arr.includes(id))this.removeFromWhitelist(id, arr);
            else this.addToWhitelist(id, arr);
        }

        /**
         * Whitelists the given id
         * 
         * @param {string} id - The id of the channel/server/folder to whitelist
         * @param {Array<string>} arr - The whitelist array to add the id to
         */
        addToWhitelist(id, arr){
            Logger.debug("Adding to whitelist: ", id);
            if(!arr.includes(id)){
                arr.push(id);
                this.saveSettings();
            }
        }

        /**
         * Removes the given id from the whitelist
         * 
         * @param {string} id - The id of the channel/server/folder to remove from the whitelist
         * @param {Array<string>} arr - The whitelist array to remove the id from
         */
        removeFromWhitelist(id, arr){
            Logger.debug("Removing from whitelist: ", id);
            if(arr.includes(id)){
                arr.splice(arr.indexOf(id), 1);
                this.saveSettings();
            }
        }
        
        /**
         * Clears all whitelists
         */
        clearWhitelist(){ 
            Logger.info("Clearing whitelist!");
            this.settings.serverWhitelist = [];
            this.settings.folderWhitelist = [];
            this.settings.channelWhitelist = [];
            this.saveSettings();
        }

        getSettingsPanel() {
            var button = document.createElement("button");
            button.classList = "bd-button bd-settings-button bd-setting-item";
            button.onclick = this.clearWhitelist.bind(this);
            var text = document.createTextNode("Clear Whitelist");
            button.appendChild(text);

            return Settings.SettingPanel.build(this.saveSettings.bind(this),
                new Settings.Switch("Enable Whitelisting", "Enables notification whitelisting. Note: turning this on without any whitelisted channels/servers will disable all notifications.", 
                    this.settings.enableWhitelisting, (i) => {this.settings.enableWhitelisting = i;}),
                new Settings.Switch("Allow non-message notifications", "Allows notifications that are not for messages to be shown. (e.g. friend requests)",
                    this.settings.allowNonMessageNotifications, (i) => {this.settings.allowNonMessageNotifications = i;}),
                new Settings.SettingField("Clear Whitelist", "", () => {}, button)
            )
        }

        /**
         * Checks whether the given guild is in a whitelisted folder
         * 
         * @param {string} guildId - The guild id to check
         * @returns {boolean} - Whether the guild is in a whitelisted folder
         */
        checkIfGuildInFolderWhitelist(guildId){
            if(!this.cachedModules.folderModule)
                this.cachedModules.folderModule = BdApi.Webpack.getModule((m) => m.getGuildFolderById);
            var folderModule = this.cachedModules.folderModule;
            for(var folderId of this.settings.folderWhitelist){
                if(folderModule.getGuildFolderById(folderId).guildIds.includes(guildId))return true;
            }
            return false;
        }
    };

};
     return plugin(Plugin, Api);
})(global.ZeresPluginLibrary.buildPlugin(config));
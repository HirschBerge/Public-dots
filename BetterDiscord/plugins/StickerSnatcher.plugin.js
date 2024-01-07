/**
 * @name StickerSnatcher
 * @description Allows for easy sticker saving.
 * @version 1.1.2
 * @author ImTheSquid
 * @authorId 262055523896131584
 * @website https://github.com/ImTheSquid/StickerSnatcher
 * @source https://raw.githubusercontent.com/ImTheSquid/StickerSnatcher/master/StickerSnatcher.plugin.js
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
const config = {
    info: {
        name: "StickerSnatcher",
        authors: [
            {
                name: "ImTheSquid",
                discord_id: "262055523896131584",
                github_username: "ImTheSquid",
                twitter_username: "ImTheSquid11"
            }
        ],
        version: "1.1.2",
        description: "Allows for easy sticker saving.",
        github: "https://github.com/ImTheSquid/StickerSnatcher",
        github_raw: "https://raw.githubusercontent.com/ImTheSquid/StickerSnatcher/master/StickerSnatcher.plugin.js"
    },
    changelog: [
        {
            title: "Fixes",
            items: [
                "Fixed for BD 1.8.0"
            ]
        }
    ],
    main: "index.js"
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
    "use strict";

    const {Patcher} = Library;
    const {ContextMenu, Webpack} = BdApi;

    class StickerSnatcher extends Plugin {
        onStart() {
            this.getStickerById = Webpack.getModule(Webpack.Filters.byProps("getStickerById")).getStickerById;
            this.copyImage = Webpack.getModule(Webpack.Filters.byProps("copyImage")).copyImage;
            this.canvas = document.createElement("canvas");

            this.unpatch = ContextMenu.patch("message", (tree, props) => {
                // Make sure Nitro stickers are not selectable
                if (props.message.stickerItems.length === 0 || this.getStickerById(props.message.stickerItems[0].id).type === 1) {
                    return;
                }

                const url = `https://media.discordapp.net/stickers/${props.message.stickerItems[0].id}.${props.message.stickerItems[0].format_type === 1 ? "webp" : "png"}`;

                tree.props.children[2].props.children.push(
                     ContextMenu.buildItem({type: "separator"}),
                     ContextMenu.buildItem({label: "Copy Sticker", action: () => {
                         let urlObj = new URL(url);
                         if (urlObj.pathname.endsWith(".png")) {
                             this.copyImage(url);
                         } else {
                             this.convertWebpToPng(url).then(dataURL => {
                                 DiscordNative.clipboard.copyImage(new Uint8Array(Buffer.from(dataURL.split(",")[1], "base64")), "sticker.png");
                             });
                         }
                     }}),
                     ContextMenu.buildItem({label: "Save Sticker", action: () => {
                         this.downloadAndConvertImage(url).then(buf => {
                             DiscordNative.fileManager.saveWithDialog(new Uint8Array(buf), "sticker.png");
                         });
                     }}),
                     ContextMenu.buildItem({type: "separator"})
                 );
            });
        };

        async downloadAndConvertImage(url) {
            const urlObj = new URL(url);
            
            // If URL ends with .png, no conversion needed so just download to specified path
            let arrayBuf;
            if (urlObj.pathname.endsWith(".png")) {
                arrayBuf = await fetch(url).then(r => r.blob()).then(b => b.arrayBuffer());
            } else {
                const data = await this.convertWebpToPng(url);
                const b64 = data.split(",")[1];
                arrayBuf = Buffer.from(b64, "base64");
            }

            return arrayBuf;
        }

        async convertWebpToPng(url) {
            const blob = await fetch(url).then(r => r.blob());
            const imageBitmap = await createImageBitmap(blob);

            this.canvas.width = imageBitmap.width;
            this.canvas.height = imageBitmap.height;
            let context = this.canvas.getContext("2d");

            context.drawImage(imageBitmap, 0, 0);
            return this.canvas.toDataURL("image/png");
        }

        onStop() {
            this.unpatch();
            Patcher.unpatchAll();
        };
    };

    return StickerSnatcher;
};
     return plugin(Plugin, Api);
})(global.ZeresPluginLibrary.buildPlugin(config));
/*@end@*/
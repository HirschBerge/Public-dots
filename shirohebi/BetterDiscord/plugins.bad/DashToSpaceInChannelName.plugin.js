/**
 * @name DashToSpaceInChannelName
 * @author Niemiets
 * @description Changes dashes in channels name to spaces
 * @version 0.0.6
 * @authorId 397074265708691456
 * @authorLink https://github.com/Niemiets
 * @website https://github.com/Niemiets/BD_Plugins
 * @source https://github.com/Niemiets/BD_Plugins/tree/main/DashToSpaceInChannelName
 * @updateUrl https://raw.githubusercontent.com/Niemiets/BD_Plugins/main/DashToSpaceInChannelName/DashToSpaceInChannelName.plugin.js
 */
const dashRegexp = new RegExp("-", "g")
module.exports = class DashToSpaceInChannelName{
    start() {
        this.dashToSpace(document.getElementsByClassName("channelName-2YrOjO"))
        this.dashToSpace(document.getElementsByClassName("title-29uC1r"))
        this.dashToSpace(document.getElementsByClassName("header-3uLluP"))
        this.dashToSpace(document.getElementsByClassName("description-1sDbzZ"))
    }
    stop() {
        var oldChannelName = BdApi.findModuleByProps("getChannel").getChannel(BdApi.findModuleByProps("getChannelId").getChannelId()).name
        for(var i = 0;document.getElementsByClassName("channelName-2YrOjO").length > i;i++){
            BdApi.ReactDOM.render(BdApi.findModuleByProps("getChannel").getChannel(document.getElementsByClassName("mainContent-u_9PKf")[i].dataset.listItemId.slice(11,document.getElementsByClassName("mainContent-u_9PKf")[i].dataset.listItemId.length)).name, document.getElementsByClassName("channelName-2YrOjO")[i])
        }

        BdApi.ReactDOM.render(oldChannelName, document.getElementsByClassName("title-29uC1r")[0])

        BdApi.ReactDOM.render(document.getElementsByClassName("header-3uLluP")[0].textContent.split(oldChannelName.replace(dashRegexp, " "))[0] + oldChannelName + document.getElementsByClassName("header-3uLluP")[0].textContent.split(oldChannelName.replace(dashRegexp, " "))[1], document.getElementsByClassName("header-3uLluP")[0])
        BdApi.ReactDOM.render(document.getElementsByClassName("description-1sDbzZ")[0].textContent.split(oldChannelName.replace(dashRegexp, " "))[0] + oldChannelName + document.getElementsByClassName("description-1sDbzZ")[0].textContent.split(oldChannelName.replace(dashRegexp, " "))[1], document.getElementsByClassName("description-1sDbzZ")[0])
    }
    observer(changes){
        if(changes.addedNodes[0] != undefined && typeof changes.addedNodes[0].className == "string" && changes.addedNodes[0].textContent.includes("-")){
            for(var i = 0; i < changes.addedNodes[0].className.split(" ").length; i++){
                switch (changes.addedNodes[0].className.split(" ")[i]) {
                    case "containerDefault--pIXnN":
                        this.dashToSpace(document.getElementsByClassName("channelName-2YrOjO"))
                        break;
                    case "title-3qD0b-":
                        this.dashToSpace(document.getElementsByClassName("title-29uC1r"))
                        break;
                    case "container-3RCQyg":
                        this.dashToSpace(document.getElementsByClassName("header-3uLluP"))
                        this.dashToSpace(document.getElementsByClassName("description-1sDbzZ"))
                        break;
                    case "chatContent-a9vAAp":
                        this.dashToSpace(document.getElementsByClassName("header-3uLluP"))
                        this.dashToSpace(document.getElementsByClassName("description-1sDbzZ"))
                        break;
                }
            }
        }
    }
    dashToSpace(elements){
        for(var i = 0;i < elements.length;i++){
            BdApi.ReactDOM.render(elements[i].textContent.replace(dashRegexp, " "), elements[i])
        }
    }
}

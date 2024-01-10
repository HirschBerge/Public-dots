/**
 * @name FileViewer
 * @author AGreenPig
 * @updateUrl https://raw.githubusercontent.com/TheGreenPig/BetterDiscordPlugins/main/FileViewer/FileViewer.plugin.js
 * @authorLink https://github.com/TheGreenPig
 * @source https://github.com/TheGreenPig/BetterDiscordPlugins/main/FileViewer/FileViewer.plugin.js
 * @invite JsqBVSCugb
 * @version 2.0.0
 */
module.exports = (() => {
	const config = {
		info: {
			name: "FileViewer",
			authors: [
				{
					name: "AGreenPig",
					discord_id: "427179231164760066",
					github_username: "TheGreenPig",
				},
			],
			version: "2.0.0",
			description: "View Pdf and other files directly in Discord.",
			github_raw: "https://raw.githubusercontent.com/TheGreenPig/BetterDiscordPlugins/main/FileViewer/FileViewer.plugin.js",
		},
		changelog: [
			{
				title: "Fixed",
				type: "fixed",
				items: [
					`Completely rewrote pretty much the entire plugin to deal with the new Discord update. 
					It uses DOM manipulation now, so it's possible that it is a little buggy at times. Should generally work though.`,
				],
			},
		],
	};
	const css = `
		.FileViewerEmbed {
			resize: both; 
			overflow: auto;
			padding: 10px;
			max-width: 100%;
			min-width: 300px;
			max-height: 80vh;
			min-height: 100px;
		}
	`;
	return !global.ZeresPluginLibrary
		? class {
				constructor() {
					this._config = config;
				}
				getName() {
					return config.info.name;
				}
				getAuthor() {
					return config.info.authors.map((a) => a.name).join(", ");
				}
				getDescription() {
					return config.info.description;
				}
				getVersion() {
					return config.info.version;
				}
				load() {
					BdApi.showConfirmationModal(
						"Library Missing",
						`The library plugin needed for ${config.info.name} is missing. Please click Download Now to install it.`,
						{
							confirmText: "Download Now",
							cancelText: "Cancel",
							onConfirm: () => {
								require("request").get(
									"https://rauenzi.github.io/BDPluginLibrary/release/0PluginLibrary.plugin.js",
									async (error, response, body) => {
										if (error) return require("electron").shell.openExternal("https://betterdiscord.app/Download?id=9");
										await new Promise((r) =>
											require("fs").writeFile(require("path").join(BdApi.Plugins.folder, "0PluginLibrary.plugin.js"), body, r)
										);
									}
								);
							},
						}
					);
				}
				start() {}
				stop() {}
		  }
		: (([Plugin, Api]) => {
				const plugin = (Plugin, Library) => {
					const {
						Settings,
						Utilities,
						Webpack: { Filters, getBulk },
						DiscordClasses,
						ReactTools,
					} = {
						...BdApi,
						...Api,
					};
					const { SettingPanel, Switch } = Settings;

					const ClassFilters = [
						Filters.byProps("attachment", "metadata"),
						Filters.byProps("layerContainer"),
						Filters.byProps("messageAttachment"),
					].map((fn) => ({ filter: fn }));

					const Classes = {};
					Object.assign(Classes, ...getBulk.apply(null, ClassFilters));

					// Massive thanks to Strencher for the createElement, getReactProps functions, 
					// the tooltip and just general fixes
					// Thanks a lot! <3
					const createElement = (type, props, ...children) => {
						if (typeof type === "function") return type({ ...props, children: [].concat() });

						const node = document.createElement(type);

						for (const key of Object.keys(props)) {
							if (key.indexOf("on") === 0) node.addEventListener(key.slice(2).toLowerCase(), props[key]);
							else if (key === "children") {
								node.append(...(Array.isArray(props[key]) ? props[key] : [].concat(props[key])));
							} else {
								node.setAttribute(key === "className" ? "class" : key, props[key]);
							}
						}

						if (children.length) node.append(...children);

						return node;
					};

					const getReactProps = (el, filter = (_) => _) => {
						const instance = ReactTools.getReactInstance(el);

						for (let current = instance.return, i = 0; i > 10000 || current !== null; current = current?.return, i++) {
							if (current?.pendingProps && filter(current.pendingProps)) return current.pendingProps;
						}

						return null;
					};

					const htmlToElement = (html) => {
						const template = document.createElement("template");
						html = html.trim();
						template.innerHTML = html;

						return template.content.firstChild;
					};

					const wrapIcon = (color, viewBox, path) =>
						`<svg class="${Classes.downloadButton}" aria-hidden="true" role="img" width="24" height="24" viewBox="${viewBox}"><path fill="${color}" d="${path}"></path></svg>`;
					
						//Thanks Dastan21 for the icons <3
					const ShowIcon = wrapIcon(
						"currentColor",
						"0 0 226 226",
						"M113,37.66667c-75.33333,0 -103.58333,75.33333 -103.58333,75.33333c0,0 28.25,75.33333 103.58333,75.33333c75.33333,0 103.58333,-75.33333 103.58333,-75.33333c0,0 -28.25,-75.33333 -103.58333,-75.33333zM113,65.91667c25.99942,0 47.08333,21.08392 47.08333,47.08333c0,25.99942 -21.08392,47.08333 -47.08333,47.08333c-25.99942,0 -47.08333,-21.08392 -47.08333,-47.08333c0,-25.99942 21.08392,-47.08333 47.08333,-47.08333zM113,84.75c-15.60204,0 -28.25,12.64796 -28.25,28.25c0,15.60204 12.64796,28.25 28.25,28.25c15.60204,0 28.25,-12.64796 28.25,-28.25c0,-15.60204 -12.64796,-28.25 -28.25,-28.25z"
					);
					const HideIcon = wrapIcon(
						"currentColor",
						"0 0 226 226",
						"M37.57471,28.15804c-3.83186,0.00101 -7.28105,2.32361 -8.72295,5.87384c-1.4419,3.55022 -0.58897,7.62011 2.15703,10.29267l16.79183,16.79183c-18.19175,14.60996 -29.9888,32.52303 -35.82747,43.03711c-3.12633,5.63117 -3.02363,12.41043 0.03678,18.07927c10.87625,20.13283 42.14532,66.10058 100.99007,66.10058c19.54493,0 35.83986,-5.13463 49.36394,-12.65365l19.31152,19.31152c2.36186,2.46002 5.8691,3.45098 9.16909,2.5907c3.3,-0.86028 5.87708,-3.43736 6.73736,-6.73736c0.86028,-3.3 -0.13068,-6.80724 -2.5907,-9.16909l-150.66666,-150.66667c-1.77289,-1.82243 -4.20732,-2.8506 -6.74984,-2.85075zM113,37.66667c-11.413,0 -21.60375,1.88068 -30.91683,4.81869l24.11182,24.11182c2.23175,-0.32958 4.47909,-0.6805 6.80501,-0.6805c25.99942,0 47.08333,21.08392 47.08333,47.08333c0,2.32592 -0.35092,4.57326 -0.6805,6.80501l32.29623,32.29623c10.1135,-11.22467 17.51573,-22.61015 21.94157,-30.18115c3.3335,-5.68767 3.32011,-12.67425 0.16553,-18.4655c-11.00808,-20.27408 -42.2439,-65.78792 -100.80615,-65.78792zM73.77002,87.08577l13.77555,13.77556c-1.77707,3.67147 -2.79557,7.77466 -2.79557,12.13867c0,15.60342 12.64658,28.25 28.25,28.25c4.364,0 8.46719,-1.01851 12.13867,-2.79557l13.79395,13.79395c-9.356,6.20362 -21.03043,9.17606 -33.4733,7.24642c-19.75617,-3.06983 -35.88427,-19.19794 -38.9541,-38.9541c-1.92879,-12.43739 1.0665,-24.10096 7.26481,-33.45491z"
					);
					const WarningIcon = wrapIcon(
						"red",
						"0 0 24 24",
						"M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm-1.351 6.493c-.08-.801.55-1.493 1.351-1.493s1.431.692 1.351 1.493l-.801 8.01c-.029.282-.266.497-.55.497s-.521-.215-.55-.498l-.801-8.009zm1.351 12.757c-.69 0-1.25-.56-1.25-1.25s.56-1.25 1.25-1.25 1.25.56 1.25 1.25-.56 1.25-1.25 1.25z"
					);

					const officeExtensions = ["ppt", "pptx", "doc", "docx", "xls", "xlsx", "odt"];
					const googleExtensions = ["pdf"];
					const objectExtensions = ["stl", "obj", "vf", "vsj", "vsb", "3mf"];

					class Tooltip {
						containerClassName = Utilities.className(
							"FileViewerTooltip",
							...["tooltip", "tooltipTop", "tooltipPrimary"].map((c) => DiscordClasses.Tooltips?.[c]?.value)
						);
						pointerClassName = DiscordClasses.Tooltips?.tooltipPointer?.value;
						contentClassName = DiscordClasses.Tooltips?.tooltipContent?.value;

						constructor(target, { text, spacing }) {
							this.target = target;
							this.ref = null;
							this.text = text;
							this.spacing = spacing;
							this.tooltip = createElement("div", {
								className: this.containerClassName,
								style: "visibility: hidden; position: fixed;",
								children: [
									createElement("div", { className: this.pointerClassName, style: "left: calc(50% + 0px)" }),
									createElement("div", { className: this.contentClassName }, text),
								],
							});

							this.target.addEventListener("mouseenter", () => {
								this.show();
							});

							this.target.addEventListener("mouseleave", () => {
								this.hide();
							});
						}

						get container() {
							const { layerContainer } = Classes;
							return document.querySelector(`.${layerContainer} ~ .${layerContainer}`);
						}

						checkOffset(x, y) {
							if (y < 0) {
								y = 0;
							} else if (y > window.innerHeight) {
								y = window.innerHeight;
							}

							if (x > window.innerWidth) {
								x = window.innerWidth;
							} else if (x < 0) {
								x = 0;
							}

							return { x, y };
						}

						show() {
							const tooltip = (this.ref = this.tooltip.cloneNode(true));
							this.container.appendChild(tooltip);

							const targetRect = this.target.getBoundingClientRect();
							const tooltipRect = tooltip.getBoundingClientRect();

							let top = targetRect.y - tooltipRect.height - this.spacing;
							let left = targetRect.x + targetRect.width / 2 - tooltipRect.width / 2;

							const position = this.checkOffset(left, top);

							tooltip.style = `position: fixed; top: ${position.y}px; left: ${position.x}px;`;
						}

						hide() {
							this.ref?.remove();
						}

						destroy() {
							this.hide();
							this.target.removeEventListener("mouseenter", () => {
								this.show();
							});

							this.target.removeEventListener("mouseleave", () => {
								this.hide();
							});
							this.tooltip?.remove();
						}
					}

					class FileViewerButton {
						constructor(target, url) {
							this.open = false;
							this.target = target;
							this.ref = null;
							this.url = url;
							this.fileViewRef = null;
						}
						mount() {
							const res = this.render();
							this.target.append();
							if (!res) this.ref?.remove();
							else {
								if (this.ref) {
									this.ref.replaceWith(res);
								} else {
									this.target.appendChild(res);
								}

								this.ref = res;
							}
						}
						render() {
							const icon = htmlToElement(this.open ? HideIcon : ShowIcon);
							const tooltip = new Tooltip(icon, {
								text: `${this.open ? "Hide File Preview" : "Show"}  File Preview`,
								spacing: 8,
							});
							const container = createElement(
								"div",
								{
									className: "FileViewerButton",
									onclick: () => {
										this.open = !this.open;
										this.mount();
										tooltip.destroy();
									},
								},
								icon
							);
							if (!this.fileViewRef && this.open) {
								const embed = htmlToElement(`<iframe class="FileViewerEmbed" src="${this.url}" width="450" height="500"></iframe>`);

								this.target.closest(`.${Classes.messageAttachment}`).parentNode.appendChild(embed);
								this.fileViewRef = embed;
							} else {
								this.fileViewRef?.remove();
								this.fileViewRef = null;
							}
							return container;
						}
					}
					return class FileViwer extends Plugin {
						start() {
							this.settings = this.loadSettings({
								forceProvider: false,
							});
							BdApi.injectCSS(config.info.name, css);
						}
						addViewerButton(attachmentElement) {
							const { url, size } = getReactProps(attachmentElement);
							if (!url) return;

							let isGoogleExtension = googleExtensions.some((e) => {
								return url.toLowerCase().endsWith(e);
							});
							let isOfficeExtension = officeExtensions.some((e) => {
								return url.toLowerCase().endsWith(e);
							});
							let isOjectExtension = objectExtensions.some((e) => {
								return url.toLowerCase().endsWith(e);
							});
							if (!isGoogleExtension && !isOfficeExtension && !isOjectExtension) {
								return;
							}

							let googleUrl = `https://drive.google.com/viewerng/viewer?embedded=true&url=${url}`;
							let officeUrl = `https://view.officeapps.live.com/op/view.aspx?src=${url}`;
							let objectUrl = `https://www.viewstl.com/?embedded&url=${url}`;
							let useGoogleProvider = this.settings.forceProvider || isGoogleExtension;

							new FileViewerButton(
								attachmentElement,
								isOjectExtension ? objectUrl : useGoogleProvider ? googleUrl : officeUrl
							).mount();

							//in bytes--> 10mb
							let fileTooBig = 10485760 < size;
							if (fileTooBig) {
								const warningIcon = htmlToElement(WarningIcon);
								attachmentElement.append(warningIcon);
								new Tooltip(warningIcon, {
									text: "This file is over 10mb! FileViewer might not be able to preview this file.",
									spacing: 8,
								});
							}
						}
						getSettingsPanel() {
							//build the settings panel
							return SettingPanel.build(
								() => this.saveSettings(this.settings),
								new Switch(
									"Force Google provider",
									`By default all office related files will be displayed by the Office Web Apps Viewer, 
									all other files the Google Docs Viewer to allow for the best overall experience. 
									If you only want to use the Google Docs Viewer, turn this setting on (some office files might not be displayed correctly).`,
									this.settings.forceProvider,
									(i) => {
										this.settings.forceProvider = i;
									}
								)
							);
						}
						observer({ addedNodes }) {
							for (const added of addedNodes) {
								if (added.nodeType === Node.TEXT_NODE) continue;
								const attachmentElement = added.getElementsByClassName(Classes.attachment);
								if (attachmentElement.length > 0) {
									Array.from(attachmentElement).forEach((a) => {
										if (a.getElementsByClassName("FileViewerButton").length > 0) return;
										this.addViewerButton(a);
									});
								}
							}
						}
						stop() {
							BdApi.clearCSS(config.info.name);
						}
					};
				};
				return plugin(Plugin, Api);
		  })(global.ZeresPluginLibrary.buildPlugin(config));
})();

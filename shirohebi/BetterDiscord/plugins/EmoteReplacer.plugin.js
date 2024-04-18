/**
 * @name EmoteReplacer
 * @version 2.1.4
 * @description Check for known emote names and replace them with an embedded image of the emote. Also supports modifiers similar to BetterDiscord's emotes. Standard emotes: https://yentis.github.io/emotes/
 * @license MIT
 * @author Yentis
 * @authorId 68834122860077056
 * @website https://github.com/Yentis/betterdiscord-emotereplacer
 * @source https://raw.githubusercontent.com/Yentis/betterdiscord-emotereplacer/master/EmoteReplacer.plugin.js
 */
'use strict';

var electron = require('electron');
var fs = require('fs');
var path = require('path');

class Logger {
  static pluginName;

  static setLogger(pluginName) {
    this.pluginName = pluginName;
  }

  static debug(...args) {
    console.debug(this.pluginName, ...args);
  }

  static info(...args) {
    console.info(this.pluginName, ...args);
  }

  static warn(...args) {
    console.warn(this.pluginName, ...args);
  }

  static error(...args) {
    console.error(this.pluginName, ...args);
  }
}

class Utils {
  static urlGetBuffer(url) {
    if (url.startsWith('http')) return Utils.fetchGetBuffer(url);
    else return Utils.fsGetBuffer(url);
  }

  static async fsGetBuffer(url) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    const data = fs.readFileSync(url, '');
    return await Promise.resolve(data);
  }

  static async fetchGetBuffer(url) {
    // TODO: remove custom TS type when BD types are updated

    const response = await BdApi.Net.fetch(url);
    const statusCode = response.status;
    if (statusCode !== 0 && (statusCode < 200 || statusCode >= 400)) {
      throw new Error(response.statusText);
    }
    if (!response.body) throw new Error(`No response body for url: ${url}`);

    const arrayBuffer = await response.arrayBuffer();
    return new Uint8Array(arrayBuffer);
  }

  static async loadImagePromise(url, waitForLoad = true, element) {
    const image = element ?? new Image();

    const loadPromise = new Promise((resolve, reject) => {
      image.onload = () => {
        resolve();
      };
      image.onerror = () => {
        reject(new Error(`Failed to load image for url ${url}`));
      };
    });

    if (url.startsWith('http') && !waitForLoad) {
      image.src = url;
    } else {
      const buffer = await Utils.urlGetBuffer(url);
      image.src = URL.createObjectURL(new Blob([buffer]));
    }

    if (waitForLoad) await loadPromise;
    return image;
  }

  static delay(duration) {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve();
      }, duration);
    });
  }

  static workerMessagePromise(worker, request) {
    return new Promise((resolve, reject) => {
      worker.onterminate = () => {
        reject(new Error('Cancelled'));
      };

      worker.onerror = (error) => {
        reject(error);
      };

      worker.onmessage = (message) => {
        const response = message.data;
        if (response.type !== request.type) return;

        if (response.data instanceof Error) {
          reject(response.data);
        } else {
          resolve(response.data);
        }
      };

      worker.postMessage(request);
    });
  }

  static clamp(num, min, max) {
    return Math.min(Math.max(num, min), max);
  }
}

class RawPlugin {
  meta;

  constructor(meta) {
    this.meta = meta;
    Logger.setLogger(meta.name);
  }

  start() {
    this.showLibraryMissingModal();
  }

  showLibraryMissingModal() {
    BdApi.UI.showConfirmationModal(
      'Library Missing',
      `The library plugin needed for ${this.meta.name} is missing. ` +
        'Please click Download Now to install it.',
      {
        confirmText: 'Download Now',
        cancelText: 'Cancel',
        onConfirm: () => {
          Utils.urlGetBuffer(
            'https://rauenzi.github.io/BDPluginLibrary/release/0PluginLibrary.plugin.js'
          )
            .then((data) => {
              fs.writeFile(
                path.join(BdApi.Plugins.folder, '0PluginLibrary.plugin.js'),
                data,
                () => {
                  /* Do nothing */
                }
              );
            })
            .catch(() => {
              electron.shell
                .openExternal(
                  'https://betterdiscord.net/ghdl?url=https://raw.githubusercontent.com/rauenzi' +
                    '/BDPluginLibrary/master/release/0PluginLibrary.plugin.js'
                )
                .catch((error) => {
                  Logger.error(error);
                });
            });
        },
      }
    );
  }

  stop() {
    // Do nothing
  }
}

const PLUGIN_CHANGELOG = [
  {
    title: '2.1.4',
    type: 'fixed',
    items: ['Fix broken plugin due to Discord update'],
  },
  {
    title: '2.1.3',
    type: 'fixed',
    items: ['Fix emotes not working', 'Fix stickers not being animated'],
  },
  {
    title: '2.1.2',
    type: 'fixed',
    items: [
      'Fix custom emote search not showing',
      'Fix emotes sometimes not sendable',
    ],
  },
];

const SETTINGS_KEY = 'settings';
const CURRENT_VERSION_INFO_KEY = 'currentVersionInfo';
const DEFAULT_SETTINGS = {
  emoteSize: 48,
  autocompleteEmoteSize: 15,
  autocompleteItems: 10,
  customEmotes: {},
  requirePrefix: true,
  prefix: ';',
  resizeMethod: 'smallest',
  showStandardEmotes: true,
};

const EMOTE_MODIFIERS = [
  {
    name: 'flip',
    type: 'normal',
    info: 'Flip emote horizontally',
  },
  {
    name: 'flap',
    type: 'normal',
    info: 'Flip emote vertically',
  },
  {
    name: 'rotate',
    type: 'normal',
    info: 'Rotate by x degrees',
    arguments: ['number'],
  },
  {
    name: 'speed',
    type: 'normal',
    info: 'Delay between frames in hundredths of a second',
    arguments: ['number'],
  },
  {
    name: 'hyperspeed',
    type: 'normal',
    info: 'Remove every other frame and use minimum frame delay',
  },
  {
    name: 'reverse',
    type: 'normal',
    info: 'Play animation backwards',
  },
  {
    name: 'spin',
    type: 'gif',
    info: 'Spin emote clockwise, options: empty, fast, faster, hyper',
    arguments: ['', 'fast', 'faster', 'hyper'],
  },
  {
    name: 'spinrev',
    type: 'gif',
    info: 'Spin emote counter-clockwise, options: empty, fast, faster, hyper',
    arguments: ['', 'fast', 'faster', 'hyper'],
  },
  {
    name: 'slide',
    type: 'gif',
    info: 'Slide emote from right to left, options: empty, fast, faster, hyper',
    arguments: ['', 'fast', 'faster', 'hyper'],
  },
  {
    name: 'sliderev',
    type: 'gif',
    info: 'Slide emote from left to right, options: empty, fast, faster, hyper',
    arguments: ['', 'fast', 'faster', 'hyper'],
  },
  {
    name: 'shake',
    type: 'gif',
    info: 'Shake emote, options: empty, fast, faster, hyper',
    arguments: ['', 'fast', 'faster', 'hyper'],
  },
  {
    name: 'rainbow',
    type: 'gif',
    info: 'Strobe emote, options: empty, fast, faster, hyper',
    arguments: ['', 'fast', 'faster', 'hyper'],
  },
  {
    name: 'infinite',
    type: 'gif',
    info: 'Pulse emote outwards, options: empty, fast, faster, hyper',
    arguments: ['', 'fast', 'faster', 'hyper'],
  },
  {
    name: 'wiggle',
    type: 'gif',
    info: 'Wiggle emote, options: empty, fast, faster, hyper',
    arguments: ['', 'fast', 'faster', 'hyper'],
  },
  {
    name: 'wide',
    type: 'normal',
    info: 'Increase emote width, options: empty, big, huge, extreme, 2 - 8',
    arguments: ['', 'big', 'huge', 'extreme', 'number'],
  },
  {
    name: 'resize',
    type: 'normal',
    info: 'Resize emote, options: small, medium, large, 32 - 128',
    arguments: ['small', 'medium', 'large', 'number'],
  },
  {
    name: 'rain',
    type: 'gif',
    info: 'Add rain, options: empty, glitter',
    arguments: ['', 'glitter'],
  },
];

class BaseService {
  plugin;
  zeresPluginLibrary;

  constructor(plugin, zeresPluginLibrary) {
    this.plugin = plugin;
    this.zeresPluginLibrary = zeresPluginLibrary;
  }
}

class CompletionsService extends BaseService {
  static TAG = CompletionsService.name;
  static TEXTAREA_KEYDOWN_LISTENER = 'textAreaKeydown';
  static TEXTAREA_WHEEL_LISTENER = 'textAreaWheel';
  static TEXTAREA_FOCUS_LISTENER = 'textAreaFocus';
  static TEXTAREA_BLUR_LISTENER = 'textAreaBlur';
  static AUTOCOMPLETE_DIV_WHEEL_LISTENER = 'autocompleteDivWheel';
  static EMOTE_ROW_MOUSEENTER_LISTENER = 'emoteRowMouseenter';
  static EMOTE_ROW_MOUSEDOWN_LISTENER = 'emoteRowMousedown';

  emoteService;
  settingsService;
  modulesService;
  listenersService;
  htmlService;
  attachService;

  draft = '';
  cached;
  curEditor;

  start(
    emoteService,
    settingsService,
    modulesService,
    listenersService,
    htmlService,
    attachService
  ) {
    this.emoteService = emoteService;
    this.settingsService = settingsService;
    this.modulesService = modulesService;
    this.listenersService = listenersService;
    this.htmlService = htmlService;
    this.attachService = attachService;

    this.listenersService.addListenersWatchers[CompletionsService.TAG] = {
      onAddListeners: () => {
        this.addListeners();
      },
    };
    this.addListeners();

    return Promise.resolve();
  }

  addListeners() {
    const editors = this.htmlService.getEditors();
    if (editors.length === 0) return;
    this.curEditor = editors[0];

    this.listenersService.removeListeners(
      CompletionsService.TEXTAREA_KEYDOWN_LISTENER
    );
    this.listenersService.removeListeners(
      CompletionsService.TEXTAREA_WHEEL_LISTENER
    );
    this.listenersService.removeListeners(
      CompletionsService.TEXTAREA_FOCUS_LISTENER
    );
    this.listenersService.removeListeners(
      CompletionsService.TEXTAREA_BLUR_LISTENER
    );

    editors.forEach((editor, index) => {
      const focusListener = {
        element: editor,
        name: 'focus',
        callback: () => {
          this.curEditor = editor;
        },
      };

      editor.addEventListener(focusListener.name, focusListener.callback);
      this.listenersService.addListener(
        `${CompletionsService.TEXTAREA_FOCUS_LISTENER}${index}`,
        focusListener
      );

      const blurListener = {
        element: editor,
        name: 'blur',
        callback: () => {
          this.destroyCompletions();
          this.curEditor = undefined;
        },
      };

      editor.addEventListener(blurListener.name, blurListener.callback);
      this.listenersService.addListener(
        `${CompletionsService.TEXTAREA_BLUR_LISTENER}${index}`,
        blurListener
      );

      const textArea = this.htmlService.getTextAreaField(editor);
      if (!textArea) return;

      const keydownListener = {
        element: textArea,
        name: 'keydown',
        callback: (evt) => {
          this.browseCompletions(evt);
        },
      };

      textArea.addEventListener(keydownListener.name, keydownListener.callback);
      this.listenersService.addListener(
        `${CompletionsService.TEXTAREA_KEYDOWN_LISTENER}${index}`,
        keydownListener
      );

      const wheelListener = {
        element: textArea,
        name: 'wheel',
        callback: (evt) => {
          this.scrollCompletions(evt);
        },
      };

      textArea.addEventListener(wheelListener.name, wheelListener.callback, {
        passive: true,
      });

      this.listenersService.addListener(
        `${CompletionsService.TEXTAREA_WHEEL_LISTENER}${index}`,
        wheelListener
      );
    });
  }

  browseCompletions(event) {
    if (
      !this.emoteService.shouldCompleteEmote(this.draft) &&
      !this.emoteService.shouldCompleteCommand(this.draft)
    ) {
      return;
    }

    let delta = 0,
      options;
    const autocompleteItems = Math.round(
      this.settingsService.settings.autocompleteItems
    );

    switch (event.key) {
      case 'Tab':
      case 'Enter':
        if (!this.prepareCompletions()) {
          break;
        }

        // Prevent Discord's default behavior (send message)
        event.stopPropagation();
        // Prevent adding a tab or line break to text
        event.preventDefault();

        this.insertSelectedCompletion().catch((error) => Logger.error(error));
        break;

      case 'ArrowUp':
        delta = -1;
        break;

      case 'ArrowDown':
        delta = 1;
        break;

      case 'PageUp':
        delta = -autocompleteItems;
        options = { locked: true, clamped: true };
        break;

      case 'PageDown':
        delta = autocompleteItems;
        options = { locked: true, clamped: true };
        break;
    }

    if (delta !== 0 && this.prepareCompletions()) {
      // Prevent Discord's default behavior
      event.stopPropagation();
      // Prevent cursor movement
      event.preventDefault();

      this.scrollWindow(delta, options);
    }
  }

  prepareCompletions() {
    const candidateText = this.draft;
    const lastText = this.cached?.candidateText;

    if (lastText !== candidateText) {
      if (this.emoteService.shouldCompleteEmote(candidateText)) {
        const { completions, matchText, matchStart } =
          this.emoteService.getCompletionsEmote(candidateText);

        this.cached = {
          candidateText,
          completions,
          matchText,
          matchStart,
          selectedIndex: 0,
          windowOffset: 0,
        };
      } else if (this.emoteService.shouldCompleteCommand(candidateText)) {
        const { completions, matchText, matchStart } =
          this.emoteService.getCompletionsCommands(candidateText);

        this.cached = {
          candidateText,
          completions,
          matchText,
          matchStart,
          selectedIndex: 0,
          windowOffset: 0,
        };
      }
    }

    const { completions } = this.cached ?? {};
    return completions !== undefined && completions.length !== 0;
  }

  async insertSelectedCompletion() {
    const { completions, matchText, selectedIndex } = this.cached ?? {};
    const curDraft = this.draft;
    const matchTextLength = matchText?.length ?? 0;
    const channelId = this.attachService.curChannelId;

    if (
      completions === undefined ||
      selectedIndex === undefined ||
      channelId === undefined
    ) {
      return;
    }

    const selectedCompletion = completions[selectedIndex];
    if (!selectedCompletion) return;
    const completionValueArguments =
      typeof selectedCompletion.data === 'string'
        ? undefined
        : selectedCompletion.data.arguments;

    let suffix = ' ';
    if (completionValueArguments) {
      const argumentOptional = completionValueArguments.some((argument) => {
        return argument === '';
      });

      if (!argumentOptional) suffix = '-';
    }
    selectedCompletion.name += suffix;

    const newDraft = curDraft.substring(0, curDraft.length - matchTextLength);
    this.destroyCompletions();

    await this.insertDraft(channelId, newDraft + selectedCompletion.name);
  }

  async insertDraft(channelId, draft) {
    await new Promise((resolve) => {
      const listener = () => {
        resolve();
        this.modulesService.draftStore.removeChangeListener(listener);
      };

      this.modulesService.draftStore.addChangeListener(listener);
      this.modulesService.draft.clearDraft(channelId, 0);
    });

    this.modulesService.componentDispatcher.dispatchToLastSubscribed(
      'INSERT_TEXT',
      { plainText: draft }
    );
  }

  destroyCompletions() {
    const textAreaContainer = this.htmlService.getTextAreaContainer(
      this.curEditor
    );

    if (textAreaContainer) {
      const completions = this.htmlService
        .getTextAreaContainer(this.curEditor)
        ?.querySelectorAll(`.${this.plugin.meta.name}`);

      completions?.forEach((completion) => {
        completion.remove();
      });
    }

    this.cached = undefined;
  }

  doRenderCompletions() {
    const channelTextArea = this.htmlService.getTextAreaContainer(
      this.curEditor
    );
    if (!channelTextArea) return;

    const oldAutoComplete =
      channelTextArea?.querySelectorAll(`.${this.plugin.meta.name}`) ?? [];
    const discordClasses = this.modulesService.classes;
    const isEmote = this.emoteService.shouldCompleteEmote(this.draft);

    for (const autoComplete of oldAutoComplete) {
      autoComplete.remove();
    }

    if (
      (!this.emoteService.shouldCompleteEmote(this.draft) &&
        !this.emoteService.shouldCompleteCommand(this.draft)) ||
      !this.prepareCompletions()
    ) {
      return;
    }

    const { completions, matchText, selectedIndex } = this.cached ?? {};
    const firstIndex = this.cached?.windowOffset ?? 0;
    const matchList = completions?.slice(
      firstIndex,
      firstIndex + Math.round(this.settingsService.settings.autocompleteItems)
    );

    const autocompleteDiv = document.createElement('div');
    this.htmlService.addClasses(
      autocompleteDiv,
      discordClasses.Autocomplete.autocomplete,
      this.plugin.meta.name
    );
    const autocompleteListener = {
      element: autocompleteDiv,
      name: 'wheel',
      callback: (evt) => {
        this.scrollCompletions(evt, { locked: true });
      },
    };

    autocompleteDiv.addEventListener(
      autocompleteListener.name,
      autocompleteListener.callback,
      { passive: true }
    );

    this.listenersService.addListener(
      CompletionsService.AUTOCOMPLETE_DIV_WHEEL_LISTENER,
      autocompleteListener
    );
    channelTextArea.append(autocompleteDiv);

    const autocompleteInnerDiv = document.createElement('div');
    this.htmlService.addClasses(
      autocompleteInnerDiv,
      discordClasses.Autocomplete.autocompleteInner
    );
    autocompleteDiv.append(autocompleteInnerDiv);

    const titleRow = document.createElement('div');
    this.htmlService.addClasses(
      titleRow,
      discordClasses.Autocomplete.autocompleteRowVertical
    );
    autocompleteInnerDiv.append(titleRow);

    const selector = document.createElement('div');
    this.htmlService.addClasses(selector, discordClasses.Autocomplete.base);
    titleRow.append(selector);

    const contentTitle = document.createElement('h3');
    this.htmlService.addClasses(
      contentTitle,
      discordClasses.Autocomplete.contentTitle,
      discordClasses.Wrapper.base,
      discordClasses.Size.size12
    );

    contentTitle.innerText = isEmote ? 'Emoji matching ' : 'Commands ';
    selector.append(contentTitle);

    const matchTextElement = document.createElement('strong');
    matchTextElement.textContent = matchText ?? '';
    contentTitle.append(matchTextElement);

    for (const [index, { name, data }] of matchList?.entries() ?? []) {
      const emoteRow = document.createElement('div');
      emoteRow.setAttribute('aria-disabled', 'false');

      this.htmlService.addClasses(
        emoteRow,
        discordClasses.Autocomplete.clickable,
        discordClasses.Autocomplete.autocompleteRowVertical,
        discordClasses.Autocomplete.autocompleteRowVerticalSmall
      );

      const mouseEnterListener = {
        element: emoteRow,
        name: 'mouseenter',
        callback: () => {
          if (!this.cached) this.cached = {};
          this.cached.selectedIndex = index + firstIndex;

          for (const child of titleRow.parentElement?.children ?? []) {
            child.setAttribute('aria-selected', 'false');

            for (const nestedChild of child.children) {
              this.htmlService.addClasses(
                nestedChild,
                discordClasses.Autocomplete.base
              );
            }
          }
        },
      };
      emoteRow.addEventListener(
        mouseEnterListener.name,
        mouseEnterListener.callback
      );
      this.listenersService.addListener(
        `${CompletionsService.EMOTE_ROW_MOUSEENTER_LISTENER}${index}`,
        mouseEnterListener
      );

      const mouseDownListener = {
        element: emoteRow,
        name: 'mousedown',
        callback: (evt) => {
          // Prevent loss of focus
          evt.preventDefault();

          if (!this.cached) this.cached = {};
          this.cached.selectedIndex = index + firstIndex;
          this.insertSelectedCompletion().catch((error) => Logger.error(error));
        },
      };
      emoteRow.addEventListener(
        mouseDownListener.name,
        mouseDownListener.callback
      );
      this.listenersService.addListener(
        `${CompletionsService.EMOTE_ROW_MOUSEDOWN_LISTENER}${index}`,
        mouseDownListener
      );
      autocompleteInnerDiv.append(emoteRow);

      const emoteSelector = document.createElement('div');
      this.htmlService.addClasses(
        emoteSelector,
        discordClasses.Autocomplete.base
      );
      emoteRow.append(emoteSelector);

      if (index + firstIndex === selectedIndex) {
        emoteRow.setAttribute('aria-selected', 'true');
      }

      const emoteContainer = document.createElement('div');
      this.htmlService.addClasses(
        emoteContainer,
        discordClasses.Autocomplete.autocompleteRowContent
      );
      emoteSelector.append(emoteContainer);

      if (isEmote) {
        const containerIcon = document.createElement('div');
        this.htmlService.addClasses(
          containerIcon,
          discordClasses.Autocomplete.autocompleteRowIcon
        );
        emoteContainer.append(containerIcon);

        const settingsAutocompleteEmoteSize =
          this.settingsService.settings.autocompleteEmoteSize;
        const containerImage = document.createElement('img');
        containerImage.alt = name;
        containerImage.title = name;
        containerImage.style.minWidth = `${Math.round(
          settingsAutocompleteEmoteSize
        )}px`;
        containerImage.style.minHeight = `${Math.round(
          settingsAutocompleteEmoteSize
        )}px`;
        containerImage.style.width = `${Math.round(
          settingsAutocompleteEmoteSize
        )}px`;
        containerImage.style.height = `${Math.round(
          settingsAutocompleteEmoteSize
        )}px`;

        this.htmlService.addClasses(
          containerImage,
          discordClasses.Autocomplete.emojiImage
        );
        containerIcon.append(containerImage);

        if (typeof data === 'string') {
          Utils.loadImagePromise(data, false, containerImage).catch((error) =>
            Logger.error(error)
          );
        }
      }

      const containerContent = document.createElement('div');
      containerContent.style.color = 'var(--interactive-active)';
      this.htmlService.addClasses(
        containerContent,
        discordClasses.Autocomplete.autocompleteRowContentPrimary
      );
      emoteContainer.append(containerContent);

      if (isEmote || typeof data === 'string') {
        containerContent.textContent = name;
      } else {
        containerContent.style.display = 'flex';
        containerContent.style.flexDirection = 'column';

        const containerContentName = document.createElement('span');
        containerContentName.style.paddingBottom = '0.5em';
        containerContentName.textContent = name;
        containerContent.append(containerContentName);

        const containerContentInfo = document.createElement('span');
        containerContentInfo.style.color = 'var(--interactive-normal)';
        containerContentInfo.textContent = data.info;
        containerContent.append(containerContentInfo);
      }
    }
  }

  renderCompletions = BdApi.Utils.debounce(
    this.doRenderCompletions.bind(this),
    250
  );

  scrollCompletions(e, options) {
    const delta = Math.sign(e.deltaY);
    this.scrollWindow(delta, options);
  }

  scrollWindow(delta, { locked = false, clamped = false } = {}) {
    if (!this.cached) return;

    const preScroll = 2;
    const {
      completions,
      selectedIndex: prevSelectedIndex,
      windowOffset,
    } = this.cached;
    const autocompleteItems = Math.round(
      this.settingsService.settings.autocompleteItems
    );

    if (!completions) {
      return;
    }

    // Change selected index
    const completionsCount = completions.length;
    let selectedIndex = (prevSelectedIndex ?? 0) + delta;
    if (clamped) {
      selectedIndex = Utils.clamp(selectedIndex, 0, completionsCount - 1);
    } else {
      selectedIndex =
        (selectedIndex % completionsCount) +
        (selectedIndex < 0 ? completionsCount : 0);
    }
    this.cached.selectedIndex = selectedIndex;

    const boundMax = Math.max(0, completionsCount - autocompleteItems);

    // Clamp window position to bounds based on new selected index
    const boundLower = Utils.clamp(
      selectedIndex + preScroll - (autocompleteItems - 1),
      0,
      boundMax
    );
    const boundUpper = Utils.clamp(selectedIndex - preScroll, 0, boundMax);

    this.cached.windowOffset = Utils.clamp(
      (windowOffset ?? 0) + (locked ? delta : 0),
      boundLower,
      boundUpper
    );

    // Render immediately
    this.doRenderCompletions();
  }

  stop() {
    this.draft = '';
    this.cached = undefined;
    this.curEditor = undefined;
  }
}

class EmoteService extends BaseService {
  listenersService;
  settingsService;
  htmlService;

  emoteNames;
  modifiers = EMOTE_MODIFIERS;

  start(listenersService, settingsService, htmlService) {
    this.listenersService = listenersService;
    this.settingsService = settingsService;
    this.htmlService = htmlService;
    this.initEmotes();

    return Promise.resolve();
  }

  initEmotes() {
    this.getEmoteNames()
      .then((emoteNames) => {
        this.setEmoteNames(emoteNames);

        if (this.htmlService.getEditors().length > 0) {
          this.listenersService.requestAddListeners(CompletionsService.TAG);
        }
      })
      .catch((error) => {
        Logger.warn('Failed to get emote names and/or modifiers', error);
      });
  }

  refreshEmotes() {
    this.emoteNames = undefined;
    BdApi.UI.showToast('Reloading emote database...', { type: 'info' });

    this.getEmoteNames()
      .then((names) => {
        this.setEmoteNames(names);
        BdApi.UI.showToast('Emote database reloaded!', { type: 'success' });
      })
      .catch((error) => {
        Logger.warn('Failed to get emote names', error);
      });
  }

  async getEmoteNames() {
    if (!this.settingsService.settings.showStandardEmotes) {
      return {};
    }

    const data = await Utils.urlGetBuffer(
      'https://raw.githubusercontent.com/Yentis/yentis.github.io/master/emotes/emotes.json'
    );
    const emoteNames = JSON.parse(new TextDecoder().decode(data));

    Object.keys(emoteNames).forEach((key) => {
      const split = emoteNames[key]?.split('.');
      const [name, extension] = split ?? [];

      delete emoteNames[key];
      if (name === undefined || extension === undefined) return;

      emoteNames[name] =
        'https://raw.githubusercontent.com/Yentis/yentis.github.io/master/emotes' +
        `/images/${key}.${extension}`;
    });

    return emoteNames;
  }

  setEmoteNames(emoteNames) {
    const customEmotes = {};

    Object.entries(this.settingsService.settings.customEmotes).forEach(
      ([name, url]) => {
        customEmotes[this.getPrefixedName(name)] = url;
      }
    );

    const standardNames = {};
    Object.entries(emoteNames).forEach(([name, url]) => {
      const prefixedName = this.getPrefixedName(name);
      standardNames[prefixedName] = url;
    });

    this.emoteNames = { ...standardNames, ...customEmotes };
  }

  getPrefixedName(name) {
    const settingsPrefix = this.settingsService.settings.prefix;
    if (name.toLowerCase().startsWith(settingsPrefix)) {
      name = name.replace(settingsPrefix, '');
    }

    return `${settingsPrefix}${name}`;
  }

  shouldCompleteEmote(input) {
    const prefix = this.settingsService.settings.requirePrefix
      ? this.escapeRegExp(this.settingsService.settings.prefix)
      : '';

    return new RegExp('(?:^|\\s)' + prefix + '\\w{2,}$').test(input);
  }

  shouldCompleteCommand(input) {
    return this.getRegexCommand().test(input);
  }

  escapeRegExp(input) {
    return input.replace(/[-\\/\\^$*+?.()|[\]{}]/g, '\\$&');
  }

  getRegexCommand() {
    const prefix = this.settingsService.settings.requirePrefix
      ? this.escapeRegExp(this.settingsService.settings.prefix)
      : '';

    return new RegExp('((?<!\\/)(?:' + prefix + '|<)[\\w:>]*\\.)([\\w\\.-]*)$');
  }

  getCompletionsEmote(text) {
    const settingsPrefix = this.settingsService.settings.prefix;
    const prefix = this.settingsService.settings.requirePrefix
      ? this.escapeRegExp(settingsPrefix)
      : '';

    const match = text.match(new RegExp('(^|\\s)(' + prefix + '\\w{2,})$'));
    if (match === null) {
      return { completions: [], matchText: undefined, matchStart: -1 };
    }

    const emoteArray = [];
    Object.entries(this.emoteNames ?? {}).forEach(([key, value]) => {
      emoteArray.push({ name: key, data: value });
    });

    const matchText = (match[2] ?? '').toLowerCase();
    const completions = emoteArray.filter((emote) => {
      const matchWithoutPrefix = matchText.startsWith(settingsPrefix)
        ? matchText.replace(settingsPrefix, '')
        : matchText;

      if (emote.name.toLowerCase().search(matchWithoutPrefix) !== -1) {
        return emote;
      } else {
        return false;
      }
    });

    const matchIndex = match.index ?? 0;
    const matchFirst = match[1] ?? '';
    const matchStart = matchIndex + matchFirst.length;

    return { completions, matchText, matchStart };
  }

  getCompletionsCommands(text) {
    const regex = this.getRegexCommand();
    const match = text.match(regex);
    if (match === null) {
      return { completions: [], matchText: undefined, matchStart: -1 };
    }

    const commandPart =
      match[2]?.substring(match[2].lastIndexOf('.') + 1) ?? '';
    const commandArray = [];

    this.modifiers.forEach((modifier) => {
      commandArray.push({ name: modifier.name, data: modifier });
    });

    const completions = commandArray.filter((command) => {
      return (
        commandPart === '' ||
        command.name.toLowerCase().search(commandPart) !== -1
      );
    });

    const matchText = commandPart;
    const matchIndex = match.index ?? 0;
    const matchZero = match[0] ?? '';
    const matchStart = matchIndex + matchZero.length;

    return { completions, matchText, matchStart };
  }

  stop() {
    this.emoteNames = undefined;
    this.modifiers = [];
  }
}

class AttachService extends BaseService {
  modulesService;

  canAttach = false;
  externalEmotes = new Set();
  userId;
  curChannelId;

  pendingUpload;
  pendingReply;

  onMessagesLoaded;
  onChannelSelect;

  async start(modulesService) {
    this.modulesService = modulesService;
    this.userId = await this.getUserId();
  }

  getUserId() {
    return new Promise((resolve) => {
      const getCurrentUser = this.modulesService.userStore.getCurrentUser;
      let user = getCurrentUser();

      if (user) {
        resolve(user.id);
        return;
      }

      // Not fully booted yet, wait for channel messages to load
      this.onMessagesLoaded = () => {
        user = getCurrentUser();
        const userId = user?.id ?? '';

        if (this.onMessagesLoaded) {
          this.modulesService.dispatcher.unsubscribe(
            'LOAD_MESSAGES_SUCCESS',
            this.onMessagesLoaded
          );
          this.onMessagesLoaded = undefined;
        }

        if (!userId) return;
        resolve(userId);
      };

      this.modulesService.dispatcher.subscribe(
        'LOAD_MESSAGES_SUCCESS',
        this.onMessagesLoaded
      );
    });
  }

  setCanAttach(_channelId) {
    if (_channelId !== undefined && _channelId === this.curChannelId) return;
    this.externalEmotes.clear();

    const channelId = _channelId ?? '';
    this.curChannelId = channelId;

    if (!channelId) {
      this.canAttach = true;
      return;
    }

    if (this.userId === undefined) {
      this.canAttach = true;
      return;
    }

    const channel = this.modulesService.channelStore.getChannel(channelId);
    if (!channel) {
      this.canAttach = true;
      return;
    }

    const guildId = channel.guild_id ?? '';
    if (!guildId) {
      this.canAttach = true;
      return;
    }

    const permissions = this.modulesService.discordPermissions;
    this.canAttach = this.modulesService.permissions.can(
      permissions.ATTACH_FILES,
      channel,
      this.userId
    );
  }

  stop() {
    if (this.onMessagesLoaded) {
      this.modulesService.dispatcher.unsubscribe(
        'LOAD_MESSAGES_SUCCESS',
        this.onMessagesLoaded
      );
      this.onMessagesLoaded = undefined;
    }

    if (this.onChannelSelect) {
      this.modulesService.dispatcher.unsubscribe(
        'CHANNEL_SELECT',
        this.onChannelSelect
      );
      this.onChannelSelect = undefined;
    }

    this.canAttach = false;
    this.pendingUpload = undefined;
  }
}

class SettingsService extends BaseService {
  static ADD_BUTTON_CLICK_LISTENER = 'addButtonClick';
  static REFRESH_BUTTON_CLICK_LISTENER = 'refreshButtonClick';
  static DELETE_BUTTON_CLICK_LISTENER = 'deleteButtonClick';

  listenersService;

  settings = DEFAULT_SETTINGS;

  start(listenersService) {
    this.listenersService = listenersService;

    const savedSettings = BdApi.Data.load(this.plugin.meta.name, SETTINGS_KEY);
    this.settings = Object.assign({}, DEFAULT_SETTINGS, savedSettings);

    return Promise.resolve();
  }

  getSettingsElement() {
    const emoteService = this.plugin.emoteService;
    if (!emoteService) return new HTMLElement();

    const Settings = this.zeresPluginLibrary.Settings;
    const settings = [];

    this.pushRegularSettings(settings, emoteService);

    const emoteFolderPicker = document.createElement('input');
    emoteFolderPicker.type = 'file';
    emoteFolderPicker.multiple = true;
    emoteFolderPicker.accept = '.png,.gif';

    let emoteName;
    const emoteNameTextbox = new Settings.Textbox(
      undefined,
      'Emote name',
      undefined,
      (val) => {
        emoteName = val;
      }
    );

    let imageUrl;
    const imageUrlTextbox = new Settings.Textbox(
      undefined,
      'Image URL (must end with .gif or .png, 128px recommended)',
      undefined,
      (val) => {
        imageUrl = val;
      }
    );

    const addButton = document.createElement('button');
    addButton.type = 'button';
    addButton.classList.add('bd-button');
    addButton.textContent = 'Add';
    const addSettingField = new Settings.SettingField(
      undefined,
      undefined,
      undefined,
      addButton
    );

    const customEmotesContainer = document.createElement('div');
    const addListener = {
      element: addButton,
      name: 'click',
      callback: () => {
        const files = emoteFolderPicker.files ?? [];

        const addPromises = (
          files.length > 0
            ? Array.from(files).map((file) => {
                const fileName = file.name.substring(
                  0,
                  file.name.lastIndexOf('.')
                );
                return this.addEmote(fileName, file.path);
              })
            : [this.addEmote(emoteName, imageUrl)]
        ).map(async (promise) => {
          const emoteName = await promise;
          customEmotesContainer.append(
            this.createCustomEmoteContainer(emoteName, emoteService)
          );
        });

        Promise.allSettled(addPromises)
          .then((results) => {
            const errors = [];
            results.forEach((result) => {
              if (result.status === 'fulfilled') return;
              errors.push(result.reason);
              Logger.error(result.reason);
            });

            const firstError = errors[0];
            if (firstError) {
              BdApi.UI.showToast(
                `${firstError.message}${
                  errors.length > 1 ? '\nSee console for all errors' : ''
                }`,
                { type: 'error' }
              );

              if (addPromises.length === 1) return;
            }

            emoteFolderPicker.value = '';
            const emoteNameTextboxInput = emoteNameTextbox
              .getElement()
              .querySelector('input');
            if (emoteNameTextboxInput) emoteNameTextboxInput.value = '';

            const imageUrlTextboxInput = imageUrlTextbox
              .getElement()
              .querySelector('input');
            if (imageUrlTextboxInput) imageUrlTextboxInput.value = '';

            BdApi.Data.save(this.plugin.meta.name, SETTINGS_KEY, this.settings);
            BdApi.UI.showToast('Emote(s) have been saved', { type: 'success' });
          })
          .catch((error) => {
            BdApi.UI.showToast(error.message, { type: 'error' });
          });
      },
    };
    addButton.addEventListener(addListener.name, addListener.callback);
    this.listenersService.addListener(
      SettingsService.ADD_BUTTON_CLICK_LISTENER,
      addListener
    );

    Object.keys(this.settings.customEmotes).forEach((key) => {
      customEmotesContainer.append(
        this.createCustomEmoteContainer(key, emoteService)
      );
    });

    const customEmoteGroup = new Settings.SettingGroup('Custom emotes');
    customEmoteGroup.append(
      emoteFolderPicker,
      emoteNameTextbox,
      imageUrlTextbox,
      addSettingField,
      customEmotesContainer
    );
    settings.push(customEmoteGroup);

    const refreshButton = document.createElement('button');
    refreshButton.type = 'button';
    refreshButton.classList.add('bd-button');
    refreshButton.textContent = 'Refresh emote list';
    const refreshSettingField = new Settings.SettingField(
      undefined,
      undefined,
      undefined,
      refreshButton
    );

    const refreshListener = {
      element: refreshButton,
      name: 'click',
      callback: () => {
        emoteService.refreshEmotes();
      },
    };
    refreshButton.addEventListener(
      refreshListener.name,
      refreshListener.callback
    );
    this.listenersService.addListener(
      SettingsService.REFRESH_BUTTON_CLICK_LISTENER,
      refreshListener
    );
    settings.push(refreshSettingField);

    return Settings.SettingPanel.build(() => {
      BdApi.Data.save(this.plugin.meta.name, SETTINGS_KEY, this.settings);
    }, ...settings);
  }

  async addEmote(emoteName, imageUrl) {
    if (!emoteName) throw new Error('No emote name entered!');
    if (!imageUrl) throw new Error('No image URL entered!');

    if (!imageUrl.endsWith('.gif') && !imageUrl.endsWith('.png')) {
      throw new Error('Image URL must end with .gif or .png!');
    }

    const emoteService = this.plugin.emoteService;
    if (!emoteService) throw new Error('Emote service not found');

    const emoteNames = emoteService.emoteNames ?? {};
    const targetEmoteName =
      emoteNames[emoteService.getPrefixedName(emoteName)] ?? '';
    if (targetEmoteName) throw new Error('Emote name already exists!');

    this.settings.customEmotes[emoteName] = imageUrl;
    emoteNames[emoteService.getPrefixedName(emoteName)] = imageUrl;

    emoteService.emoteNames = emoteNames;
    return await Promise.resolve(emoteName);
  }

  pushRegularSettings(settings, emoteService) {
    const Settings = this.zeresPluginLibrary.Settings;

    settings.push(
      new Settings.Slider(
        'Emote Size',
        'The size of emotes. (default 48)',
        32,
        128,
        this.settings.emoteSize,
        (val) => {
          this.settings.emoteSize = Math.round(val);
        },
        { units: 'px', markers: [32, 48, 64, 96, 128] }
      )
    );

    settings.push(
      new Settings.Slider(
        'Autocomplete Emote Size',
        'The size of emotes in the autocomplete window. (default 15)',
        15,
        64,
        this.settings.autocompleteEmoteSize,
        (val) => {
          this.settings.autocompleteEmoteSize = Math.round(val);
        },
        { units: 'px', markers: [15, 32, 48, 64] }
      )
    );

    settings.push(
      new Settings.Slider(
        'Autocomplete Items',
        'The amount of emotes shown in the autocomplete window. (default 10)',
        1,
        25,
        this.settings.autocompleteItems,
        (val) => {
          this.settings.autocompleteItems = Math.round(val);
        },
        { units: ' items', markers: [1, 5, 10, 15, 20, 25] }
      )
    );

    settings.push(
      new Settings.Switch(
        'Require prefix',
        'If this is enabled, ' +
          'the autocomplete list will not be shown unless the prefix is also typed.',
        this.settings.requirePrefix,
        (checked) => {
          this.settings.requirePrefix = checked;
        }
      )
    );

    settings.push(
      new Settings.Switch(
        'Show standard custom emotes',
        'If this is enabled, the standard custom emotes will be visible.',
        this.settings.showStandardEmotes,
        (checked) => {
          this.settings.showStandardEmotes = checked;
          emoteService.refreshEmotes();
        }
      )
    );

    settings.push(
      new Settings.Textbox(
        'Prefix',
        'The prefix to check against for the above setting. ' +
          'It is recommended to use a single character not in use by other chat functionality, ' +
          'other prefixes may cause issues.',
        this.settings.prefix,
        BdApi.Utils.debounce((val) => {
          if (val === this.settings.prefix) return;

          const previousPrefix = this.settings.prefix;
          this.settings.prefix = val;
          BdApi.Data.save(this.plugin.meta.name, SETTINGS_KEY, this.settings);

          const previousEmoteNames = Object.assign({}, emoteService.emoteNames);
          const emoteNames = {};

          Object.entries(previousEmoteNames).forEach(([name, value]) => {
            const prefixedName = emoteService.getPrefixedName(
              name.replace(previousPrefix, '')
            );
            emoteNames[prefixedName] = value;
          });

          emoteService.emoteNames = emoteNames;
        }, 2000)
      )
    );

    settings.push(
      new Settings.RadioGroup(
        'Resize Method',
        'How emotes will be scaled down to fit your selected emote size',
        this.settings.resizeMethod,
        [
          {
            name: 'Scale down smallest side',
            value: 'smallest',
          },
          {
            name: 'Scale down largest side',
            value: 'largest',
          },
        ],
        (val) => {
          this.settings.resizeMethod = val;
        }
      )
    );
  }

  createCustomEmoteContainer(emoteName, emoteService) {
    const Settings = this.zeresPluginLibrary.Settings;

    const customEmoteContainer = document.createElement('div');
    customEmoteContainer.style.display = 'flex';

    const url = this.settings.customEmotes[emoteName] ?? '';
    const containerImage = document.createElement('img');
    containerImage.alt = emoteName;
    containerImage.title = emoteName;
    containerImage.style.minWidth = `${Math.round(
      this.settings.autocompleteEmoteSize
    )}px`;
    containerImage.style.minHeight = `${Math.round(
      this.settings.autocompleteEmoteSize
    )}px`;
    containerImage.style.width = `${Math.round(
      this.settings.autocompleteEmoteSize
    )}px`;
    containerImage.style.height = `${Math.round(
      this.settings.autocompleteEmoteSize
    )}px`;
    containerImage.style.marginRight = '0.5rem';

    customEmoteContainer.append(containerImage);
    Utils.loadImagePromise(url, false, containerImage).catch((error) =>
      Logger.error(error)
    );

    const deleteButton = document.createElement('button');
    deleteButton.type = 'button';
    deleteButton.classList.add('bd-button', 'bd-button-danger');
    deleteButton.innerHTML =
      '<svg class="" fill="#FFFFFF" viewBox="0 0 24 24" ' +
      'style="width: 20px; height: 20px;"><path fill="none" d="M0 0h24v24H0V0z"></path>' +
      '<path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zm2.46-7.12l1.41-1.41L12 12.59l2.12-2.' +
      '12 1.41 1.41L13.41 14l2.12 2.12-1.41 1.41L12 15.41l-2.12 2.12-1.41-1.41L10.59 14l-2.13-2.1' +
      '2zM15.5 4l-1-1h-5l-1 1H5v2h14V4z"></path><path fill="none" d="M0 0h24v24H0z"></path></svg>';
    customEmoteContainer.append(deleteButton);

    const deleteListener = {
      element: deleteButton,
      name: 'click',
      callback: () => {
        delete this.settings.customEmotes[emoteName];
        if (emoteService.emoteNames) {
          delete emoteService.emoteNames[
            emoteService.getPrefixedName(emoteName)
          ];
        }

        BdApi.Data.save(this.plugin.meta.name, SETTINGS_KEY, this.settings);
        BdApi.UI.showToast(`Emote ${emoteName} has been deleted!`, {
          type: 'success',
        });

        document.getElementById(emoteName)?.remove();
      },
    };
    deleteButton.addEventListener(deleteListener.name, deleteListener.callback);
    this.listenersService.addListener(
      `${SettingsService.DELETE_BUTTON_CLICK_LISTENER}${emoteName}`,
      deleteListener
    );

    const targetEmote = this.settings.customEmotes[emoteName];
    const existingEmote = new Settings.SettingField(
      emoteName,
      targetEmote,
      undefined,
      customEmoteContainer,
      { noteOnTop: true }
    );

    existingEmote.getElement().id = emoteName;
    return existingEmote.getElement();
  }

  stop() {
    // Do nothing
  }
}

class ListenersService extends BaseService {
  listeners = {};

  addListenersWatchers = {};

  start() {
    return Promise.resolve();
  }

  addListener(id, listener) {
    if (this.listeners[id]) this.removeListener(id);
    this.listeners[id] = listener;
  }

  removeListeners(idPrefix) {
    const listeners = Object.keys(this.listeners).filter((id) =>
      id.startsWith(idPrefix)
    );
    if (listeners.length === 0) return;

    listeners.forEach((id) => {
      this.removeListener(id);
    });
  }

  removeListener(id) {
    const listener = this.listeners[id];
    if (!listener) return;
    const { element, name, callback } = listener;

    if (element) {
      element.removeEventListener(name, callback);
    }

    delete this.listeners[id];
  }

  requestAddListeners(targetId) {
    Object.entries(this.addListenersWatchers).forEach(
      ([id, addListenersWatcher]) => {
        if (id !== targetId) return;
        addListenersWatcher.onAddListeners();
      }
    );
  }

  stop() {
    Object.keys(this.listeners).forEach((id) => {
      this.removeListener(id);
    });
  }
}

function funcToSource(fn, sourcemapArg) {
  var sourcemap = sourcemapArg === undefined ? null : sourcemapArg;
  var source = fn.toString();
  var lines = source.split('\n');
  lines.pop();
  lines.shift();
  var blankPrefixLength = lines[0].search(/\S/);
  var regex = /(['"])__worker_loader_strict__(['"])/g;
  for (var i = 0, n = lines.length; i < n; ++i) {
    lines[i] =
      lines[i].substring(blankPrefixLength).replace(regex, '$1use strict$2') +
      '\n';
  }
  if (sourcemap) {
    lines.push('//# sourceMappingURL=' + sourcemap + '\n');
  }
  return lines;
}

function createURL(fn, sourcemapArg) {
  var lines = funcToSource(fn, sourcemapArg);
  var blob = new Blob(lines, { type: 'application/javascript' });
  return URL.createObjectURL(blob);
}

function createInlineWorkerFactory(fn, sourcemapArg) {
  var url;
  return function WorkerFactory(options) {
    url = url || createURL(fn, sourcemapArg);
    return new Worker(url, options);
  };
}

var WorkerFactory = createInlineWorkerFactory(
  /* rollup-plugin-web-worker-loader */ function () {
    (function () {
      '__worker_loader_strict__';

      var WorkerMessageType;
      (function (WorkerMessageType) {
        const INIT = 0;
        WorkerMessageType[(WorkerMessageType['INIT'] = INIT)] = 'INIT';
        const APPLY_COMMANDS = INIT + 1;
        WorkerMessageType[
          (WorkerMessageType['APPLY_COMMANDS'] = APPLY_COMMANDS)
        ] = 'APPLY_COMMANDS';
      })(WorkerMessageType || (WorkerMessageType = {}));

      let wasm;

      const heap = new Array(128).fill(undefined);

      heap.push(undefined, null, true, false);

      function getObject(idx) {
        return heap[idx];
      }

      let heap_next = heap.length;

      function dropObject(idx) {
        if (idx < 132) return;
        heap[idx] = heap_next;
        heap_next = idx;
      }

      function takeObject(idx) {
        const ret = getObject(idx);
        dropObject(idx);
        return ret;
      }

      const cachedTextDecoder = new TextDecoder('utf-8', {
        ignoreBOM: true,
        fatal: true,
      });

      cachedTextDecoder.decode();

      let cachedUint8Memory0 = null;

      function getUint8Memory0() {
        if (
          cachedUint8Memory0 === null ||
          cachedUint8Memory0.byteLength === 0
        ) {
          cachedUint8Memory0 = new Uint8Array(wasm.memory.buffer);
        }
        return cachedUint8Memory0;
      }

      function getStringFromWasm0(ptr, len) {
        return cachedTextDecoder.decode(
          getUint8Memory0().subarray(ptr, ptr + len)
        );
      }

      function addHeapObject(obj) {
        if (heap_next === heap.length) heap.push(heap.length + 1);
        const idx = heap_next;
        heap_next = heap[idx];

        heap[idx] = obj;
        return idx;
      }

      let WASM_VECTOR_LEN = 0;

      const cachedTextEncoder = new TextEncoder('utf-8');

      const encodeString =
        typeof cachedTextEncoder.encodeInto === 'function'
          ? function (arg, view) {
              return cachedTextEncoder.encodeInto(arg, view);
            }
          : function (arg, view) {
              const buf = cachedTextEncoder.encode(arg);
              view.set(buf);
              return {
                read: arg.length,
                written: buf.length,
              };
            };

      function passStringToWasm0(arg, malloc, realloc) {
        if (realloc === undefined) {
          const buf = cachedTextEncoder.encode(arg);
          const ptr = malloc(buf.length);
          getUint8Memory0()
            .subarray(ptr, ptr + buf.length)
            .set(buf);
          WASM_VECTOR_LEN = buf.length;
          return ptr;
        }

        let len = arg.length;
        let ptr = malloc(len);

        const mem = getUint8Memory0();

        let offset = 0;

        for (; offset < len; offset++) {
          const code = arg.charCodeAt(offset);
          if (code > 0x7f) break;
          mem[ptr + offset] = code;
        }

        if (offset !== len) {
          if (offset !== 0) {
            arg = arg.slice(offset);
          }
          ptr = realloc(ptr, len, (len = offset + arg.length * 3));
          const view = getUint8Memory0().subarray(ptr + offset, ptr + len);
          const ret = encodeString(arg, view);

          offset += ret.written;
        }

        WASM_VECTOR_LEN = offset;
        return ptr;
      }

      function isLikeNone(x) {
        return x === undefined || x === null;
      }

      let cachedInt32Memory0 = null;

      function getInt32Memory0() {
        if (
          cachedInt32Memory0 === null ||
          cachedInt32Memory0.byteLength === 0
        ) {
          cachedInt32Memory0 = new Int32Array(wasm.memory.buffer);
        }
        return cachedInt32Memory0;
      }

      let cachedFloat64Memory0 = null;

      function getFloat64Memory0() {
        if (
          cachedFloat64Memory0 === null ||
          cachedFloat64Memory0.byteLength === 0
        ) {
          cachedFloat64Memory0 = new Float64Array(wasm.memory.buffer);
        }
        return cachedFloat64Memory0;
      }

      function debugString(val) {
        // primitive types
        const type = typeof val;
        if (type == 'number' || type == 'boolean' || val == null) {
          return `${val}`;
        }
        if (type == 'string') {
          return `"${val}"`;
        }
        if (type == 'symbol') {
          const description = val.description;
          if (description == null) {
            return 'Symbol';
          } else {
            return `Symbol(${description})`;
          }
        }
        if (type == 'function') {
          const name = val.name;
          if (typeof name == 'string' && name.length > 0) {
            return `Function(${name})`;
          } else {
            return 'Function';
          }
        }
        // objects
        if (Array.isArray(val)) {
          const length = val.length;
          let debug = '[';
          if (length > 0) {
            debug += debugString(val[0]);
          }
          for (let i = 1; i < length; i++) {
            debug += ', ' + debugString(val[i]);
          }
          debug += ']';
          return debug;
        }
        // Test for built-in
        const builtInMatches = /\[object ([^\]]+)\]/.exec(toString.call(val));
        let className;
        if (builtInMatches.length > 1) {
          className = builtInMatches[1];
        } else {
          // Failed to match the standard '[object ClassName]'
          return toString.call(val);
        }
        if (className == 'Object') {
          // we're a user defined class or Object
          // JSON.stringify avoids problems with cycles, and is generally much
          // easier than looping through ownProperties of `val`.
          try {
            return 'Object(' + JSON.stringify(val) + ')';
          } catch (_) {
            return 'Object';
          }
        }
        // errors
        if (val instanceof Error) {
          return `${val.name}: ${val.message}\n${val.stack}`;
        }
        // TODO we could test for more things here, like `Set`s and `Map`s.
        return className;
      }
      /**
       */
      function initPanicHook() {
        wasm.initPanicHook();
      }

      function passArray8ToWasm0(arg, malloc) {
        const ptr = malloc(arg.length * 1);
        getUint8Memory0().set(arg, ptr / 1);
        WASM_VECTOR_LEN = arg.length;
        return ptr;
      }

      function getArrayU8FromWasm0(ptr, len) {
        return getUint8Memory0().subarray(ptr / 1, ptr / 1 + len);
      }
      /**
       * @param {Uint8Array} data
       * @param {string} format_type
       * @param {any} commands
       * @returns {Uint8Array}
       */
      function applyCommands(data, format_type, commands) {
        try {
          const retptr = wasm.__wbindgen_add_to_stack_pointer(-16);
          const ptr0 = passArray8ToWasm0(data, wasm.__wbindgen_malloc);
          const len0 = WASM_VECTOR_LEN;
          const ptr1 = passStringToWasm0(
            format_type,
            wasm.__wbindgen_malloc,
            wasm.__wbindgen_realloc
          );
          const len1 = WASM_VECTOR_LEN;
          wasm.applyCommands(
            retptr,
            ptr0,
            len0,
            ptr1,
            len1,
            addHeapObject(commands)
          );
          var r0 = getInt32Memory0()[retptr / 4 + 0];
          var r1 = getInt32Memory0()[retptr / 4 + 1];
          var r2 = getInt32Memory0()[retptr / 4 + 2];
          var r3 = getInt32Memory0()[retptr / 4 + 3];
          if (r3) {
            throw takeObject(r2);
          }
          var v2 = getArrayU8FromWasm0(r0, r1).slice();
          wasm.__wbindgen_free(r0, r1 * 1);
          return v2;
        } finally {
          wasm.__wbindgen_add_to_stack_pointer(16);
        }
      }

      function handleError(f, args) {
        try {
          return f.apply(this, args);
        } catch (e) {
          wasm.__wbindgen_exn_store(addHeapObject(e));
        }
      }

      function notDefined(what) {
        return () => {
          throw new Error(`${what} is not defined`);
        };
      }

      async function load(module, imports) {
        if (typeof Response === 'function' && module instanceof Response) {
          if (typeof WebAssembly.instantiateStreaming === 'function') {
            try {
              return await WebAssembly.instantiateStreaming(module, imports);
            } catch (e) {
              if (module.headers.get('Content-Type') != 'application/wasm') {
                console.warn(
                  '`WebAssembly.instantiateStreaming` failed because your server does not serve wasm with `application/wasm` MIME type. Falling back to `WebAssembly.instantiate` which is slower. Original error:\n',
                  e
                );
              } else {
                throw e;
              }
            }
          }

          const bytes = await module.arrayBuffer();
          return await WebAssembly.instantiate(bytes, imports);
        } else {
          const instance = await WebAssembly.instantiate(module, imports);

          if (instance instanceof WebAssembly.Instance) {
            return { instance, module };
          } else {
            return instance;
          }
        }
      }

      function getImports() {
        const imports = {};
        imports.wbg = {};
        imports.wbg.__wbindgen_object_drop_ref = function (arg0) {
          takeObject(arg0);
        };
        imports.wbg.__wbindgen_error_new = function (arg0, arg1) {
          const ret = new Error(getStringFromWasm0(arg0, arg1));
          return addHeapObject(ret);
        };
        imports.wbg.__wbindgen_string_get = function (arg0, arg1) {
          const obj = getObject(arg1);
          const ret = typeof obj === 'string' ? obj : undefined;
          var ptr0 = isLikeNone(ret)
            ? 0
            : passStringToWasm0(
                ret,
                wasm.__wbindgen_malloc,
                wasm.__wbindgen_realloc
              );
          var len0 = WASM_VECTOR_LEN;
          getInt32Memory0()[arg0 / 4 + 1] = len0;
          getInt32Memory0()[arg0 / 4 + 0] = ptr0;
        };
        imports.wbg.__wbindgen_is_object = function (arg0) {
          const val = getObject(arg0);
          const ret = typeof val === 'object' && val !== null;
          return ret;
        };
        imports.wbg.__wbindgen_jsval_loose_eq = function (arg0, arg1) {
          const ret = getObject(arg0) == getObject(arg1);
          return ret;
        };
        imports.wbg.__wbindgen_boolean_get = function (arg0) {
          const v = getObject(arg0);
          const ret = typeof v === 'boolean' ? (v ? 1 : 0) : 2;
          return ret;
        };
        imports.wbg.__wbindgen_number_get = function (arg0, arg1) {
          const obj = getObject(arg1);
          const ret = typeof obj === 'number' ? obj : undefined;
          getFloat64Memory0()[arg0 / 8 + 1] = isLikeNone(ret) ? 0 : ret;
          getInt32Memory0()[arg0 / 4 + 0] = !isLikeNone(ret);
        };
        imports.wbg.__wbg_String_88810dfeb4021902 = function (arg0, arg1) {
          const ret = String(getObject(arg1));
          const ptr0 = passStringToWasm0(
            ret,
            wasm.__wbindgen_malloc,
            wasm.__wbindgen_realloc
          );
          const len0 = WASM_VECTOR_LEN;
          getInt32Memory0()[arg0 / 4 + 1] = len0;
          getInt32Memory0()[arg0 / 4 + 0] = ptr0;
        };
        imports.wbg.__wbg_get_27fe3dac1c4d0224 = function (arg0, arg1) {
          const ret = getObject(arg0)[arg1 >>> 0];
          return addHeapObject(ret);
        };
        imports.wbg.__wbg_length_e498fbc24f9c1d4f = function (arg0) {
          const ret = getObject(arg0).length;
          return ret;
        };
        imports.wbg.__wbindgen_is_function = function (arg0) {
          const ret = typeof getObject(arg0) === 'function';
          return ret;
        };
        imports.wbg.__wbg_next_b7d530c04fd8b217 = function (arg0) {
          const ret = getObject(arg0).next;
          return addHeapObject(ret);
        };
        imports.wbg.__wbg_next_88560ec06a094dea = function () {
          return handleError(function (arg0) {
            const ret = getObject(arg0).next();
            return addHeapObject(ret);
          }, arguments);
        };
        imports.wbg.__wbg_done_1ebec03bbd919843 = function (arg0) {
          const ret = getObject(arg0).done;
          return ret;
        };
        imports.wbg.__wbg_value_6ac8da5cc5b3efda = function (arg0) {
          const ret = getObject(arg0).value;
          return addHeapObject(ret);
        };
        imports.wbg.__wbg_iterator_55f114446221aa5a = function () {
          const ret = Symbol.iterator;
          return addHeapObject(ret);
        };
        imports.wbg.__wbg_get_baf4855f9a986186 = function () {
          return handleError(function (arg0, arg1) {
            const ret = Reflect.get(getObject(arg0), getObject(arg1));
            return addHeapObject(ret);
          }, arguments);
        };
        imports.wbg.__wbg_call_95d1ea488d03e4e8 = function () {
          return handleError(function (arg0, arg1) {
            const ret = getObject(arg0).call(getObject(arg1));
            return addHeapObject(ret);
          }, arguments);
        };
        imports.wbg.__wbg_parseFloat_cb5f4687ae0be33e = function (arg0, arg1) {
          const ret = parseFloat(getStringFromWasm0(arg0, arg1));
          return ret;
        };
        imports.wbg.__wbg_isArray_39d28997bf6b96b4 = function (arg0) {
          const ret = Array.isArray(getObject(arg0));
          return ret;
        };
        imports.wbg.__wbg_instanceof_ArrayBuffer_a69f02ee4c4f5065 = function (
          arg0
        ) {
          let result;
          try {
            result = getObject(arg0) instanceof ArrayBuffer;
          } catch {
            result = false;
          }
          const ret = result;
          return ret;
        };
        imports.wbg.__wbg_entries_4e1315b774245952 = function (arg0) {
          const ret = Object.entries(getObject(arg0));
          return addHeapObject(ret);
        };
        imports.wbg.__wbg_buffer_cf65c07de34b9a08 = function (arg0) {
          const ret = getObject(arg0).buffer;
          return addHeapObject(ret);
        };
        imports.wbg.__wbg_new_537b7341ce90bb31 = function (arg0) {
          const ret = new Uint8Array(getObject(arg0));
          return addHeapObject(ret);
        };
        imports.wbg.__wbg_set_17499e8aa4003ebd = function (arg0, arg1, arg2) {
          getObject(arg0).set(getObject(arg1), arg2 >>> 0);
        };
        imports.wbg.__wbg_length_27a2afe8ab42b09f = function (arg0) {
          const ret = getObject(arg0).length;
          return ret;
        };
        imports.wbg.__wbg_instanceof_Uint8Array_01cebe79ca606cca = function (
          arg0
        ) {
          let result;
          try {
            result = getObject(arg0) instanceof Uint8Array;
          } catch {
            result = false;
          }
          const ret = result;
          return ret;
        };
        imports.wbg.__wbg_random_afb3265527cf67c8 =
          typeof Math.random == 'function'
            ? Math.random
            : notDefined('Math.random');
        imports.wbg.__wbg_new_abda76e883ba8a5f = function () {
          const ret = new Error();
          return addHeapObject(ret);
        };
        imports.wbg.__wbg_stack_658279fe44541cf6 = function (arg0, arg1) {
          const ret = getObject(arg1).stack;
          const ptr0 = passStringToWasm0(
            ret,
            wasm.__wbindgen_malloc,
            wasm.__wbindgen_realloc
          );
          const len0 = WASM_VECTOR_LEN;
          getInt32Memory0()[arg0 / 4 + 1] = len0;
          getInt32Memory0()[arg0 / 4 + 0] = ptr0;
        };
        imports.wbg.__wbg_error_f851667af71bcfc6 = function (arg0, arg1) {
          try {
            console.error(getStringFromWasm0(arg0, arg1));
          } finally {
            wasm.__wbindgen_free(arg0, arg1);
          }
        };
        imports.wbg.__wbindgen_debug_string = function (arg0, arg1) {
          const ret = debugString(getObject(arg1));
          const ptr0 = passStringToWasm0(
            ret,
            wasm.__wbindgen_malloc,
            wasm.__wbindgen_realloc
          );
          const len0 = WASM_VECTOR_LEN;
          getInt32Memory0()[arg0 / 4 + 1] = len0;
          getInt32Memory0()[arg0 / 4 + 0] = ptr0;
        };
        imports.wbg.__wbindgen_throw = function (arg0, arg1) {
          throw new Error(getStringFromWasm0(arg0, arg1));
        };
        imports.wbg.__wbindgen_memory = function () {
          const ret = wasm.memory;
          return addHeapObject(ret);
        };

        return imports;
      }

      function finalizeInit(instance, module) {
        wasm = instance.exports;
        init.__wbindgen_wasm_module = module;
        cachedFloat64Memory0 = null;
        cachedInt32Memory0 = null;
        cachedUint8Memory0 = null;

        return wasm;
      }

      async function init(input) {
        if (typeof input === 'undefined') {
          input = new URL(
            'gif_wasm_bg.wasm',
            (document.currentScript && document.currentScript.src) ||
              new URL('worker.js', document.baseURI).href
          );
        }
        const imports = getImports();

        if (
          typeof input === 'string' ||
          (typeof Request === 'function' && input instanceof Request) ||
          (typeof URL === 'function' && input instanceof URL)
        ) {
          input = fetch(input);
        }

        const { instance, module } = await load(await input, imports);

        return finalizeInit(instance, module);
      }

      function _loadWasmModule(sync, filepath, src, imports) {
        function _instantiateOrCompile(source, imports, stream) {
          var instantiateFunc = stream
            ? WebAssembly.instantiateStreaming
            : WebAssembly.instantiate;
          var compileFunc = stream
            ? WebAssembly.compileStreaming
            : WebAssembly.compile;

          if (imports) {
            return instantiateFunc(source, imports);
          } else {
            return compileFunc(source);
          }
        }

        var buf = null;
        var isNode =
          typeof process !== 'undefined' &&
          process.versions != null &&
          process.versions.node != null;
        if (isNode) {
          buf = Buffer.from(src, 'base64');
        } else {
          var raw = globalThis.atob(src);
          var rawLength = raw.length;
          buf = new Uint8Array(new ArrayBuffer(rawLength));
          for (var i = 0; i < rawLength; i++) {
            buf[i] = raw.charCodeAt(i);
          }
        }

        if (sync) {
          var mod = new WebAssembly.Module(buf);
          return imports ? new WebAssembly.Instance(mod, imports) : mod;
        } else {
          return _instantiateOrCompile(buf, imports, false);
        }
      }

      function gifWasm(imports) {
        return _loadWasmModule(
          0,
          null,
          'AGFzbQEAAAABuAIqYAJ/fwF/YAJ/fwBgA39/fwF/YAF/AGABfwF/YAN/f38AYAR/f39/AGAGf39/f39/AGABfwF+YAV/f39/fwBgAAF/YAJ/fQF9YAV/f39/fwF/YAN/f30AYAAAYAJ9fQF9YAJ/fwF8YAF9AX1gBn9/f39/fwF/YAN/fX8AYAd/f39/f39/AX9gA399fQBgBH9/f38Bf2AAAXxgCH9/f39/f39/AGACf30AYAR/f35+AGAHf39/f39/fwBgCX9/f39/f35+fgBgAn9/AX5gA35/fwF/YAR/f319AGATf39/f39/f39/f39/f39/f39/fwF/YAt/f39/f39/f39/fwF/YAN/fn4AYAV/f31/fwBgBH99f38AYAV/f35/fwBgBH9+f38AYAV/f3x/fwBgBH98f38AYAF8AXwCgAkiA3diZxpfX3diaW5kZ2VuX29iamVjdF9kcm9wX3JlZgADA3diZxRfX3diaW5kZ2VuX2Vycm9yX25ldwAAA3diZxVfX3diaW5kZ2VuX3N0cmluZ19nZXQAAQN3YmcUX193YmluZGdlbl9pc19vYmplY3QABAN3YmcZX193YmluZGdlbl9qc3ZhbF9sb29zZV9lcQAAA3diZxZfX3diaW5kZ2VuX2Jvb2xlYW5fZ2V0AAQDd2JnFV9fd2JpbmRnZW5fbnVtYmVyX2dldAABA3diZx1fX3diZ19TdHJpbmdfODg4MTBkZmViNDAyMTkwMgABA3diZxpfX3diZ19nZXRfMjdmZTNkYWMxYzRkMDIyNAAAA3diZx1fX3diZ19sZW5ndGhfZTQ5OGZiYzI0ZjljMWQ0ZgAEA3diZxZfX3diaW5kZ2VuX2lzX2Z1bmN0aW9uAAQDd2JnG19fd2JnX25leHRfYjdkNTMwYzA0ZmQ4YjIxNwAEA3diZxtfX3diZ19uZXh0Xzg4NTYwZWMwNmEwOTRkZWEABAN3YmcbX193YmdfZG9uZV8xZWJlYzAzYmJkOTE5ODQzAAQDd2JnHF9fd2JnX3ZhbHVlXzZhYzhkYTVjYzViM2VmZGEABAN3YmcfX193YmdfaXRlcmF0b3JfNTVmMTE0NDQ2MjIxYWE1YQAKA3diZxpfX3diZ19nZXRfYmFmNDg1NWY5YTk4NjE4NgAAA3diZxtfX3diZ19jYWxsXzk1ZDFlYTQ4OGQwM2U0ZTgAAAN3YmchX193YmdfcGFyc2VGbG9hdF9jYjVmNDY4N2FlMGJlMzNlABADd2JnHl9fd2JnX2lzQXJyYXlfMzlkMjg5OTdiZjZiOTZiNAAEA3diZy1fX3diZ19pbnN0YW5jZW9mX0FycmF5QnVmZmVyX2E2OWYwMmVlNGM0ZjUwNjUABAN3YmceX193YmdfZW50cmllc180ZTEzMTViNzc0MjQ1OTUyAAQDd2JnHV9fd2JnX2J1ZmZlcl9jZjY1YzA3ZGUzNGI5YTA4AAQDd2JnGl9fd2JnX25ld181MzdiNzM0MWNlOTBiYjMxAAQDd2JnGl9fd2JnX3NldF8xNzQ5OWU4YWE0MDAzZWJkAAUDd2JnHV9fd2JnX2xlbmd0aF8yN2EyYWZlOGFiNDJiMDlmAAQDd2JnLF9fd2JnX2luc3RhbmNlb2ZfVWludDhBcnJheV8wMWNlYmU3OWNhNjA2Y2NhAAQDd2JnHV9fd2JnX3JhbmRvbV9hZmIzMjY1NTI3Y2Y2N2M4ABcDd2JnGl9fd2JnX25ld19hYmRhNzZlODgzYmE4YTVmAAoDd2JnHF9fd2JnX3N0YWNrXzY1ODI3OWZlNDQ1NDFjZjYAAQN3YmccX193YmdfZXJyb3JfZjg1MTY2N2FmNzFiY2ZjNgABA3diZxdfX3diaW5kZ2VuX2RlYnVnX3N0cmluZwABA3diZxBfX3diaW5kZ2VuX3Rocm93AAEDd2JnEV9fd2JpbmRnZW5fbWVtb3J5AAoD1QPTAwkYBwcNAgYHAQQBBgcFAAcBBgEFBgEBABkAEQMABQUJGgICBQUBARIFBwkGAxMEAgUCBgEAAwUBAQEBAQMBDAEBEwECAwIBAAEBGwAcAAAHABQEDQIADAAAAAAAAB0eBQMGAAYDAwAfAgEBBQEACgABAwMBBQEGAAABAAcEBQUFAAABBQEBAQEBAQUFAQEFBQAgAAkMBgwBIQYDBBQBAAcAAAAAAAEDFQABBAMBAQAJACICBQUBBQAKFQAAAQEEAQoAAwAJAAAAAAABAAAAAAAAAAAAAAAABAMNAwAAAwEBDgABAQABAQMDAAAAAAAAAQEFAAICBgICAQcCAgEDDgEBAAUMAAAAAAAAAQEBAAMAAAQFDgAAAAAABQUBBgUAAAABAQMFBgMCBQASAQAAAAAJDCMlJwABAAEDAwEG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EWxBfwJ/IAwgAkMAAIBPXXEEQCACqQwBC0EAC0EAIAwbIAJD//9/T14bakECdGooAAALIQwgBiANNgJYIABBA00NBCABIAw2AAAgC0EBaiELIAEgDWohASAAIA1rIgANAAsLIAkgCmohCSAIQQFqIQggByAKayIHDQALDAMLDAQLDAILIAYgCkECdCIONgJYIApFDQIgB0UNACABQQxqKAIAIRAgASgCBLMhEyABKAIAIhGzIRQgBioCxAEhFSAGKgLAASEWIAYqArwBIRcgBioCuAEhGCAGKgK0ASEZIAYqArABIRpBACEIA0AgCUUNASAHIA4gByAOSRsiCgRAIBYgCLMiApQhGyAZIAKUIRxBACELIAkhASAKIQADQEEEIAAgAEEETxshDSAYIBwgGiALsyISlJKSEPsCIQIgFSAbIBcgEpSSkhD7AiESAn9BACACQwAAAABdDQAaQQAgAiAUYA0AGkEAIBJDAAAAAF0NABpBACASIBNgDQAaIAJDAAAAAGAhDCAQQX8CfyASQwAAAABgIg8gEkMAAIBPXXEEQCASqQwBC0EAC0EAIA8bIBJD//9/T14bIBFsQX8CfyAMIAJDAACAT11xBEAgAqkMAQtBAAtBACAMGyACQ///f09eG2pBAnRqKAAACyEMIAYgDTYCWCAAQQNNDQQgASAMNgAAIAtBAWohCyABIA1qIQEgACANayIADQALCyAJIApqIQkgCEEBaiEIIAcgCmsiBw0ACwsgBkHQAmokAA8LIAZBADYCiAJBACAGQdgAakGAncAAIAZBgAJqQYSdwAAQ5gEACyAGQQA2ApQCIAZBtKnAADYCkAIgBkEBNgKMAiAGQdypwAA2AogCIAZBADYCgAJBASAGQdgAakG0qcAAIAZBgAJqQbSqwAAQ5gEAC4AbAhl/A3wjAEGwBGsiAyQAIANCADcDmAEgA0IANwOQASADQgA3A4gBIANCADcDgAEgA0IANwN4IANCADcDcCADQgA3A2ggA0IANwNgIANCADcDWCADQgA3A1AgA0IANwNIIANCADcDQCADQgA3AzggA0IANwMwIANCADcDKCADQgA3AyAgA0IANwMYIANCADcDECADQgA3AwggA0IANwMAIANCADcDuAIgA0IANwOwAiADQgA3A6gCIANCADcDoAIgA0IANwOYAiADQgA3A5ACIANCADcDiAIgA0IANwOAAiADQgA3A/gBIANCADcD8AEgA0IANwPoASADQgA3A+ABIANCADcD2AEgA0IANwPQASADQgA3A8gBIANCADcDwAEgA0IANwO4ASADQgA3A7ABIANCADcDqAEgA0IANwOgASADQgA3A9gDIANCADcD0AMgA0IANwPIAyADQgA3A8ADIANCADcDuAMgA0IANwOwAyADQgA3A6gDIANCADcDoAMgA0IANwOYAyADQgA3A5ADIANCADcDiAMgA0IANwOAAyADQgA3A/gCIANCADcD8AIgA0IANwPoAiADQgA3A+ACIANCADcD2AIgA0IANwPQAiADQgA3A8gCIANCADcDwAIgA0HgA2pBAEHQABDOAxpB7JbDACgCACIKIQcgAkEDa0EYbSIFQQAgBUEAShsiDiEGIA5BaGwhDyAOQQJ0QfyWwwBqIQUDQCAEIAdPIAQgBCAHSWogAyAEQQN0aiAGQQBIBHxEAAAAAAAAAAAFIAUoAgC3CzkDACAFQQRqIQUgBkEBaiEGIgQgB0tyRQ0AC0EAIQYDQEEAIQQgA0HAAmogBkEDdGogHCAAIARBA3RqKwMAIAMgBiAEa0EDdGorAwCioDkDACAGIApJBEAgBiAGIApJaiIGIApNDQELC0QAAAAAAADwf0QAAAAAAADgfyACIA9qIgJBlwhrIgVB/wdLIhAbRAAAAAAAAAAARAAAAAAAAGADIAJBGGsiCUG5cEkiERtEAAAAAAAA8D8gCUGCeEgiEhsgCUH/B0oiExtB/RcgCSAJQf0XThtB/g9rIAUgEBsiFUHwaCAJIAlB8GhMG0GSD2ogAkGxB2ogERsiFiAJIBIbIBMbQf8Haq1CNIa/oiEeIApBAnQgA2pB3ANqIQ9BDyACa0EfcSEXQRAgAmtBH3EhFCACQRlrIRggCiEFAkADQCADQcACaiAFQQN0aisDACEcAkAgBUUNACADQeADaiEIIAUhBANAIBxEAAAAAAAAcD6iIh1EAAAAAAAA4MFmIQYgHEH/////BwJ/IB2ZRAAAAAAAAOBBYwRAIB2qDAELQYCAgIB4C0GAgICAeCAGGyAdRAAAwP///99BZBtBACAdIB1hG7ciHUQAAAAAAABwwaKgIhxEAAAAAAAA4MFmIQYgCEH/////BwJ/IByZRAAAAAAAAOBBYwRAIByqDAELQYCAgIB4C0GAgICAeCAGGyAcRAAAwP///99BZBtBACAcIBxhGzYCACAEQQN0IANqQbgCaisDACAdoCEcIARBAkkNASAIQQRqIQggBCAEQQFLayIEDQALCwJ/AkAgE0UEQCASDQEgCQwCCyAcRAAAAAAAAOB/oiIcRAAAAAAAAOB/oiAcIBAbIRwgFQwBCyAcRAAAAAAAAGADoiIcRAAAAAAAAGADoiAcIBEbIRwgFgshBCAcIARB/wdqrUI0hr+iIhwgHEQAAAAAAADAP6KcRAAAAAAAACDAoqAiHEQAAAAAAADgwWYhBCAcQf////8HAn8gHJlEAAAAAAAA4EFjBEAgHKoMAQtBgICAgHgLQYCAgIB4IAQbIBxEAADA////30FkG0EAIBwgHGEbIgu3oSEcAkACQAJAAn8gCUEASiIZRQRAIAkNAiAFQQJ0IANqQdwDaigCAEEXdQwBCyAFQQJ0IANqQdwDaiIEIAQoAgAiBCAEIBR1IgQgFHRrIgY2AgAgBCALaiELIAYgF3ULIgxBAEoNAQwCC0EAIQwgHEQAAAAAAADgP2ZFDQFBAiEMCwJAIAVFBEBBACEGDAELQQAhBkEAIQggBUEBRwRAIAVBfnEhGiADQeADaiEEA0AgBCgCACENQf///wchBwJ/AkAgBg0AQYCAgAghByANDQBBAQwBCyAEIAcgDWs2AgBBAAshDSAIQQJqIQggBEEEaiIbKAIAIQZB////ByEHAn8CQCANRQ0AQYCAgAghByAGDQBBAAwBCyAbIAcgBms2AgBBAQshBiAEQQhqIQQgCCAaRw0ACwsgBUEBcUUNACADQeADaiAIQQJ0aiIHKAIAIQRB////ByEIAkAgBg0AQYCAgAghCCAEDQBBACEGDAELIAcgCCAEazYCAEEBIQYLAkAgGUUNAEH///8DIQQCQAJAIBgOAgEAAgtB////ASEECyAFQQJ0IANqQdwDaiIHIAcoAgAgBHE2AgALIAtBAWohCyAMQQJHDQBEAAAAAAAA8D8gHKEiHCAeoSAcIAYbIRxBAiEMCyAcRAAAAAAAAAAAYQRAIA8hBCAFIQYCQCAKIAVBAWsiCEsNAEEAIQcDQAJAIANB4ANqIAhBAnRqKAIAIAdyIQcgCCAKTQ0AIAogCCAIIApLayIITQ0BCwsgBSEGIAdFDQAgBUECdCADakHcA2ohBCAJIQIDQCAFQQFrIQUgAkEYayECIAQoAgAgBEEEayEERQ0ACwwDCwNAIAZBAWohBiAEKAIAIARBBGshBEUNAAsgBUEBaiEHIAcgBiIFSw0BA0AgAyAHQQN0aiAHIA5qQQJ0QfyWwwBqKAIAtzkDAEEAIQREAAAAAAAAAAAhHCADQcACaiAHQQN0aiAcIAAgBEEDdGorAwAgAyAHIARrQQN0aisDAKKgOQMAIAYgB00EQCAGIQUMAwsgByAGIAdLaiIFIQcgBSAGTQ0ACyAGIQUMAQsLAkACQEEYIAJrIgRB/wdMBEAgBEGCeE4NAiAcRAAAAAAAAGADoiEcIARBuHBNDQFB4QcgAmshBAwCCyAcRAAAAAAAAOB/oiEcQZl4IAJrIgBBgAhJBEAgACEEDAILIBxEAAAAAAAA4H+iIRxB/RcgBCAEQf0XThtB/g9rIQQMAQsgHEQAAAAAAABgA6IhHEHwaCAEIARB8GhMG0GSD2ohBAsCQCAcIARB/wdqrUI0hr+iIhxEAAAAAAAAcEFmRQRAIAkhAgwBCyAcRAAAAAAAAHA+oiIdRAAAAAAAAODBZiEAIBxB/////wcCfyAdmUQAAAAAAADgQWMEQCAdqgwBC0GAgICAeAtBgICAgHggABsgHUQAAMD////fQWQbQQAgHSAdYRu3IhxEAAAAAAAAcMGioCIdRAAAAAAAAODBZiEAIANB4ANqIAVBAnRqQf////8HAn8gHZlEAAAAAAAA4EFjBEAgHaoMAQtBgICAgHgLQYCAgIB4IAAbIB1EAADA////30FkG0EAIB0gHWEbNgIAIAVBAWohBQsgHEQAAAAAAADgwWYhACADQeADaiAFQQJ0akH/////BwJ/IByZRAAAAAAAAOBBYwRAIByqDAELQYCAgIB4C0GAgICAeCAAGyAcRAAAwP///99BZBtBACAcIBxhGzYCAAsCQAJAIAJB/wdMBEBEAAAAAAAA8D8hHCACQYJ4SA0BIAIhBAwCC0QAAAAAAADgfyEcIAJB/wdrIgRBgAhJDQFB/RcgAiACQf0XThtB/g9rIQREAAAAAAAA8H8hHAwBCyACQbhwSwRAIAJByQdqIQREAAAAAAAAYAMhHAwBC0HwaCACIAJB8GhMG0GSD2ohBEQAAAAAAAAAACEcCyAcIARB/wdqrUI0hr+iIRwgBUEBcQR/IAUFIANBwAJqIAVBA3RqIBwgA0HgA2ogBUECdGooAgC3ojkDACAcRAAAAAAAAHA+oiEcIAUgBUEAR2sLIQQgBQRAA0AgA0HAAmoiAiAEQQN0aiAcIANB4ANqIgYgBEECdGooAgC3ojkDACACIAQgBEEAR2siAEEDdGogHEQAAAAAAABwPqIiHCAAQQJ0IAZqKAIAt6I5AwAgACAAQQBHayEEIBxEAAAAAAAAcD6iIRwgAA0ACwsgA0HAAmogBUEDdGohCCAFIQIDQEEAIQRBf0EAIAIiABshCSAFIAJrIQZEAAAAAAAAAAAhHEEBIQIDQAJAIBwgBEGImcMAaisDACAEIAhqKwMAoqAhHCACIApLDQAgBEEIaiEEIAIgBk0gAkEBaiECDQELCyADQaABaiAGQQN0aiAcOQMAIAhBCGshCCAAIAlqIQIgAA0AC0QAAAAAAAAAACEcAkAgBUEBakEDcSIARQRAIAUhBAwBCyAFIQIDQCAcIANBoAFqIAJBA3RqKwMAoCEcIAIgAkEAR2siBCECIABBAWsiAA0ACwsgBUEDTwRAA0AgHCADQaABaiIFIgAgBEEDdGorAwCgIAQgBEEAR2siAkEDdCAAaisDAKAgACACIAJBAEdrIgBBA3RqKwMAoCAAIABBAEdrIgBBA3QgBWorAwCgIRwgACAAQQBHayEEIAANAAsLIAEgHJogHCAMGzkDACADQbAEaiQAIAtBB3ELrBsDF38JfQZ+IwBBoAFrIgQkAAJAAkACQAJAAkAgASgCACIJIAJHIAEoAgQiBiADR3JFBEAgAkH/////A3EgAkcNBSACQQJ0rSADrX4iJEIgiKcNBQJAICSnIgZFBEBBASEHDAELIAZBAE4iBUUNBCAGIAUQjQMiB0UNAwsgBEE4aiIFIAY2AgAgBEE0aiAHNgIAIAQgBjYCMCAEIAM2AiwgBCACNgIoIARBQGsgBEEoaiABQQBBABBMIAQoAkBBBkcNASAAIAQpAyg3AgAgAEEQaiAFKAIANgIAIABBCGogBEEwaikDADcCAAwECwJAIAlB/////wNxIAlHDQAgA60iJiAJQQJ0rX4iJEIgiKcNAAJAAkAgJKciDkUEQEEEIRYMAQsgDkH/////AUsNBSAOQQJ0IghBAEgNBSAOQYCAgIACSUECdCEFIAgEfyAIIAUQjQMFIAULIhZFDQELQaidwAAqAgAhI0GUncAAKAIAIRQgBEKAgICAwAA3AygCQCADRQ0AIAazIAOzlSIhQwAAgD+XIiIgI5QhICAGrSIpQgF9IScDQCAEQQA2AjAgICAhIBezQwAAAD+SlCIdko0iG0MAAADfYCEFQv///////////wACfiAbi0MAAABfXQRAIBuuDAELQoCAgICAgICAgH8LQoCAgICAgICAgH8gBRsgG0P///9eXhtCACAbIBtbGyIoICkgKCApUxshJCAdICCTjiIbQwAAAN9gIQUCQEL///////////8AAn4gG4tDAAAAX10EQCAbrgwBC0KAgICAgICAgIB/C0KAgICAgICAgIB/IAUbIBtD////Xl4bQgAgGyAbWxsiJSAnICUgJ1MbQgAgJUIAWRsiJaciDCAkICVCAXwgKCAlQv////8Pg1UbpyINTw0AIB1DAAAAv5IhHSAUKAIUIQdDAAAAACEcIAwhBQNAIAVBAWpBASAFsyAdkyAilSAHEQsAIRsgBCgCMCIFIAQoAihGBEAgBEEoaiAFEKYBIAQoAjAhBQsgBCgCLCAFQQJ0aiAbOAIAIAQgBCgCMCIIQQFqIg82AjAgHCAbkiEcIgUgDUcNAAsgD0UNACAEKAIsIgYhBSAPQQNxIgcEQANAIAUgBSoCACAclTgCACAFQQRqIQUgB0EBayIHDQALCyAIQf////8DcUEDSQ0AIAYgD0ECdGohCANAIAUgBSoCACAclTgCACAFQQRqIgYgBioCACAclTgCACAFQQhqIgYgBioCACAclTgCACAFQQxqIgYgBioCACAclTgCACAFQRBqIgUgCEcNAAsLAkAgCUUNAEEBIAxrIRggCSAXbCEPIAkgEGxBBGtBAnYhDUEAIQoCQANAAkAgBCgCMCIFRQRAQwAAAAAhHkMAAAAAIR9DAAAAACEcQwAAAAAhGwwBCyABKAIEIRkCQAJAAkAgCiABKAIAIhpJBEAgBCgCLCERIAFBEGooAgAhEiABQQxqKAIAIQcgBUECdCEVIBpBAnQhBiAYIBkgDCAMIBlJGyITaiEIIAogDCAabGpBAnRBBGohBUMAAAAAIRtDAAAAACEcQwAAAAAhH0MAAAAAIR4DQCAIQQFrIghFDQIgBUUNAyAFIBJLDQQgGyARKgIAIh0gBSAHakEEaygAACILQRh2s5SSIRsgHiAdIAtB/wFxs5SSIR4gHCAdIAtBEHZB/wFxs5SSIRwgHyAdIAtBCHZB/wFxs5SSIR8gBSAGaiEFIBFBBGohESAVQQRrIhUNAAsMBAsgJachEwsgBEHMAGpBBTYCACAEQfQAakECNgIAIARB/ABqQQI2AgAgBCATNgKUASAEIAo2ApABIARBgIrAADYCcCAEQQA2AmggBEEFNgJEIAQgGTYCnAEgBCAaNgKYASAEIARBQGs2AnggBCAEQZgBajYCSCAEIARBkAFqNgJAIARB6ABqQdCKwAAQrAIAC0F8IAVBwIrAABCmAwALIAUgEkHAisAAEKUDAAsgCiAPakECdCIFQQRqIQYgCiANRwRAIAYgDksNAiAWIAVBAnRqIgUgGzgCDCAFIBw4AgggBSAfOAIEIAUgHjgCACAKQQFqIgogCUYNAwwBCwtBfCAGQfSXwAAQpgMACyAGIA5B9JfAABClAwALIBBBBGshECAXQQFqIhcgA0cNAAsgBCgCKEUNACAEKAIsED0LAkAgAkH/////A3EgAkcNACACQQJ0rSAmfiIkQiCIpw0AAkACQCAkpyILRQRAQQEhEgwBCyALQQBOIgFFDQcgCyABEI0DIhJFDQELIAAgCzYCCCAAIAM2AgQgACACNgIAIABBEGogCzYCACAAQQxqIBI2AgAgBEKAgICAwAA3AygCQCACRQ0AIAmzIAKzlSIhQwAAgD+XIiIgI5QhICAJQQJ0IRggCUEEdCEPIAmtIidCAX0hKEEAIQoDQCAEQQA2AjAgICAhIAqzQwAAAD+SlCIdko0iG0MAAADfYCEAQv///////////wACfiAbi0MAAABfXQRAIBuuDAELQoCAgICAgICAgH8LQoCAgICAgICAgH8gABsgG0P///9eXhtCACAbIBtbGyIlICcgJSAnUxshJCAdICCTjiIbQwAAAN9gIQACQEL///////////8AAn4gG4tDAAAAX10EQCAbrgwBC0KAgICAgICAgIB/C0KAgICAgICAgIB/IAAbIBtD////Xl4bQgAgGyAbWxsiJiAoICYgKFMbQgAgJkIAWRsiJqciCCAkICZCAXwgJSAmQv////8Pg1UbpyIMTw0AIB1DAAAAv5IhHSAUKAIUIQZDAAAAACEcIAghBQNAIAVBAWpBASAFsyAdkyAilSAGEQsAIRsgBCgCMCIFIAQoAihGBEAgBEEoaiAFEKYBIAQoAjAhBQsgBCgCLCAFQQJ0aiAbOAIAIAQgBCgCMCIBQQFqIg02AjAgHCAbkiEcIgUgDEcNAAsgDUUNACAEKAIsIgAhBSANQQNxIgcEQANAIAUgBSoCACAclTgCACAFQQRqIQUgB0EBayIHDQALCyABQf////8DcUEDSQ0AIAAgDUECdGohAQNAIAUgBSoCACAclTgCACAFQQRqIgAgACoCACAclTgCACAFQQhqIgAgACoCACAclTgCACAFQQxqIgAgACoCACAclTgCACAFQRBqIgUgAUcNAAsLAkAgA0UNACAIQQJ0QQRqIQYgFiAIQQR0aiEBIAkgCCAIIAlJGyINIAhrQQFqIQBBACEQAkACQAJAAkADQAJAIAQoAjAiBUUEQEMAAAAAIR5DAAAAACEfQwAAAAAhHEMAAAAAIRsMAQsgBCgCLCERIAVBAnQhFUMAAAAAIRsgBiEHIAEhBSAAIQhDAAAAACEcQwAAAAAhH0MAAAAAIR4CQAJAA0AgCEEBayIIBEAgB0UNAiAHIA5LDQMgB0EEaiEHIB4gBSoCACARKgIAIh2UkiEeIBsgBUEMaioCACAdlJIhGyAcIAVBCGoqAgAgHZSSIRwgHyAFQQRqKgIAIB2UkiEfIAVBEGohBSARQQRqIREgFUEEayIVDQEMBAsLIARBzABqQQU2AgAgBEH0AGpBAjYCACAEQfwAakECNgIAIAQgEDYClAEgBCANNgKQASAEQaCYwAA2AnAgBEEANgJoIARBBTYCRCAEIAM2ApwBIAQgCTYCmAEgBCAEQUBrNgJ4IAQgBEGYAWo2AkggBCAEQZABajYCQCAEQegAakHAmMAAEKwCAAtBfCAHQbCYwAAQpgMACyAHIA5BsJjAABClAwALIARDAAAAACAeQwAAf0OWIB5DAAAAAF0bOAJoIARBIGogBEHoAGoQmgIgBC0AIEEBcUUEQEHQmMAAQStBkJrAABCTAgALIAQtACEhDCAEQwAAAAAgH0MAAH9DliAfQwAAAABdGzgCaCAEQRhqIARB6ABqEJoCIAQtABhBAXEEQCAELQAZIQggBEMAAAAAIBxDAAB/Q5YgHEMAAAAAXRs4AmggBEEQaiAEQegAahCaAiAELQAQQQFxRQ0CIAQtABEhBSAEQwAAAAAgG0MAAH9DliAbQwAAAABdGzgCaCAEQQhqIARB6ABqEJoCIAQtAAhBAXFFDQMgAiAQbCAKakECdCIHQQRqIRMgB0F8Rg0EIAsgE0kNBSAHIBJqIAQtAAlBGHQgBUEQdHIgCEEIdHIgDHI2AAAgBiAYaiEGIAEgD2ohASAQQQFqIhAgA0YNBgwBCwtB0JjAAEErQYCawAAQkwIAC0HQmMAAQStB8JnAABCTAgALQdCYwABBK0HgmcAAEJMCAAtBfCATQfSXwAAQpgMACyATIAtB9JfAABClAwALIApBAWoiCiACRw0ACyAEKAIoRQ0AIAQoAiwQPQsgDgRAIBYQPQtBASAUKAIAEQMAIBRBBGooAgBFDQcgFEEIaigCABpBARA9DAcLIAsgARDKAwALDAYLIAggBRDKAwALDAQLIARBiAFqIARB4ABqKQMANwMAIARBgAFqIARB2ABqKQMANwMAIARB+ABqIARB0ABqKQMANwMAIARB8ABqIARByABqKQMANwMAIAQgBCkDQDcDaEGgmsAAQSsgBEHoAGpBzJrAAEHcmsAAENEBAAsgBiAFEMoDAAsQoAIACyAEQaABaiQADwtB4IrAAEEzQZSLwAAQqAMAC6XeAgQyfwV+CHwTfSMAQeABayITJAAgE0G4AWohCiMAQSBrIg8kACAPIAU2AgwCQAJAAkAgD0EMaigCABATBEAgD0EQaiIJIA9BDGoQ3QIgD0EANgIcIwBB0ABrIhIkACAJKAIIIgcEQCAJQQRqKAIAIgYgCSgCAGsiBUEAIAUgBk0bIQ4LIBJBQGsgDjYCACASQQE2AjwgEiAONgI4IBJBEGohBkEAIQ4gEkE4aiIFKAIEQQFHBH9BAAUgBUEIaigCACIOIAUoAgBGCyEFIAYgDjYCBCAGIAU2AgACQAJAAkBBgCAgEigCFCIFIAVBgCBPG0EAIBIoAhAbIgZFBEBBBCEODAELIAZBGGwiBUEEEIwDIg5FDQELIBJBADYCICASIA42AhwgEiAGNgIYAkACQCAHRQ0AIBJBQGshCANAIBJBCGogCRCeAiASKAIIRQ0BIBIoAgwhBSAJIAkoAgxBAWo2AgwgEkE4aiAFECwgEigCPCEHIBIoAjgiBkECRgRAIApBADYCBCAKIAc2AgAgEigCICIFBEAgBUEYbCEOIBIoAhxBEGohBQNAIAVBBGsoAgAEQCAFKAIAED0LIAVBGGohBSAOQRhrIg4NAAsLIBIoAhhFDQMgEigCHBA9DAMLIBJBMGoiBSAIQQhqKQIANwMAIBIgCCkCADcDKCASKAIgIg4gEigCGEYEQCASQRhqIA4QpwEgEigCICEOCyASKAIcIA5BGGxqIgsgBzYCBCALIAY2AgAgC0EIaiASKQMoNwIAIAtBEGogBSkDADcCACASIBIoAiBBAWo2AiAgCSgCCA0ACwsgCiASKQMYNwIAIApBCGogEkEgaigCADYCAAsgEkHQAGokAAwBCyAFQQQQygMACwwBCyAPQRBqIA9BDGoQjAEgDygCECEGAkACQAJAIA8tABQiBUECaw4CAQACCyAKQQA2AgQgCiAGNgIAIA8oAgwiBUGEAUkNBAwDCyAPQQxqIA9BEGpBxKXAABBlIQUgCkEANgIEIAogBTYCAAwBCyMAQdAAayIJJAAgCSAFQQBHOgAUIAkgBjYCECAJQQA2AiAgCUKAgICAwAA3AxggCUFAayELAkACQAJ/A0ACQCAJQQhqIAlBEGoQzwEgCSgCDCEGIAkoAggiBQRAIAVBAmsNASAKIAkpAxg3AgAgCkEIaiAJQSBqKAIANgIAIAkoAhAiBkGDAUsNBAwFCyAJQThqIAYQLCAJKAI8IgggCSgCOCIHQQJGDQIaIAlBMGoiBSALQQhqKQIANwMAIAkgCykCADcDKCAJKAIgIgYgCSgCGEYEQCAJQRhqIAYQpwEgCSgCICEGCyAJKAIcIAZBGGxqIgYgCDYCBCAGIAc2AgAgBkEIaiAJKQMoNwIAIAZBEGogBSkDADcCACAJIAkoAiBBAWo2AiAMAQsLIAYLIQUgCkEANgIEIAogBTYCACAJKAIgIgUEQCAFQRhsIQcgCSgCHEEQaiEGA0AgBkEEaygCAARAIAYoAgAQPQsgBkEYaiEGIAdBGGsiBw0ACwsgCSgCGARAIAkoAhwQPQsgCSgCECIGQYQBSQ0BCyAGEAALIAlB0ABqJAALIA8oAgwiBUGDAU0NAQsgBRAACyAPQSBqJAAgEygCuAEhBgJAAkACQAJAAkACQAJAAkACQAJAAkACQCATKAK8ASIFBEAgEyATKALAATYCGCATIAU2AhQgEyAGNgIQIBNBuAFqIRcjAEGgEGsiDCQAIAwgBDYCHCAMIAM2AhggDEGAgID8AzYCmAwgDEGAgID8AzYCiAEgDEGYDGohCSAMQYgBaiELQQAhB0EAIQgCQAJAIBNBEGoiDigCCCIKRQ0AIA4oAgRBDGohBQNAAkAgBUEIaigCAEEGRw0AIAVBBGooAgAiBkHkgcAAQQYQzwMNACAJIAVBBGsqAgAiRTgCACALIAVBCGsqAgAgRSAFQQxrKAIAGzgCAEEBIQggB0EBaiEHIAUoAgBFDQIgBhA9DAILIAVBGGohBSAKIAdBAWoiB0cNAAsMAQsgByAKRg0AIAogB2shGiAOKAIEIAdBGGxqIQUDQAJAAkAgBUEUaigCAEEGRw0AIAVBEGooAgAiBkHkgcAAQQYQzwMNACAJIAVBCGoqAgAiRTgCACALIAVBBGoqAgAgRSAFKAIAGzgCACAIQQFqIQggBUEMaigCAEUNASAGED0MAQsgBSAIQWhsaiIGIAUpAgA3AgAgBkEQaiAFQRBqKQIANwIAIAZBCGogBUEIaikCADcCAAsgBUEYaiEFIBpBAWsiGg0ACwsgDiAKIAhrNgIIIAwqAogBIUcgDCoCmAwhRQJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQCAEQQNrDgIAAQILAkAgA0GIssAAQQMQzwMEQCADQYuywABBAxDPAw0DIAxB7ABqIAI2AgAgDCABNgJoIAxCADcDYCAMQYgBaiAMQeAAahAyIAwoAtgDIghBAkYNCCAMQZgMaiIJIAxBiAFqIgtB0AIQ0AMaIAxByAlqIgcgDEHcA2oiBkG0ARDQAxogDEHABWoiBSAJQdACENADGiALIAVB0AIQ0AMaIAwgCDYC2AMgBiAHQbQBENADGiMAQcAIayIKJAAgCkEIaiALQYgEENADGgJAAkACQAJAAkACQAJAAkACQAJAAkACQCAKQcgAaigCAEECRwRAIAogCkEYahC8AyAKKAIEIQcgCigCACELAkACQAJAAkACQAJAAkACQAJAAkACQCAKLQCIBCIGQQFrDgkIBwYFBAMCAQAJCyAKQbgEaiIFIApBCGpBiAQQ0AMaIApBkARqIAUQWyAKKAKQBCIIQQZGBEAgCkGYBGooAgAhDiAKKAKUBCEIAkAgC0H/////A3EgC0cNACALQQJ0rSAHrX4iOEIgiKcNACAKQZwEaigCACIiIDinTw0LCyAIRQ0VIA4QPQwVCyAJIAopA6AENwMQIAlBGGogCkGoBGopAwA3AwAgCUEgaiAKQbAEaikDADcDACAKKQKUBCE4IAkgCigCnAQ2AgwgCSA4NwIEDBYLIApBuARqIgUgCkEIakGIBBDQAxogCkGQBGogBRBbIAooApAEIghBBkYNEiAJIAopA6AENwMQIAlBGGogCkGoBGopAwA3AwAgCUEgaiAKQbAEaikDADcDACAKKQKUBCE4IAkgCigCnAQ2AgwgCSA4NwIEDBULIApBuARqIgUgCkEIakGIBBDQAxogCkGQBGogBRBaIAooApAEIghBBkYNECAJIAopA6AENwMQIAlBGGogCkGoBGopAwA3AwAgCUEgaiAKQbAEaikDADcDACAKKQKUBCE4IAkgCigCnAQ2AgwgCSA4NwIEDBQLIApBuARqIgUgCkEIakGIBBDQAxogCkGQBGogBRBaIAooApAEIghBBkYNDiAJIAopA6AENwMQIAlBGGogCkGoBGopAwA3AwAgCUEgaiAKQbAEaikDADcDACAKKQKUBCE4IAkgCigCnAQ2AgwgCSA4NwIEDBMLIApBuARqIgUgCkEIakGIBBDQAxogCkGQBGogBRBaIAooApAEIghBBkYNDCAJIAopA6AENwMQIAlBGGogCkGoBGopAwA3AwAgCUEgaiAKQbAEaikDADcDACAKKQKUBCE4IAkgCigCnAQ2AgwgCSA4NwIEDBILIApBuARqIgUgCkEIakGIBBDQAxogCkGQBGogBRBaIAooApAEIghBBkYNCiAJIAopA6AENwMQIAlBGGogCkGoBGopAwA3AwAgCUEgaiAKQbAEaikDADcDACAKKQKUBCE4IAkgCigCnAQ2AgwgCSA4NwIEDBELIApBuARqIgUgCkEIakGIBBDQAxogCkGQBGogBRBdIAooApAEIghBBkYNCCAJIAopA6AENwMQIAlBGGogCkGoBGopAwA3AwAgCUEgaiAKQbAEaikDADcDACAKKQKUBCE4IAkgCigCnAQ2AgwgCSA4NwIEDBALIApBuARqIgUgCkEIakGIBBDQAxogCkGQBGogBRBdIAooApAEIghBBkYNBiAJIAopA6AENwMQIAlBGGogCkGoBGopAwA3AwAgCUEgaiAKQbAEaikDADcDACAKKQKUBCE4IAkgCigCnAQ2AgwgCSA4NwIEDA8LIApBuARqIgUgCkEIakGIBBDQAxogCkGQBGogBRBdIAoo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QQFrDgIBAgALIAFBmARqKAIAIQYCQCABQZwEaigCACIDRQRAQQEhBAwBCyADQQBOIgVFDRIgAyAFEIwDIgRFDRcLIAQgBiADENADIQQgAUGQBGooAgAhBSABKAKMBCEGIAFBqARqKAIABEAgAUGsBGooAgAQPQsgASADNgKoBCABIAY2AqAEIAFBsARqIAM2AgAgAUGsBGogBDYCACABQaQEaiAFNgIADAILIAFBmARqKAIAIQYCQCABQZwEaigCACIDRQRAQQEhBAwBCyADQQBOIgVFDREgAyAFEIwDIgRFDRYLIAQgBiADENADIQQgAUGQBGooAgAhBiABKAKMBCIHIQUgAUGoBGooAgAEQCABQawEaigCABA9IAEoAowEIQULIAEgAzYCqAQgASAHNgKgBCABQbAEaiADNgIAIAFBrARqIAQ2AgAgAUGkBGogBjYCACAFQf////8DcSAFRw0EIAE1ApAEIAVBAnStfiISQiCIpw0EIBKnIgMgAUGcBGooAgAiBEsNBSADRQ0BIAFBmARqKAIAQQAgAxDOAxoMAQsgAUGsBGooAgAhBgJAIAFBsARqKAIAIgNFBEBBASEEDAELIANBAE4iBUUNECADIAUQjAMiBEUNFQsgBCAGIAMQ0AMhBCABQaQEaigCACEFIAEoAqAEIQYgAUGUBGooAgAEQCABQZgEaigCABA9CyABIAM2ApQEIAEgBjYCjAQgAUGcBGogAzYCACABQZgEaiAENgIAIAFBkARqIAU2AgALIAFBQGsoAgBBAkYNEiACQRhqIAFBEGoiDRC8AyACKAIcIQMgAigCGCEEIAJBEGogARCSAQJAIAMgAi0AECACLQARIAQQ1AFBAWtsIgNFBEBBASEFDAELIANBAE4iBEUNDyADIAQQjQMiBUUNBQsgAkHYAGogASAFIAMQLQJ/AkACQCACLQBYQSNHBEAgAkGAAWogAkHoAGooAgA2AgAgAkH4AGogAkHgAGopAwA3AwAgAiACKQNYNwNwIAJBmAFqIAJB8ABqEGggAigCmAEiBEEGRw0BCyABKAJAQQJGDRUgDRDwAiIHDQEgAUHUAGooAgAhBiABQdAAaigCACEEQQEMAgsgAkFAayACQagBaigCADYCACACQcwAaiACQbQBaikCADcCACACQdQAaiACQbwBaigCADYCACACIAIpA6ABNwM4IAIgAikCrAE3AkQgAigCnAEhASADRQ0DIAUQPQwDCyAHKAIQIQogBygCDCELIAcoAgghBiAHKAIEIQQgBy0AGSABIActABg6ALQERQshBwJAAkACQAJAAkACQAJAAkACQAJAIAgtAAAOCAECAwQPDw8PAAtBjI7AAEGUjsAAEJECAAsgBK0gBq1+IhJCIIhQIBKnIANNcQ0FIAMEQCAFED0LQamMwABBK0HQj8AAEJMCAAsCQCAEIARqIgggBEkNACAIrSAGrX4iEkIgiKcNACASpyADTQ0ECyADBEAgBRA9C0GpjMAAQStB+I7AABCTAgALAkAgBK1CA34iEkIgiKcNACASp60gBq1+IhJCIIinDQAgEqcgA00NAgsgAwRAIAUQPQtBqYzAAEErQeiOwAAQkwIACwJAIARB/////wNxIARHDQAgBEECdK0gBq1+IhJCIIinDQAgEqcgA00NBAsgAwRAIAUQPQtBqYzAAEErQdiOwAAQkwIACyACQawBaiADNgIAIAJBqAFqIAU2AgAgAkGkAWogAzYCACACQaABaiAGNgIAIAIgBDYCnAEgAkECNgKYASACQdgAaiACQZgBahDOASAHDQ8MAwsgAkGsAWogAzYCACACQagBaiAFNgIAIAJBpAFqIAM2AgAgAkGgAWogBjYCACACIAQ2ApwBIAJBATYCmAEgAkHYAGogAkGYAWoQzgEgBw0ODAILIAJBrAFqIAM2AgAgAkGoAWogBTYCACACQaQBaiADNgIAIAJBoAFqIAY2AgAgAiAENgKcASACQQA2ApgBIAJB2ABqIAJBmAFqEM4BIAdFDQEMDQsgAiADNgJoIAIgBTYCZCACIAM2AmAgAiAGNgJcIAIgBDYCWCAHDQwLIAIoAlgiBkH/////A3EgBkcNBiAGQQJ0rSACKAJcIgStfiISQiCIpw0GIBKnIgMgAkHoAGooAgAiBUsNByADRQ0MQQAgBCAGbEECdGshCCAGRSEFIAJB5ABqKAIAIQQgAUGYBGohDyABQZwEaiEQQQAhAwNAIAEoAowEIgcgAyALaiIJTSAFIApqIgwgASgCkAQiEU9yDQkgByAMbCAJakECdCIJQQRqIQcgCUF8Rg0KIAcgECgCACIMSw0LIA8oAgAgCWogBBBfIANBAWoiB0EAIAYgB0sbIQMgBSAGIAdNaiEFIARBBGohBCAIQQRqIggNAAsMDAsgAkFAayACQagBaikDADcDACACQcgAaiACQbABaikDADcDACACQdAAaiACQbgBaikDADcDACACIAIpA6ABNwM4IAIoApwBIQELIAAgAikDODcDCCAAIAE2AgQgACAENgIAIABBIGogAkHQAGopAwA3AwAgAEEYaiACQcgAaikDADcDACAAQRBqIAJBQGspAwA3AwAMCwtBmInAAEErQbCKwAAQkwIACyADIARBoIrAABClAwALIAMgBBDKAwALQcCOwABByI7AABCRAgALQZiJwABBK0HEicAAEJMCAAsgAyAFQYiJwAAQpQMACyACQfwAakEFNgIAIAJBpAFqQQI2AgAgAkGsAWpBAjYCACACIAw2AsQBIAIgCTYCwAEgAkGgkcAANgKgASACQQA2ApgBIAJBBTYCdCACIBE2AswBIAIgBzYCyAEgAiACQfAAajYCqAEgAiACQcgBajYCeCACIAJBwAFqNgJwIAJBmAFqQbCRwAAQrAIAC0F8IAdB9JDAABCmAwALIAcgDEH0kMAAEKUDAAsgAkHwAGogAUGMBGogAkHYAGogCyAKEEwgAigCcEEGRg0AIAJBuAFqIAJBkAFqKQMANwMAIAJBsAFqIAJBiAFqKQMANwMAIAJBqAFqIAJBgAFqKQMANwMAIAJBoAFqIAJB+ABqKQMANwMAIAIgAikDcDcDmAFBiI/AAEElIAJBmAFqQbCPwABBwI/AABDRAQALIAEgDkEBazYCiAQgAigCYARAIAJB5ABqKAIAED0LIAFBmARqKAIAIQYCQCABQZwEaigCACIFRQRAQQEhBAwBCyAFQQBOIgNFDQIgBSADEIwDIgRFDQMLIAQgBiAFENADIQggASgCQEECRg0FIAFBkARqKAIAIQogASgCjAQhCyANEPACIgFFDQMCfyABLwEUIgNFBEBBACEEQQEMAQtBASEEQQEgA0HoB2wiBiABLwEWIgFB5AAgARsiB0YNABogBiAHcmghBAJAIAYgBmh2IgMgByAHaHYiAUYEQCADIQEMAQsDQAJAIAEgA08EQCABIANrIgEgAWh2IQEMAQsgAyABayIDIANodiEDCyABIANHDQALCyABIAR0IgFFDQUgBiABbiEEIAcgAW4LIQEgAkEIaiAEIAEQkAMgAigCDCEBIAIoAgghAyACIAU2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IANBEGogAUEYaigCADYCACABKAIMIQYgA0ECNgLQAiADIAY2AgQgAyAFOgAAIAQQVwsgAUGgBGokACACKALoEEECRw0BIAJBqBJqIAJBqA5qKAIANgIAIAJBoBJqIAJBoA5qKQMANwMAIAIgAikDmA43A5gSIAJBmApqIAJBmBJqEGgMAgsgACACKQKcDjcCBCAAQSRqIAJBvA5qKAIANgIAIABBHGogAkG0DmopAgA3AgAgAEEUaiACQawOaikCADcCACAAQQxqIAJBpA5qKQIANwIADAMLIAJBmApqIAJBmA5qQYAEENADGiACKALoDCIBQQJHDQULIAJB6AdqIAJBuApqKQMAIgc3AwAgAkHgB2ogAkGwCmopAwAiCDcDACACQdgHaiACQagKaikDACIJNwMAIAJB0AdqIAJBoApqKQMAIgo3AwAgAiACKQOYCiILNwPIByAAQSBqIAc3AwAgAEEYaiAINwMAIABBEGogCTcDACAAQQhqIAo3AwAgACALNwMAIABBAjYC0AIMBQsgACACKQOgDjcDCCAAQRBqIAJBqA5qKQMANwMAIABBGGogAkGwDmopAwA3AwAgAEEgaiACQbgOaikDADcDACAAIAIoApwONgIECyAAIAE2AgAgAEECNgLQAiACQShqEFcMAwtBgIACQQEQygMACyAAIAIpApwONwIEIABBJGogAkG8DmooAgA2AgAgAEEcaiACQbQOaikCADcCACAAQRRqIAJBrA5qKQIANwIAIABBDGogAkGkDmopAgA3AgAgAEECNgLQAiAAIAM2AgAMAQsgAkHIB2oiAyACQZgKakHQAhDQAxogAkGcBmogAkHsDGpBrAEQ0AMaIAJByANqIgQgA0HQAhDQAxogAiABNgKYBiACIAQQkgEgAi0AASEDAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkAgAi0AAEEBaw4GFAEEAhQDAAtBACEBIANBAmsODw0TDhMTExETExMTExMTDwwLQQIhASADQQJrDg8IEgkSEhIQEhISEhISEgoHC0EBIQEgA0ECaw4PAxEEERERDxEREREREREFAgtBAyEBAkACQAJAAkAgA0ECaw4PARQCFBQUEhQUFBQUFBQDAAsgAEEEIAIQuwIMEAsgAEEIIAIQuwIMDwsgAEEMIAIQuwIMDgtBByEBDA4LIABBGSADELsCDAwLIABBAiACELsCDAsLIABBBiACELsCDAoLIABBCiACELsCDAkLQQUhAQwJCyAAQQMgAhC7AgwHCyAAQQcgAhC7AgwGCyAAQQsgAhC7AgwFC0EGIQEMBQsgAEEBIAIQuwIMAwsgAEEFIAIQuwIMAgsgAEEJIAIQuwIMAQtBBCEBDAELIABBAjYC0AIgAkHIA2oQVyACKALwBgRAIAJB9AZqKAIAED0LIAIoAvwGBEAgAkGAB2ooAgAQPQsgAigCiAdFDQEgAkGMB2ooAgAQPQwBCyAAIAJByANqQYAEENADIAE6AIAECyACQcAVaiQADwsAC+sKAhV/AX4jAEEQayIMJAACQAJAIAFBwAFqKAIAIgdFDQACQAJAAkACfwJAAkAgAS0A8gFFBEAgAUHrAWotAAAhDyABQeoBai0AACEEIAFB2AFqKAIAIgsNASABQbABaigCACILDQJBmLTAAEErQfizwAAQkwIACyACIAFBvAFqKAIAIgYgAyAHIAMgB0kbIggQ0AMaQQEhBQwDCyABQdwBagwBCyABQbQBagshCSADIANBAnYiDSAHIAcgDUsbIghBAnQiCk8EQCAIRQRAQQQhBUEAIQggByEEDAMLIAkoAgAhDSABQbwBaigCACEGIARFIRAgAiEEQQAhCQNAAkAgDSAGIAlqLQAAIhFBA2wiDkEDakkNAAJAAkACQAJAIA0gDk8EQCANIA5GDQFBBCAKIApBBE8bRQ0CIAQgCyAOaiIFLQAAOgAAIA0gDmsiDkEBTQ0DIARBAWogBS0AAToAACAOQQJGDQQgBEECaiAFLQACOgAAIARBA2pBACAQIA8gEUdyazoAAAwFCyAOIA1B+LPAABCkAwALQQBBAEH4s8AAENgBAAtBAEEAQfizwAAQ2AEAC0EBQQFB+LPAABDYAQALQQJBAkH4s8AAENgBAAtBBCEFIARBBGohBCAKQQRrIQogCUEBaiIJIAhHDQALDAELIAogA0H4s8AAEKUDAAsgAUHAAWpBADYCACAHIAhrIQQgCEUEQEEAIQgMAQsgByAIRg0BIAYgBiAIaiAEENEDCyABQcABaiAENgIACyADIAUgCGwiBE8EQCADIARrIgMEQCACIARqIQIMAgsgAEECNgIAIABBAToABAwCCyAEIANBiLTAABCkAwALIAwgARBZAkACQCAMLQAAIhBBC0cEQCABQbQBaiENIAFB3AFqIQ4gAUHYAWohEyABQbABaiEUA0AgDCgCCCEGIAwoAgQhByAQQQhHDQMCQAJAIAEtAPIBRQRAIAEtAOsBIRUgAS0A6gEhFiAOIQkgEygCACIRDQEgDSEJIBQoAgAiEQ0BQZi0wABBK0HEtMAAEJMCAAsgAiAHIAMgBiADIAZJGyILENADGkEBIQUMAQsgAyADQQJ2IgQgBiAEIAZJGyILQQJ0IgpPBEBBBCEFIAsgBiAGIAtLGyIIRSACRXINASAJKAIAIQ8gByEJIAIhBANAAkAgDyAJLQAAIhdBA2wiBUEDakkNAAJAAkACQAJAIAUgD00EQCAFIA9GDQFBBCAKIApBBE8bRQ0CIAQgBSARaiISLQAAOgAAIA8gBWsiBUEBTQ0DIARBAWogEi0AAToAACAFQQJGDQQgBEECaiASLQACOgAAIARBA2pBACAWRSAVIBdHcms6AAAMBQsgBSAPQcS0wAAQpAMAC0EAQQBBxLTAABDYAQALQQBBAEHEtMAAENgBAAtBAUEBQcS0wAAQ2AEAC0ECQQJBxLTAABDYAQALIAlBAWohCUEEIQUgBEEEaiEEIApBBGshCiAIQQFrIggNAAsMAQsgCiADQcS0wAAQpQMACyADIAUgC2wiBEkNAiADIARrIgNFBEBBASEYIAYgC00NBCAGIAtrIgIgASgCuAEgAUHAAWoiAygCACIEa0sEQCABQbgBaiAEIAIQrAEgAygCACEECyABQbwBaigCACAEaiAHIAtqIAIQ0AMaIAMgAiAEajYCAAwECyAHRSAQQQFHckUEQCAGED0LIAIgBGohAiAMIAEQWSAMLQAAIhBBC0cNAAsLIAwpAgQhGSAAIAxBDGooAgA2AgggACAZNwIADAILIAQgA0HUtMAAEKQDAAsgAEECNgIAIAAgGDoABCAHRSAQQQFHcg0AIAYQPQsgDEEQaiQAC4RIAh1/AX4jAEHQAGsiCSQAAkACQAJAAkAgAAJ/AkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQCABKAKgAyIWBEAgAUHIA2oiAygCACEIIANBADYCACABQcQDaigCACEOIAFBwANqIgMoAgAhBSADQoCAgIAQNwMAIAlBOGogARA4AkAgCSgCOEUEQCAJIAlBxQBqKAAANgIwIAkgCUHIAGooAAA2ADMgCUHMAGooAgAhHSAJQcQAai0AACIDQQJHBEAgDiAJKQI8Ih+nIB9CIIinIgcgCCAHIAhJGxDQAxogByAISw0EIAkgCSgAMzYAKyAJIAkoAjA2AiggAyEYCyAJIAkoACs2ACMgCSAJKAIoNgIgIAEoAsADBEAgAUHEA2ooAgAQPQsgASAFNgLAAyABQcgDaiAINgIAIAFBxANqIA42AgAgA0ECRg0FIAFBQGsoAgBBAkYNBCABQfgBai0AACETIAEoAhAhBSABLQD5ASEDIBhBAXEEQCAJIAEgHRCWASAJKAIARQ0HIAkoAgQiCCABQcgDaigCACIHSw0IIAFBxANqKAIAIQ4LIBZBEHENAQwOCyAJQRxqIAlBzABqKAIANgIAIAlBFGogCUHEAGotAAA6AAAgCSAJQcgAaigAADYAMyAJIAlBxQBqKAAANgIwIAlBFWogCSgCMDYAACAJQRhqIAkoADM2AAAgCSAJKQI8NwIMDAsLIAFBEGohBwJAAkACQCADQQdxDgUCDwoBAA8LIBNBB0sNDgwLCyABKAJAQQJGDQkgCUE4aiEQQQAhBSMAQaABayICJAACQAJAIAcoAhBBAkYiA0UEQCAHLQDoASIBQRBHDQEgEEEDOgACIBBBjyA7AQAMAgsgEEEOOgAADAELQQAgB0EQaiADGyENIAJBADoAFiACQQA6ABUgAkEAOgAUAkAgBygCACIDQQJHBEAgDUEIQQQgDSgCABtqQQRqKAIAIAdBBGooAgAhDCAHQQxqKAIAIQQgB0EIaigCACEHIAIgAToAFyAIQQRJDQFBA24iBiAEIAcgAxsiD0khBCAIQQJ2IAFsIgtBA3YgC0EHcSILQQBHaiEKIAsEQEEIIAtrIAFuIQULQcyKwQAgByAMIAMbIAQbIREgAkEBOgCEASACQQA6AIABIAJBADYCeCACQoCAgIAwNwNwIAJCADcDaCACIAo2AmAgAkEANgJcIAJBAjoASCACQQI6ACggAiAFNgIYIAIgCEEEazYCfCAGIA9PIRJBfyABdEF/cyEUIAIgAkEXajYCZCACQcwAaiEMIAJBLGohByACQTxqIRUgAkHkAGohGSACQdwAaiEXIAJBGGpBBHIhCyANQQhqIRogDUEMaiEeQQIhBgJAA0ACQCAFRQ0AIAJBADYCGCAGQQJHBEAgBkUhAUEAIQMgAigCHCEEIAIoAiQhGyACKAIgIQYCQANAAkACQCABQQFxRQRAIAJBADoAKCAEIAZIDQFBASEBDAQLIAQgG2oiCiAETiEcQQEhASACIApBAWoiBCAGIBwgBiAKSnEiChs2AhwgCg0BDAMLIAIgBEEBaiIENgIcC0EBIQEgBSADQQFqIgNHDQALQQAhASAFIQMLIAFFDQEgBSADayEFCyACQQI6ACggAigCZARAIAIgGTYCkAEgAiALNgKMASACIAJBmAFqNgKIASACQQhqIBcgBSACQYgBahCFASACKAIIDQEgAigCDCEFCyACQQI6ACggAi0ASCIBQQJHBEACQCAFRQRAQQAhA0EAIQEMAQsgAUUhAUEAIQMgAigCPCEEIAIoAkQhGyACKAJAIQYDQAJAAkAgAUEBcUUEQCACQQA6AEggBCAGSA0BQQEhAQwECyAEIBtqIgogBE4hHEEBIQEgAiAKQQFqIgQgBiAcIAYgCkpxIgobNgI8IAoNAQwDCyACIARBAWoiBDYCPAtBASEBIAUgA0EBaiIDRw0AC0EAIQEgBSEDCyABRQ0BIAUgA2shBQsgAkECOgBIIAUNBAsgAi0AKCEEAkACQAJAIAIoAmQiAwRAIAIoAlwhBQNAIARB/wFxIgRBAkYiAUUEQEEAIAsgARshAQJAIAQEQEEAIQYgAkEAOgAoIAEoAgAiBCACKAIgTg0BIAshAyAHIQEMBgsgASABKAIAIgEgAigCJGoiBEEBaiACKAIgIgYgBCAGSCABIARMcSIBGzYCACABRQ0AQQAhBiAHIQEMBgsgAkECOgAoCyAFIAIoAmAiAU8NAiACIAFBAWsiATYCYCADLQAAIgZFDRsgAkEANgI4IAJCADcDMCACIAE2AixBASEEIAJBAToAKCACQoCAgICAATcCHCACIAZBAWs2AiQMAAsACyAEQf8BcSIBQQJGIgMNAEEAIAsgAxshBQJAIAEEQEEAIQYgAkEAOgAoIAshAyAHIQEgBSgCACIEIAIoAiBODQEMAwsgBSAFKAIAIgEgAigCJGoiBEEBaiACKAIgIgMgASAETCADIARKcSIDGzYCAEEAIQYgByEBIAMNAwsgAkECOgAoCyACLQBIIgFBAkYiAw0FQQAgFSADGyEDIAEEQCACQQA6AEhBAiEGIAwhASADKAIAIgQgAigCQE4NBgwBCyADIAMoAgAiASACKAJEaiIEQQFqIAIoAkAiAyABIARMIAMgBEpxIgMbNgIAQQIhBiAMIQEgA0UNBQwBCyADIARBAWo2AgALIAEoAgAhCgJAAkAgAi0AhAFFBEAgAi0AgAENBiACKAJ4IgEgAigCfCIDSw0GIAMgAigCdCIFSQ0GAkBBfyADIAVrIgMgAUcgASADSxtB/wFxDgICAAcLIAIgA0EBazYCfAwCCyACQQA6AIQBIAItAIABDQUgAigCeCIBIAIoAnwiA0sNBSABIANPBEAgAkEBOgCAAQwCCyACIANBAWs2AnwMAQsgAkEBOgCAASACIAM2AnwLIAggCksEQCADQQRqIQEgA0F7Sw0ZIAEgCEsNAiADIA5qIgMgCiAOai0AACAUIARBB3EiAXRxIAF2IgVBA2wiASAaKAIAIgQgDSgCBCANKAIAIgobakEAIAFBA2ogHigCACAEIAobTRsiASACQRZqIAEbLQAAOgAAIAMgAUEBaiACQRVqIAEbLQAAOgABIAMgAUECaiACQRRqIAEbLQAAOgACIANBzIrBACAFIBFqIAUgD08bQcyKwQAgEhstAAA6AAMgAigCGCEFDAELCwwWCwwXCyACIAE6ABcgCEEDSQ0AIAhBA24gAWwiA0EDdiADQQdxIgNBAEdqIQcgAwRAQQggA2sgAW4hBQsgAkEBOgCEASACQQA6AIABIAJBADYCeCACQoCAgIAgNwNwIAJCADcDaCACIAc2AmAgAkEANgJcIAJBAjoASCACQQI6ACggAiAFNgIYIAIgCEEDazYCfEF/IAF0QX9zIQ8gAiACQRdqNgJkIAJBzABqIQwgAkEsaiEHIAJBPGohESACQeQAaiESIAJB3ABqIRQgAkEYakEEciELIA1BCGohFSANQQxqIRlBAiEGAkADQAJAIAVFDQAgAkEANgIYIAZBAkcEQCAGRSEBQQAhAyACKAIcIQQgAigCJCEXIAIoAiAhBgJAA0ACQAJAIAFBAXFFBEAgAkEAOgAoIAQgBkgNAUEBIQEMBAsgBCAXaiIKIAROIRpBASEBIAIgCkEBaiIEIAYgGiAGIApKcSIKGzYCHCAKDQEMAwsgAiAEQQFqIgQ2AhwLQQEhASAFIANBAWoiA0cNAAtBACEBIAUhAwsgAUUNASAFIANrIQULIAJBAjoAKCACKAJkBEAgAiASNgKQASACIAs2AowBIAIgAkGYAWo2AogBIAIgFCAFIAJBiAFqEIUBIAIoAgANASACKAIEIQULIAJBAjoAKCACLQBIIgFBAkcEQAJAIAVFBEBBACEDQQAhAQwBCyABRSEBQQAhAyACKAI8IQQgAigCRCEXIAIoAkAhBgNAAkACQCABQQFxRQRAIAJBADoASCAEIAZIDQFBASEBDAQLIAQgF2oiCiAETiEaQQEhASACIApBAWoiBCAGIBogBiAKSnEiChs2AjwgCg0BDAMLIAIgBEEBaiIENgI8C0EBIQEgBSADQQFqIgNHDQALQQAhASAFIQMLIAFFDQEgBSADayEFCyACQQI6AEggBQ0DCyACLQAoIQQCQAJAAkACQCACKAJkIgMEQCACKAJcIQUDQCAEQf8BcSIEQQJGIgFFBEBBACALIAEbIQECQCAEBEBBACEGIAJBADoAKCABKAIAIgQgAigCIE4NASALIQMgByEBDAYLIAEgASgCACIBIAIoAiRqIgRBAWogAigCICIGIAQgBkggASAETHEiARs2AgAgAUUNAEEAIQYgByEBDAcLIAJBAjoAKAsgBSACKAJgIgFPDQIgAiABQQFrIgE2AmAgAy0AACIGRQ0bIAJBADYCOCACQgA3AzAgAiABNgIsQQEhBCACQQE6ACggAkKAgICAgAE3AhwgAiAGQQFrNgIkDAALAAsgBEH/AXEiAUECRiIDDQBBACALIAMbIQUCQCABBEBBACEGIAJBADoAKCALIQMgByEBIAUoAgAiBCACKAIgTg0BDAMLIAUgBSgCACIBIAIoAiRqIgRBAWogAigCICIDIAEgBEwgAyAESnEiAxs2AgBBACEGIAchASADDQQLIAJBAjoAKAsgAi0ASCIBQQJGIgMNBUEAIBEgAxshAyABRQ0BIAJBADoASEECIQYgDCEBIAMoAgAiBCACKAJATg0FCyADIARBAWo2AgAMAQsgAyADKAIAIgEgAigCRGoiBEEBaiACKAJAIgMgASAETCADIARKcSIDGzYCAEECIQYgDCEBIANFDQMLIAEoAgAhBQJAAkAgAi0AhAFFBEAgAi0AgAENBSACKAJ4IgEgAigCfCIDSw0FIAMgAigCdCIKSQ0FAkBBfyADIAprIgMgAUcgASADSxtB/wFxDgICAAYLIAIgA0EBazYCfAwCCyACQQA6AIQBIAItAIABDQQgAigCeCIBIAIoAnwiA0sNBCABIANPBEAgAkEBOgCAAQwCCyACIANBAWs2AnwMAQsgAkEBOgCAASACIAM2AnwLIAUgCEkEQCADQQNqIQEgA0F8Sw0YIAEgCEsNAiADIA5qIgMgBSAOai0AACAPIARBB3EiAXRxIAF2QQNsIgEgFSgCACIFIA0oAgQgDSgCACIEG2pBACABQQNqIBkoAgAgBSAEG00bIgEgAkEWaiABGy0AADoAACADIAFBAWogAkEVaiABGy0AADoAASADIAFBAmogAkEUaiABGy0AADoAAiACKAIYIQUMAQsLIAUgCEGsisEAENgBAAsMFgsgEEEjOgAACyACQaABaiQAIAktADgiAUEjRg0NIAlBHGogCUHIAGooAAA2AAAgCUEVaiAJQcEAaikAADcAACAJIAkpADk3AA0gCSABOgAMQQEhASAJQQE2AggMBwsgE0EISQ0JDAcLIAlBCGogARA4IAkoAgghAQwFCyAJQQA6ADsgCUEAOwA5IAlBrKPAADYCPCAJQQI6ADggCUEIakEEciIBQR86AAAgASAJQThqKQIANwIEDAgLQdyfwABBK0G8osAAEJMCAAsgCUEUakECOgAAQQAhASAJQQA2AggMAgtBiKHAAEEyQayiwAAQqAMACyAIIAdBvKHAABClAwALIAENBCAJQRRqLQAAIRgMBwsgBUECRg0EIAMQ9QIhAyABKAJAQQJGBEBB3J/AAEErQfyhwAAQkwIACyAHKAIAIgVBAkcEQCABQRxqKAIAIAFBGGooAgAiByAFGyEMIAcgAUEUaigCACAFGyEBIBNBCEYEQCADIgtBAWoiAyAISw0HIAEhAgJAAkACQAJAAkAgAwRAIAsEQCAOQQFrIQYgCCADayEHIAtBAWshEyAIIANuIAtsIAtrIQUgCyAMRiERA0ACfyAKBEAgBCAFIBNJciAPIAcgC0lycg0RIAcgC2siB0EBa0EAIAcbIQMgBSATayIFQQFrQQAgBRshASAFRSEEIAdFDAELIAQgD3INECAFQQFrQQAgBRshASAFRSEEIAdFBEBBACEDQQAhB0EBDAELIAdBAWshA0EACyEPIAUgC2oiDCAFSQ0DIAggDEkNBAJAIBFFBEBB/wEhDCAHIAtqIg0gCEkNAQwJCyAHIAtqIQ0gBSAOaiACIAsQzwMEQEH/ASEMIAggDU0NCQwBC0EAIQwgCCANTQ0GCyANIA5qIAw6AAAgBSAGaiENIAVBAWshBSAGIAdqIQwgB0EBayEHQQAhEAJAA0AgBSALaiIKIAhPDQggByALaiIKIAhPDQEgCyAMaiALIA1qLQAAOgAAIA1BAWshDSAFQQFrIQUgDEEBayEMIAdBAWshB0EBIQogCyAQQQFqIhBHDQALIAEhBSADIQcMAQsLIAogCEGMjsEAENgBAAsMEAtBsI3BAEEZQaCNwQAQkwIACyAFIAxBzI3BABCmAwALIAwgCEHMjcEAEKUDAAsgDSAIQdyNwQAQ2AEACyAKIAhB/I3BABDYAQALIA0gCEHsjcEAENgBAAsgASECIAwhCwJAAn8gA0EBdCIMQQJqIgEgCEsNAQJAIAEEQCAMRQ0NIA5BAmshEiAMQQFyIRQgCCABayEHIAxBAWshFSAIIAFuIAxsIAxrIQUCfwNAAn8gBEEBcQRAIAogBSAVSXIgDSAHIBRJcnINByAHIBRrIgdBAWtBACAHGyEDIAUgFWsiBUEBa0EAIAUbIQEgBUUhCiAHRQwBCyAKIA1yDQYgBUEBa0EAIAUbIQEgBUUhCiAHRQRAQQAhA0EAIQdBAQwBCyAHQQFrIQNBAAshDQJAAkACQAJAAkAgBSAFIAxqIgRNBEAgBCAISw0BAkACQCALIAxHBEAgByAMaiIEIAhPDQEMBwsgByALaiEEIAUgDmogAiALEM8DRQ0BIAQgCEkNBgsgBCAIQdyOwQAQ2AEACyAEIAhPDQJBACEGIAQgDmpBADoAACAEQQFqIgQgCE8NAwwFCyAFIARBrI7BABCmAwALIAQgCEGsjsEAEKUDAAsgBCAIQbyOwQAQ2AEACyAEIAhBzI7BABDYAQALQf8BIQYgBCAOakH/AToAACAEQQFqIgQgCEkNACAEIAhB7I7BABDYAQALIAQgDmogBjoAACAFIBJqIQQgByASaiEGQQAhEAJAA0ACQCAIIAUgDGoiD0EBa0sEQCAHIAxqIhFBAWsgCEkNASARQQFrDAULIA9BAWsMBwsgBiAMaiIZQQFqIAQgDGoiF0EBai0AADoAACAPQQJrIAhPDQUgEUECayAITw0BIBkgFy0AADoAACAFQQJrIQUgBEECayEEIAdBAmshByAGQQJrIQYgDCAQQQJqIhBHDQALQQEhBCABIQUgAyEHDAELCyARQQJrCyAIQYyPwQAQ2AEAC0GwjcEAQRlBnI7BABCTAgALIA9BAmsLIAhB/I7BABDYAQALDAULQdyfwABBK0HsocAAEJMCAAtB3J/AAEErQcyhwAAQkwIACyABKAJAQQJGBEBB3J/AAEErQdyhwAAQkwIAC0EAIQUjAEGgAWsiAiQAAkACQEF/IActAOgBIgFBD3F0IgNB/wFxQf8BRwRAQf8BIANBf3MiDUH/AXFuIRAgBygCAEECRg0BIAIgAToAFyAIQQJJDQIgCEEBdiABbCIDQQN2IANBB3EiA0EAR2ohCyADBEBBCCADayABbiEFCyACQQE6AIQBIAJBADoAgAEgAkEANgJ4IAJCgICAgBA3A3AgAkIANwNoIAIgCzYCYCACQQA2AlwgAkECOgBIIAJBAjoAKCACIAU2AhggAiAIQQJrNgJ8IAdBCGooAgAiASAHQQRqKAIAIAcoAgAiAxshEyAHQQxqKAIAIAEgAxshDyACIAJBF2o2AmQgAkHMAGohDCACQSxqIQcgAkE8aiERIAJB5ABqIRYgAkHcAGohEiACQRhqQQRyIQtBAiEGAkADQAJAIAVFDQAgAkEANgIYIAZBAkcEQCAGRSEBQQAhAyACKAIcIQQgAigCJCEUIAIoAiAhBgJAA0ACQAJAIAFBAXFFBEAgAkEAOgAoIAQgBkgNAUEBIQEMBAsgBCAUaiIKIAROIRVBASEBIAIgCkEBaiIEIAYgFSAGIApKcSIKGzYCHCAKDQEMAwsgAiAEQQFqIgQ2AhwLQQEhASAFIANBAWoiA0cNAAtBACEBIAUhAwsgAUUNASAFIANrIQULIAJBAjoAKCACKAJkBEAgAiAWNgKQASACIAs2AowBIAIgAkGYAWo2AogBIAJBCGogEiAFIAJBiAFqEIUBIAIoAggNASACKAIMIQULIAJBAjoAKCACLQBIIgFBAkcEQAJAIAVFBEBBACEDQQAhAQwBCyABRSEBQQAhAyACKAI8IQQgAigCRCEUIAIoAkAhBgNAAkACQCABQQFxRQRAIAJBADoASCAEIAZIDQFBASEBDAQLIAQgFGoiCiAETiEVQQEhASACIApBAWoiBCAGIBUgBiAKSnEiChs2AjwgCg0BDAMLIAIgBEEBaiIENgI8C0EBIQEgBSADQQFqIgNHDQALQQAhASAFIQMLIAFFDQEgBSADayEFCyACQQI6AEggBQ0FCyACLQAoIQQCQAJAAkAgAigCZCIDBEAgAigCXCEFA0AgBEH/AXEiBEECRiIBRQRAQQAgCyABGyEBAkAgBARAQQAhBiACQQA6ACggASgCACIEIAIoAiBODQEgCyEDIAchAQwGCyABIAEoAgAiASACKAIkaiIEQQFqIAIoAiAiBiAEIAZIIAEgBExxIgEbNgIAIAFFDQBBACEGIAchAQwGCyACQQI6ACgLIAUgAigCYCIBTw0CIAIgAUEBayIBNgJgIAMtAAAiBkUNECACQQA2AjggAkIANwMwIAIgATYCLEEBIQQgAkEBOgAoIAJCgICAgIABNwIcIAIgBkEBazYCJAwACwALIARB/wFxIgFBAkYiAw0AQQAgCyADGyEFAkAgAQRAQQAhBiACQQA6ACggCyEDIAchASAFKAIAIgQgAigCIE4NAQwDCyAFIAUoAgAiASACKAIkaiIEQQFqIAIoAiAiAyABIARMIAMgBEpxIgMbNgIAQQAhBiAHIQEgAw0DCyACQQI6ACgLIAItAEgiAUECRiIDDQZBACARIAMbIQMgAQRAIAJBADoASEECIQYgDCEBIAMoAgAiBCACKAJATg0HDAELIAMgAygCACIBIAIoAkRqIgRBAWogAigCQCIDIAEgBEwgAyAESnEiAxs2AgBBAiEGIAwhASADRQ0GDAELIAMgBEEBajYCAAsgASgCACEKAkACQCACLQCEAUUEQCACLQCAAQ0HIAIoAngiASACKAJ8IgNLDQcgAyACKAJ0IgVJDQcCQEF/IAMgBWsiAyABRyABIANLG0H/AXEOAgIACAsgAiADQQFrNgJ8DAILIAJBADoAhAEgAi0AgAENBiACKAJ4IgEgAigCfCIDSw0GIAEgA08EQCACQQE6AIABDAILIAIgA0EBazYCfAwBCyACQQE6AIABIAIgAzYCfAsgCCAKTQ0MIANBAmohASADQX1LDQ0gASAISw0BIA8EQCADIA5qIgEgCiAOai0AACANIARBB3EiA3RxIAN2IgMgEGw6AAAgAUF/QQAgEy0AACADRxs6AAEgAigCGCEFDAELC0EAQQBBvIvBABDYAQALDAwLQZCKwQBBGUGsi8EAEJMCAAsgAiABOgAXIAhFDQAgASAIbCIDQQN2IANBB3EiA0EAR2ohByADBEBBCCADayABbiEFCyACQfAAakIANwMAIAJB+ABqQQA2AgAgAkIANwNoIAIgBzYCYCACQQA2AlwgAkECOgBIIAJBAjoAKCACIAU2AhggAkEBOgCEASACQQA6AIABIAIgCEEBazYCfCACIAJBF2o2AmQgAkHMAGohDCACQSxqIQcgAkE8aiETIAJB5ABqIQ8gAkHcAGohESACQRhqQQRyIQtBAiEGAkACQANAAkAgBUUNACACQQA2AhggBkECRwRAIAZFIQFBACEDIAIoAhwhBCACKAIkIRYgAigCICEGAkADQAJAAkAgAUEBcUUEQCACQQA6ACggBCAGSA0BQQEhAQwECyAEIBZqIgogBE4hEkEBIQEgAiAKQQFqIgQgBiASIAYgCkpxIgobNgIcIAoNAQwDCyACIARBAWoiBDYCHAtBASEBIAUgA0EBaiIDRw0AC0EAIQEgBSEDCyABRQ0BIAUgA2shBQsgAkECOgAoIAIoAmQEQCACIA82ApABIAIgCzYCjAEgAiACQZgBajYCiAEgAiARIAUgAkGIAWoQhQEgAigCAA0BIAIoAgQhBQsgAkECOgAoIAItAEgiAUECRwRAAkAgBUUEQEEAIQNBACEBDAELIAFFIQFBACEDIAIoAjwhBCACKAJEIRYgAigCQCEGA0ACQAJAIAFBAXFFBEAgAkEAOgBIIAQgBkgNAUEBIQEMBAsgBCAWaiIKIAROIRJBASEBIAIgCkEBaiIEIAYgEiAGIApKcSIKGzYCPCAKDQEMAwsgAiAEQQFqIgQ2AjwLQQEhASAFIANBAWoiA0cNAAtBACEBIAUhAwsgAUUNASAFIANrIQULIAJBAjoASCAFDQQLIAItACghBAJAAkACQAJAIAIoAmQiAwRAIAIoAlwhBQNAIARB/wFxIgRBAkYiAUUEQEEAIAsgARshAQJAIAQEQEEAIQYgAkEAOgAoIAEoAgAiBCACKAIgTg0BIAshAyAHIQEMBgsgASABKAIAIgEgAigCJGoiBEEBaiACKAIgIgYgBCAGSCABIARMcSIBGzYCACABRQ0AQQAhBiAHIQEMBwsgAkECOgAoCyAFIAIoAmAiAU8NAiACIAFBAWsiATYCYCADLQAAIgZFDRAgAkEANgI4IAJCADcDMCACIAE2AixBASEEIAJBAToAKCACQoCAgICAATcCHCACIAZBAWs2AiQMAAsACyAEQf8BcSIBQQJGIgMNAEEAIAsgAxshBQJAIAEEQEEAIQYgAkEAOgAoIAshAyAHIQEgBSgCACIEIAIoAiBODQEMAwsgBSAFKAIAIgEgAigCJGoiBEEBaiACKAIgIgMgASAETCADIARKcSIDGzYCAEEAIQYgByEBIAMNBAsgAkECOgAoCyACLQBIIgFBAkYiAw0GQQAgEyADGyEDIAFFDQEgAkEAOgBIQQIhBiAMIQEgAygCACIEIAIoAkBODQYLIAMgBEEBajYCAAwBCyADIAMoAgAiASACKAJEaiIEQQFqIAIoAkAiAyABIARMIAMgBEpxIgMbNgIAQQIhBiAMIQEgA0UNBAsgASgCACEKAkACQCACLQCEAUUEQCACLQCAAQ0GIAIoAngiASACKAJ8IgNLDQYgAyACKAJ0IgVJDQYCQEF/IAMgBWsiAyABRyABIANLG0H/AXEOAgIABwsgAiADQQFrNgJ8DAILIAJBADoAhAEgAi0AgAENBSACKAJ4IgEgAigCfCIDSw0FIAEgA08EQCACQQE6AIABDAILIAIgA0EBazYCfAwBCyACQQE6AIABIAIgAzYCfAsgCCAKSwRAIANBAWoiAUUNAiABIAhLDQMgAyAOaiAKIA5qLQAAIA0gBEEHcSIBdHEgAXYgEGw6AAAgAigCGCEFDAELCwwKC0F/IAFBvIrBABCmAwALDAoLIAJBoAFqJAAMAwsgBUUNACAOED0LIAAgCSkCDDcCBCAAQRRqIAlBHGooAgA2AgAgAEEMaiAJQRRqKQIANwIAQQEMAwsgFkEBcUUgE0EQR3INACAIQQF2IQMgCEECSQRAIAMhCAwBC0EBIAMgA0EBTRshB0EAIQFBACEFAkACQANAIAEgCE8NAiAFIAhGDQEgBSAOaiABIA5qLQAAOgAAIAFBAmohASAFQQFqIgUgB0cNAAsgAyEIDAILIAggCEGcosAAENgBAAsgASAIQYyiwAAQ2AEACyAJQRhqIAkoACM2AAAgCUEVaiAJKAIgNgAAIAlBHGogHTYCACAJQRRqIBg6AAAgCUEQaiAINgIAIAkgDjYCDAsgGEH/AXFBAkYEQCAAQQxqQQI6AABBAAwBCyAAIAkpAgw3AgQgAEEUaiAJQRxqKAIANgIAIABBDGogCUEUaikCADcCAEEACzYCACAJQdAAaiQADwtBpILBAEEbQZiDwQAQkwIACyAKIAhBrIrBABDYAQALIAMgAUG8isEAEKYDAAsgASAIQbyKwQAQpQMAC/8OAgd/An4jAEGQAWsiAyQAAkACQAJAAkACQCACRQRAIAFBQGsoAgBBAkcNAUHcn8AAQStBmKDAABCTAgALIAFBQGsoAgBBAkYNBCADQSBqIgQgAUEQaiICLQDpAUEEc0EHcUEDdEHY/sAAaikDACACNQJAIAIxAOgBfn4iCkLx/////wBUNgIAIAQgCkIHfEIDiKdBAWo2AgQCQCADKAIgQQFHDQAgASgCQEECRg0FIANBGGogAhC8AyADKAIcIQIgAygCGCEEIANBEGogARCSASADQQhqIAMtABAgAy0AESAEEJcCIAMoAghFDQAgAygCDEEBa60gAq1+QiCIUA0CCyAAQSI6AAAMAwsgAUEQahDwAiECIAEoApADIgRBAkEBIAIbRgRAIAIEQCABQZQDaigCACABKAKYA0EBa0cNAgsgAUHQA2ooAgAhBCABKALMAyECIANBMGogARCSASADLQAxIQUgAy0AMCEGIANBKGogARCSASADLQAoIAMtACkgAhDUASEBIABBEWogBjoAACAAQRBqIAU6AAAgAEEIaiAENgIAIAAgAjYCBCAAQSM6AAAgAEEMaiABQQFrNgIADAMLIARBA0YNAQsgA0EANgJYIANCgICAgBA3A1AgA0HgAGogASADQdAAahBSIANB6ABqIQYCQCADLQB5IgJBDkcEQCABQcwDaiEEIAFBEGohBQNAIAJB/wFxIgdBDUYEQCADQQY6AGAgACADQeAAahC9AgwDCwJAAkACQAJAAkBBBiACQQJrIAdBAU0bQf8BcUECaw4FAAQEBAEECyADLQBnIQIgAy0AZiEHIAMtAGUhCCADLQBkIglByQBGDQEgCUHmAEcgCEHkAEdyIAdBwQBHIAJB1ABHcnINAwwCCyABKAJAQQJGDQggA0HgAGogBRBqIARBKGogA0GIAWooAgA2AgAgBEEgaiADQYABaikDADcCACAEQRhqIANB+ABqKQMANwIAIARBEGogA0HwAGopAwA3AgAgBEEIaiAGKQMANwIAIAQgAykDYDcCACABQQI2ApADIAEgASgCmAMiAjYClAMgASACQQFqNgKYAwwCCyAIQcQARyAHQcEAR3IgAkHUAEdyDQELIAMoAlAEQCADKAJUED0LIAEoAkBBAkYEQCADQQQ6AGAgACADQeAAahC9AgwGCyABAn8gBS0A6QFBBHNBB3FBAnRBmP/AAGooAgAgBS0A6AFBB2pB+AFxQQN2bEEBayICQQhPQa8BIAJ2QQFxRXJFBEBCgYSMoJDAwYAIIAKtQgOGiKcMAQsjAEEgayIAJAAgAEEMakEBNgIAIABBFGpBATYCACAAQcz3wAA2AgggAEEANgIAIABBzgE2AhwgAEGE+cAANgIYIAAgAEEYajYCECAAQYz5wAAQrAIACzoA+AMgA0HgAGogBRBqIARBKGogA0GIAWooAgA2AgAgBEEgaiADQYABaikDADcCACAEQRhqIANB+ABqKQMANwIAIARBEGogA0HwAGopAwA3AgAgBEEIaiADQegAaikDADcCACAEIAMpA2A3AgAgASgCpAMhAiADIAEgASgCzAMQlgECQCADKAIAQQFHDQAgAiADKAIEIgZJDQACQCAGIAFBwANqIgUoAggiBE0EQCAFIAY2AggMAQsgBiAEIgJrIgcgBSgCACACa0sEQCAFIAQgBxCsASAFKAIIIQILIAUoAgQiCSACaiEIAkACQCAHQQJPBEAgCEEAIAdBAWsiBBDOAxogCSACIARqIgJqIQgMAQsgBCAGRg0BCyAIQQA6AAAgAkEBaiECCyAFIAI2AggLIANB4ABqIQQCQAJAAkACQCABQdQDaigCACICRQRAIARBATYCBAwBCyACQQBOIgVFDQEgAiAFEI0DIgZFDQIgBCAGNgIECyAEIAI2AgAgBCACNgIIDAILEKACAAsgAiAFEMoDAAsgASgCqAMEQCABQawDaigCABA9CyABQagDaiICIAMpA2A3AgAgAkEIaiADQegAaigCADYCACMAQRBrIgIkACABQdADaigCACEFIAEoAswDIQQgAkEIaiABEJIBIAItAAkhBiACLQAIIQcgAiABEJIBIAItAAAgAi0AASAEENQBIQggAEEEaiIBIAc6AA0gASAFNgIEIAEgBDYCACABIAY6AAwgASAIQQFrNgIIIAJBEGokACAAQSM6AAAMBgsgAEEiOgAADAULIAMoAlAEQCADKAJUED0LIANBADYCWCADQoCAgIAQNwNQIANB4ABqIAEgA0HQAGoQUiADLQB5IgJBDkcNAAsL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KAIAIgRB/////wNxIARHDQAgBTUCBCAEQQJ0rX4iGUIgiKcNACAZpyIGIAVBEGooAgAiB0sNASADIAQ2AgggA0IANwIAIANBGGpCgICAgMAANwIAIANBEGogBjYCACADIAVBDGooAgAiBTYCDCADQRRqIAUgBmo2AgAMAgtBmInAAEErQbCKwAAQkwIACyAGIAdBoIrAABClAwALAkACQAJAAkACQCACKAKQASIDIAIoApwBIgVJDQAgAigCjAEhBiAFQQRGBEAgAi0AKCEMIAIoAoABIgRBACAEIAIoAogBIgdJGyEFIAIoAoQBIAQgB09qIQQgAUGMAmohCiABQZACaiELA0AgBkUNAiABKAKAAiIIIAVNIAEoAoQCIgkgBE1yDQQgBCAIbCAFakECdCIJQQRqIQggCUF8Rg0FIAggCygCACINSw0GIAwgCigCACAJaiAGELQCIAVBAWoiCEEAIAcgCEsbIQUgBCAHIAhNaiEEIAZBBGohBiADQQRrIgNBBE8NAAsMAQsgBg0BCyACQZABaiACQUBrKAIANgIAIAJBiAFqIAJBOGopAwA3AwAgAiACKQMwNwOAASAAQQRqIAJBgAFqQQBBACACKAIQIAIoAhQQmwIgAEEGNgIADAgLIAIgBTYCoAEgAkEANgKIAUEAIAJBoAFqQYCdwAAgAkGAAWpBhJ3AABDmAQALIAJBrAFqQQU2AgAgAkGMAWpBAjYCACACQZQBakECNgIAIAIgBDYCXCACIAU2AlggAkGAu8AANgKIASACQQA2AoABIAJBBTYCpAEgAiAJNgJMIAIgCDYCSCACIAJBoAFqNgKQASACIAJByABqNgKoASACIAJB2ABqNgKgASACQYABakGQu8AAEKwCAAtBfCAIQdS6wAAQpgMACyAIIA1B1LrAABClAwALIAJBiAFqIAJB8ABqKAIANgIAIAIgAikDaDcDgAEgACACQYABahDeASAIRQ0DIAUQPQwDCyACQYgBaiACQfAAaigCADYCACACIAIpA2g3A4ABIAAgAkGAAWoQ3gEMAgsQoAIACyAIIAMQygMACyACQbABaiQADwtBDEEEEMoDAAv2OgMcfw98An4jAEHQAGsiDiQAIAEtAPgDIQICQAJAAkACQAJAAkACQAJAAkACQAJAAkACQCABQdgDaigCAEUEQCABKALcAyIEIAFB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IBdBA2otAAAiAiACIAlqIANrIhAgAmsiAiACQRB0QR91IgJzIAJrQf//A3EiBiAQIANrIgIgAkEQdEEfdSICcyACa0H//wNxIhFLGyIDIBAgCWsiAiACQRB0QR91IgJzIAJrQf//A3EiAiARTRsgAyACIAZNG2o6AAAgGEEERg0AIBRBBGoiAiACLQAAIBVBBGotAAAiCSAWQQRqLQAAIgMgF0EEai0AACICIAIgCWogA2siECACayICIAJBEHRBH3UiAnMgAmtB//8DcSIGIBAgA2siAiACQRB0QR91IgJzIAJrQf//A3EiEUsbIgMgECAJayICIAJBEHRBH3UiAnMgAmtB//8DcSICIBFNGyADIAIgBk0bajoAACAYQQVGDQAgFEEFaiICIAItAAAgFUEFai0AACIJIBZBBWotAAAiAyAXQQVqLQAAIgIgAiAJaiADayIQIAJrIgIgAkEQdEEfdSICcyACa0H//wNxIgYgECADayICIAJBEHRBH3UiAnMgAmtB//8DcSIRSxsiAyAQIAlrIgIgAkEQdEEfdSICcyACa0H//wNxIgIgEU0bIAMgAiAGTRtqOgAAIBhBBkYNACAUQQZqIgIgAi0AACAVQQZqLQAAIgkgFkEGai0AACIDIBdBBmotAAAiAiACIAlqIANrIhAgAmsiAiACQRB0QR91IgJzIAJrQf//A3EiBiAQIANrIgIgAkEQdEEfdSICcyACa0H//wNxIhFLGyIDIBAgCWsiAiACQRB0QR91IgJzIAJrQf//A3EiAiARTRsgAyACIAZNG2o6AAAgGEEHRg0AIBRBB2oiAiACLQAAIBVBB2otAAAiCSAWQQdqLQAAIgMgF0EHai0AACICIAIgCWogA2siECACayICIAJBEHRBH3UiAnMgAmtB//8DcSIGIBAgA2siAiACQRB0QR91IgJzIAJrQf//A3EiEUsbIgMgECAJayICIAJBEHRBH3UiAnMgAmtB//8DcSICIBFNGyADIAIgBk0bajoAAAsgCiASaiEKQQAhECASIBwgEmsiHE0NAAsMBgsgByAHLQAAIA0tAABBAXZqOgAAAkAgAkH/AXFBAUYNACAEQQFGDQQgByAHLQABIA0tAAFBAXZqOgABIAJB/wFxQQJGDQAgBEECRg0EIAcgBy0AAiANLQACQQF2ajoAAiACQf8BcUEDRg0AIARBA0YNBCAHIActAAMgDS0AA0EBdmo6AAMgAkH/AXFBBEYNACAEQQRGDQQgByAHLQAEIA0tAARBAXZqOgAEIAJB/wFxQQVGDQAgBEEFRg0EIAcgBy0ABSANLQAFQQF2ajoABSACQf8BcUEGRg0AIARBBkYNBCAHIActAAYgDS0ABkEBdmo6AAYgAkH/AXFBB0YNACAEQQdGDQQgByAHLQAHIA0tAAdBAXZqOgAHCwJAAkACQAJAAkACQAJAIAJBD3FBAmsOBwIDBAAFAAYBCwALAkAgBARAIARBAWsiCEUNASAHLQAAIQkgCEEBcQRAIAcgBy0AASANLQABIAlB/wFxakEBdmoiCToAASANQQFqIQ0gB0EBaiEHIARBAmshCAsgBEECRg0BIAdBAmohCiANQQJqIQcDQCAKQQFrIgIgAi0AACAHQQFrLQAAIAlB/wFxakEBdmoiAjoAACAKIAotAAAgBy0AACACQf8BcWpBAXZqIgk6AAAgCkECaiEKIAdBAmohByAIQQJrIggNAAsMAQtB0ITBAEErQbCGwQAQkwIACwwKCwJAIARBfnEiAgRAIAJBAkcEQCAHQQNqIQpBAiACayEJIA1BA2ohCCAHLQAAIQ0DQCAKQQFrIgIgAi0AACAIQQFrLQAAIA1B/wFxakEBdmoiDToAACAKIAotAAAgCC0AACAKQQJrLQAAakEBdmo6AAAgCkECaiEKIAhBAmohCCAJQQJqIgkNAAsLDAELQdCEwQBBK0GghsEAEJMCAAsMCQsCQCAEIARBA3BrIgJBA08EQCACQQNrIglBA08EQCAHLQAAIQsDQCAHIApqIgZBA2oiAiACLQAAIAogDWoiA0EDai0AACALQf8BcWpBAXZqIgs6AAAgBkEEaiICIAItAAAgA0EEai0AACAGQQFqLQAAakEBdmo6AAAgBkEFaiICIAItAAAgA0EFai0AACAGQQJqLQAAakEBdmo6AAAgCkEDaiEKIAlBA2siCUECSw0ACwsMAQtB0ITBAEErQZCGwQAQkwIACwwICwJAIARBfHEiAgRAIAJBBGsiAwRAIActAAAhC0EAIQgDQCAHIAhqIgVBBGoiAiACLQAAIAggDWoiBkEEai0AACALQf8BcWpBAXZqIgs6AAAgBUEFaiICIAItAAAgBkEFai0AACAFQQFqLQAAakEBdmo6AAAgBUEGaiICIAItAAAgBkEGai0AACAFQQJqLQAAakEBdmo6AAAgBUEHaiICIAItAAAgBkEHai0AACAFQQNqLQAAakEBdmo6AAAgAyAIQQRqIghHDQALCwwBC0HQhMEAQStBgIbBABCTAgALDAcLAkAgBCAEQQZwayICQQZPBEAgAkEGayILQQZPBEAgBy0AACESA0AgByAJaiIGQQZqIgIgAi0AACAJIA1qIgNBBmotAAAgEkH/AXFqQQF2aiISOgAAIAZBB2oiAiACLQAAIANBB2otAAAgBkEBai0AAGpBAXZqOgAAIAZBCGoiAiACLQAAIANBCGotAAAgBkECai0AAGpBAXZqOgAAIAZBCWoiAiACLQAAIANBCWotAAAgBkEDai0AAGpBAXZqOgAAIAZBCmoiAiACLQAAIANBCmotAAAgBkEEai0AAGpBAXZqOgAAIAZBC2oiAiACLQAAIANBC2otAAAgBkEFai0AAGpBAXZqOgAAIAlBBmohCSALQQZrIgtBBUsNAAsLDAELQdCEwQBBK0HwhcEAEJMCAAsMBgsCQCAEQXhxIgIEQCACQQhrIgMEQCAHLQAAIQsDQCAHIAlqIgVBCGoiAiACLQAAIAkgDWoiBkEIai0AACALQf8BcWpBAXZqIgs6AAAgBUEJaiICIAItAAAgBkEJai0AACAFQQFqLQAAakEBdmo6AAAgBUEKaiICIAItAAAgBkEKai0AACAFQQJqLQAAakEBdmo6AAAgBUELaiICIAItAAAgBkELai0AACAFQQNqLQAAakEBdmo6AAAgBUEMaiICIAItAAAgBkEMai0AACAFQQRqLQAAakEBdmo6AAAgBUENaiICIAItAAAgBkENai0AACAFQQVqLQAAakEBdmo6AAAgBUEOaiICIAItAAAgBkEOai0AACAFQQZqLQAAakEBdmo6AAAgBUEPaiICIAItAAAgBkEPai0AACAFQQdqLQAAakEBdmo6AAAgAyAJQQhqIglHDQALCwwBC0HQhMEAQStB4IXBABCTAgALDAULIAQgBEHAhMEAENgBAAtB0ITBAEErQfyEwQAQkwIACyAKIARBnIXBABDYAQALIAQgBEGMhcEAENgBAAtBrIXBACEQQTEhEQsgGyARNgIEIBsgEDYCACAOKAIIIgIEQCAOKAIMIQEgDiACNgI0IA5BHToAMCAOIAE2AjggAEEEaiAOQTBqEL0CIABBATYCAAwBCyAPIAFBsANqIgMoAgAiAksNBiABQawDaiICKAIAIBogDxDQAxogASABKAKcAyAPajYCnAMgDyADKAIAIgFLDQcgAEEANgIAIABBFGogGTYCACAAQRBqIBM2AgAgAEENaiAMOgAAIABBDGogHToAACAAQQhqIAQ2AgAgACACKAIAQQFqNgIECyAOQdAAaiQADwsgBSALQaigwAAQpAMAC0EAQQBBuKDAABDYAQALQQFBAEHIoMAAEKYDAAsgDyAEQcigwAAQpQMACyAPIARB2KDAABClAwALIA8gAkHooMAAEKUDAAsgDyABQfigwAAQpQMAC44KAQF/IwBBMGsiAiQAAn8CQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkAgAC0AAEEBaw4RAQIDBAUGBwgJCgsMDQ4PEBEACyACIAAtAAE6AAggAkEkakECNgIAIAJBLGpBATYCACACQcTAwAA2AiAgAkEANgIYIAJB4gA2AhQgAiACQRBqNgIoIAIgAkEIajYCECABIAJBGGoQ8wEMEQsgAiAAKQMINwMIIAJBJGpBAjYCACACQSxqQQE2AgAgAkGowMAANgIgIAJBADYCGCACQeMANgIUIAIgAkEQajYCKCACIAJBCGo2AhAgASACQRhqEPMBDBALIAIgACkDCDcDCCACQSRqQQI2AgAgAkEsakEBNgIAIAJBqMDAADYCICACQQA2AhggAkHkADYCFCACIAJBEGo2AiggAiACQQhqNgIQIAEgAkEYahDzAQwPCyACIAArAwg5AwggAkEkakECNgIAIAJBLGpBATYCACACQYzAwAA2AiAgAkEANgIYIAJB5QA2AhQgAiACQRBqNgIoIAIgAkEIajYCECABIAJBGGoQ8wEMDgsgAiAAKAIENgIIIAJBJGpBAjYCACACQSxqQQE2AgAgAkHsv8AANgIgIAJBADYCGCACQeYANgIUIAIgAkEQajYCKCACIAJBCGo2AhAgASACQRhqEPMBDA0LIAIgACkCBDcDCCACQSRqQQE2AgAgAkEsakEBNgIAIAJB2L/AADYCICACQQA2AhggAkHnADYCFCACIAJBEGo2AiggAiACQQhqNgIQIAEgAkEYahDzAQwMCyACQSRqQQE2AgAgAkEsakEANgIAIAJByL/AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwLCyACQSRqQQE2AgAgAkEsakEANgIAIAJBtL/AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwKCyACQSRqQQE2AgAgAkEsakEANgIAIAJBoL/AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwJCyACQSRqQQE2AgAgAkEsakEANgIAIAJBjL/AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwICyACQSRqQQE2AgAgAkEsakEANgIAIAJB9L7AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwHCyACQSRqQQE2AgAgAkEsakEANgIAIAJB5L7AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwGCyACQSRqQQE2AgAgAkEsakEANgIAIAJB2L7AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwFCyACQSRqQQE2AgAgAkEsakEANgIAIAJBzL7AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwECyACQSRqQQE2AgAgAkEsakEANgIAIAJBuL7AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwDCyACQSRqQQE2AgAgAkEsakEANgIAIAJBoL7AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwCCyACQSRqQQE2AgAgAkEsakEANgIAIAJBiL7AADYCICACQfi9wAA2AiggAkEANgIYIAEgAkEYahDzAQwBCyABIAAoAgQgAEEIaigCABCFAwsgAkEwaiQAC5gJAxV/A30BfiMAQSBrIgUkAAJAIABBCGooAgAiBEUNACAFQQhqIABBBGooAgAiCxC0AyAFIAUoAgggBSgCDBCQAyAFKAIAsyAFKAIEs5RDAAAgQZUiFyABXw0AAn8CQAJAAkACQAJAAkAgBEHj8bgcSw0AIARBJGwiB0EASA0AIARB5PG4HElBAnQhAiAHBH8gByACEIwDBSACCyIMRQ0DIAUgDDYCFCAFIAQ2AhAgCyAEQSRsIgZqIREgBCEHIAshAgNAIAYgCkcEQCAHRQ0DIAJBHGooAgAhCCACKAIMIQ0gAigCCCEOIAIo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KAIAIAEoAggiA0YEQCABIANBARCsASABKAIIIQMLIAEgA0EBajYCCCABKAIEIANqQSE6AAAgBQRAIAJBBGovAQAhBSACLwECAn8gBCgCACIBKAIAIAEoAggiA0cEQCABDAELIAEgA0EBEKwBIAEoAgghAyAEKAIACyECIAEgA0EBajYCCCABKAIEIANqQf8BOgAAIAIoAggiAyACKAIARwR/IAIFIAIgA0EBEKwBIAIoAgghAyAEKAIACyEBIAIgA0EBajYCCCACKAIEIANqQQs6AAAgASgCACABKAIIIgJrQQpNBEAgASACQQsQrAEgASgCCCECCyABIAJBC2o2AgggASgCBCACaiIBQbukwAApAAA3AAAgAUEHakHCpMAAKAAANgAAAn8gBCgCACIBKAIAIAEoAggiA0cEQCABDAELIAEgA0EBEKwBIAEoAgghAyAEKAIACyECIAEgA0EBajYCCCABKAIEIANqQQM6AAAgAigCCCIBIAIoAgBGBEAgAiABQQEQrAEgAigCCCEBCyACIAFBAWo2AgggAigCBCABakEBOgAABEAgBCgCACICKAIAIAIoAggiAWtBAU0EQCACIAFBAhCsASACKAIIIQELIAIgAUECajYCCCACKAIEIAFqQQA7AAAMAwsgBCgCACICKAIAIAIoAggiAWtBAU0EQCACIAFBAhCsASACKAIIIQELIAIgAUECajYCCCACKAIEIAFqIgEgBUGA/gNxQQh2OgABIAEgBToAAAwCCyACLQACIQYgAi8BBCEFIAItAAEhBwJ/IAQoAgAiASgCACABKAIIIgNHBEAgAQwBCyABIANBARCsASABKAIIIQMgBCgCAAshAiABIANBAWo2AgggASgCBCADakH5AToAACACKAIIIgMgAigCAEcEfyACBSACIANBARCsASACKAIIIQMgBCgCAAshASACIANBAWo2AgggAigCBCADakEEOgAAIAEoAggiAiABKAIARgRAIAEgAkEBEKwBIAEoAgghAgsgASACQQFqNgIIIAEoAgQgAmogBzoAACAFQYD+A3FBCHYhBwJ/IAQoAgAiASgCACABKAIIIgNrQQFLBEAgAQwBCyABIANBAhCsASABKAIIIQMgBCgCAAshAiABIANBAmo2AgggASgCBCADaiIBIAc6AAEgASAFOgAAIAIoAggiASACKAIA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IwBBMGsiASQAAn8CQCAAQQRqIgQoAhBFBEAgBC0AAEEDRw0BIAFBFGpBATYCACABQRxqQQA2AgAgAUGMz8AANgIQIAFByMnAADYCGCABQQA2AgggAiABQQhqEPMBDAILIAEgBEEQajYCBCABQRRqQQI2AgAgAUEcakECNgIAIAFBLGpBjQE2AgAgAUHozsAANgIQIAFBADYCCCABQYwBNgIkIAEgBDYCICABIAFBIGo2AhggASABQQRqNgIoIAIgAUEIahDzAQwBCyABQRRqQQE2AgAgAUEcakEBNgIAIAFB+M7AADYCECABQQA2AgggAUGMATYCJCABIAQ2AiAgASABQSBqNgIYIAIgAUEIahDzAQsgAUEwaiQADAULIABBBGohASAAQRRqIgQoAgBFBEAgA0EkakEBNgIAIANBLGpBATYCACADQcjOwAA2AiAgA0EANgIYIANBjAE2AgwgAyABNgIIIAMgA0EIajYCKCACIANBGGoQ8wEMBQsgAyAENgIEIANBJGpBAjYCACADQSxqQQI2AgAgA0EUakGNATYCACADQbjOwAA2AiAgA0EANgIYIANBjAE2AgwgAyABNgIIIAMgA0EIajYCKCADIANBBGo2AhAgAiADQRhqEPMBDAQLIwBBMGsiASQAAkACQAJAAkACQAJAIABBBGoiBigCAEEBaw4DAAECAwtBASEEIAFBHGpBATYCACABQSRqQQA2AgAgAUHMzcAANgIYIAFByMnAADYCICABQQA2AhAgAiABQRBqEPMBRQ0DDAQLIAEgBkEEajYCDEEBIQQgAUEcakEBNgIAIAFBJGpBATYCACABQYDNwAA2AhggAUEANgIQIAFBigE2AiwgASABQShqNgIgIAEgAUEMajYCKCACIAFBEGoQ8wFFDQIMAwtBASEEIAFBHGpBATYCACABQSRqQQA2AgAgAUHczMAANgIYIAFByMnAADYCICABQQA2AhAgAiABQRBqEPMBRQ0BDAILQQEhBCABQRxqQQE2AgAgAUEkakEANgIAIAFBjM7AADYCGCABQcjJwAA2AiAgAUEANgIQIAIgAUEQahDzAQ0BCyAGKAIQRQRAQQAhBAwBCyABIAZBEGo2AgwgAUEcakEBNgIAIAFBJGpBATYCACABQZjOwAA2AhggAUEANgIQIAFBjQE2AiwgASABQShqNgIgIAEgAUEMajYCKCACIAFBEGoQ8wEhBAsgAUEwaiQAIAQMAwsCQAJAAkBBAiAAKQMIIgenQQJrIAdCAVgbQQFrDgIBAgALIANBJGpBATYCACADQSxqQQA2AgAgA0Gc0MAANgIgIANByMnAADYCKCADQQA2AhggAiADQRhqEPMBDAQLIANBJGpBATYCACADQSxqQQA2AgAgA0GA0MAANgIgIANByMnAADYCKCADQQA2AhggAiADQRhqEPMBDAMLIANBJGpBATYCACADQSxqQQA2AgAgA0Hkz8AANgIgIANByMnAADYCKCADQQA2AhggAiADQRhqEPMBDAILIwBBMGsiASQAAn8CQAJAAkACQAJAAkBBASAAQQRqIgQtAAAiBkEEayAGQQNNG0H/AXFBAWsOAgECAAsgASAEQQFqNgIEIAFBFGpBAzYCACABQRxqQQI2AgAgAUEsakGOATYCACABQZzMwAA2AhAgAUEANgIIIAFBjAE2AiQgASAEQRBqNgIgIAEgAUEgajYCGCABIAFBBGo2AiggAiABQQhqEPMBDAULIAZBAmsOAgIDAQsgASAEQQRqNgIAIAQtABBBA0YEQCABQRRqQQE2AgAgAUEcakEBNgIAIAFBwMrAADYCECABQQA2AgggAUGKATYCJCABIAFBIGo2AhggASABNgIgIAIgAUEIahDzAQwECyABIARBEGo2AgQgAUEUakECNgIAIAFBHGpBAjYCACABQSxqQYoBNgIAIAFBgMrAADYCECABQQA2AgggAUGPATYCJCABIAFBIGo2AhggASABNgIoIAEgAUEEajYCICACIAFBCGoQ8wEMAwsgASAENgIEIAFBFGpBAjYCACABQRxqQQE2AgAgAUHsysAANgIQIAFBADYCCCABQY8BNgIkIAEgAUEgajYCGCABIAFBBGo2AiAgAiABQQhqEPMBDAILIAEgBDYCBCABQRRqQQI2AgAgAUEcakEBNgIAIAFB6MvAADYCECABQQA2AgggAUGPATYCJCABIAFBIGo2AhggASABQQRqNgIgIAIgAUEIahDzAQwBCyABQRRqQQE2AgAgAUEcakEANgIAIAFBpMvAADYCECABQcjJwAA2AhggAUEANgIIIAIgAUEIahDzAQsgAUEwaiQADAELIABBBGogAhBwCyECIANBMGokAAJAAkAgAkUEQCAFKAIEIAUo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aikCACILNwMAIAMgBikCACIMNwMAIABBDGogCzcCACAAIAw3AgQgAEEOOgAZIAAgBDYCAAsgA0FAayQAC/kEAQp/IwBBMGsiAyQAIANBAzoAKCADQoCAgICABDcDICADQQA2AhggA0EANgIQIAMgATYCDCADIAA2AggCfwJAAkAgAigCACIKRQRAIAJBFGooAgAiAEUNASACKAIQIQEgAEEDdCEFIABBAWtB/////wFxQQFqIQcgAigCCCEAA0AgAEEEaigCACIEBEAgAygCCCAAKAIAIAQgAygCDCgCDBECAA0ECyABKAIAIANBCGogAUEEaigCABEAAA0DIAFBCGohASAAQQhqIQAgBUEIayIFDQALDAELIAIoAgQiAEUNACAAQQV0IQsgAEEBa0H///8/cUEBaiEHIAIoAgghAANAIABBBGooAgAiAQRAIAMoAgggACgCACABIAMoAgwoAgwRAgANAwsgAyAFIApqIgRBHGotAAA6ACggAyAEQRRqKQIANwMgIARBEGooAgAhBiACKAIQIQhBACEJQQAhAQJAAkACQCAEQQxqKAIAQQFrDgIAAgELIAZBA3QgCGoiDEEEaigCAEG5AkcNASAMKAIAKAIAIQYLQQEhAQsgAyAGNgIUIAMgATYCECAEQQhqKAIAIQECQAJAAkAgBEEEaigCAEEBaw4CAAIBCyABQQN0IAhqIgZBBGooAgBBuQJHDQEgBigCACgCACEBC0EBIQkLIAMgATYCHCADIAk2AhggCCAEKAIAQQN0aiIBKAIAIANBCGogASgCBBEAAA0CIABBCGohACALIAVBIGoiBUcNAAsLIAJBDGooAgAgB0sEQCADKAIIIAIoAgggB0EDdGoiACgCACAAKAIEIAMoAgwoAgwRAgANAQtBAAwBC0EBCyADQTBqJAALrAUCBH8CfiMAQfAAayIEJAAgBEIANwNAIAQgA60iCDcDSAJAAkACQCABQUBrKAIAQQJHBEAgBEEQaiABQRBqELwDIAQgBDUCECAENQIUfiABLQCABBCBA61C/wGDENMBIARCADcDWCAEQn8gBCkDACAEKQMIQgBSGyIJNwNgIAggCVINASAEQUBrIAEgAiADEC0CQAJAAkACQCAELQBAQSNHBEAgBEHoAGogBEHQAGooAgA2AgAgBEHgAGogBEHIAGopAwA3AwAgBCAE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gAQQgQOtQv8BgxDTAUJ/IAIpAwggAikDEEIAUhsiBkKAgICACFQEQAJAIAanIgNFBEBBASEEDAELIANBARCNAyIERQ0DCyACQegAaiIFIAFBiAQQ0AMaIAJBQGsgBSAEIAMQVCACKAJAIgFBBkcNAyAAIAM2AgQgAEEGNgIAIABBDGogAzYCACAAQQhqIAQ2AgAMBAsgAkIDNwNAIAJBIGogAkFAaxChAiACQYQBaiACQThqKQMANwIAIAJB/ABqIAJBMGopAwA3AgAgAkH0AGogAkEoaikDADcCACACIAIpAyA3AmwgAEEDNgIAIAAgAikCaDcCBCAAQQxqIAJB8ABqKQIANwIAIABBFGogAkH4AGopAgA3AgAgAEEcaiACQYABaikCADcCACAAQSRqIAJBiAFqKAIANgIAIAEQTgwDC0Hcn8AAQStBvKLAABCTAgALIANBARDKAwALIAAgAikCRDcCBCAAQSRqIAJB5ABqKAIANgIAIABBHGogAkHcAGopAgA3AgAgAEEUaiACQdQAaikCADcCACAAQQxqIAJBzABqKQIANwIAIAAgATYCACADRQ0AIAQQPQsgAkHwBGokAAv4AwECfwJAAkACQAJAAkACQAJAIAAoAgAOBQECAwUEAAsgAC0ABEEDRw0EIABBCGooAgAiASgCACABKAIEKAIAEQMAIAEoAgQiAkEEaigCAARAIAJBCGooAgAaIAEoAgAQPQsgACgCCBA9DwsCQCAALQAEQQFrQQFLDQAgAEEIaigCAEUNACAAQQxqKAIAED0LIABBFGooAgAiAUUNAyABIABBGGoiASgCACgCABEDACABKAIAIgFBBGooAgBFDQMMBAsCQCAALQAEQQFrQQFLDQAgAEEIaigCAEUNACAAQQxqKAIAED0LIABBFGooAgAiAUUNAiABIABBGGoiASgCACgCABEDACABKAIAIgFBBGooAgBFDQIMAwsCQCAAKAIEQQJHDQAgAEEIaigCAEUNACAAQQxqKAIAED0LIABBFGooAgAiAUUNASABIABBGGoiASgCACgCABEDACABKAIAIgFBBGooAgBFDQEgAUEIaigCABogACgCFBA9DAELAkAgAEEUai0AAEEBa0EBSw0AIABBGGooAgBFDQAgAEEcaigCABA9CwJAAkBBASAALQAEIgFBBGsgAUEDTRtB/wFx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agsiAyICIAVJDQELCyAAIAM2AgQgACAENgIAIAEgBSACazYCBCABIAIgBGo2AgAgACACIANrNgIMIAAgAyAEajYCCA8LIABBADYCAAvdAwIEfwF9IwBBMGsiBCQAIABDAAAAQRA6AkAgAEEIaigCAEUNACAEQRBqIABBBGoiAygCABC0AyAEQQhqIAQoAhAgBCgCFBCQAyAEQRhqIAMoAgAgAEEIaiIFKAIAQX8Cf0MAALRDIAQoAgizIAQoAgyzlEMAACBBlUMAALRDlCABQwAASEOUQwAAAD6UlSIHlY4iAUMAAIBPXSABQwAAAABgIgZxBEAgAakMAQtBAAtBACAGGyABQ///f09eGxBNIAUoAgAiBQRAIAVBJGwhBSADKAIAQRxqIQMDQCADQQRrKAIABEAgAygCABA9CyADQSRqIQMgBUEkayIFDQALCyAAKAIABEAgAEEEaigCABA9CyAAIAQpAxg3AgAgAEEIaiIDIARBIGoiBigCADYCACADKAIAIgNFDQAgB4wgByACGyEBIABBBGooAgAhBSADQSRsIQBBACEDA0AgASADs5RDAAC0QxDhAyEHIARBGGogBRDWAyAHQzX6jjyUECYgBRDWAyICKAIIBEAgAkEMaigCABA9CyAFQSRqIQUgAiAEKQMYNwIAIAJBEGogBEEoaigCADYCACACQQhqIAYpAwA3AgAgA0EBaiEDIABBJGsiAA0ACwsgBEEwaiQAC+0DAQZ/IwBBMGsiBSQAAkACQAJAAkACQCABQQxqKAIAIgMEQCABKAIIIQcgA0EBa0H/////AXEiA0EBaiIGQQdxIQQCfyADQQdJBEBBACEDIAcMAQsgB0E8aiECIAZB+P///wNxIQZBACEDA0AgAigCACACQQhrKAIAIAJBEGsoAgAgAkEYaygCACACQSBrKAIAIAJBKGsoAgAgAkEwaygCACACQThrKAIAIANqampqampqaiEDIAJBQGshAiAGQQhrIgYNAAsgAkE8awshAiAEBEAgAkEEaiECA0AgAigCACADaiEDIAJBCGohAiAEQQFrIgQNAAsLIAFBFGooAgANASADIQQMAwtBACEDIAFBFGooAgANAUEBIQIMBAsgA0EPSw0AIAcoAgRFDQILIAMgA2oiBCADSQ0BCyAERQ0AAkAgBEEATgRAIARBARCMAyICRQ0BIAQh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QRBqKAIANgIAIANBCGogAUEIaikCADcCAAwCCyACQRhqIAFBEGooAgA2AgAgAkEQaiABQQhqKQIANwMAIAIgASkCADcDCCACQQA2AiggAkKAgICAEDcDICACQTBqIgEgAkEgakGMyMAAEMYCIAJBCGogARB3DQMgAEEIaiACKQMgNwIAIABBEGogAkEoaigCADYCACAAQRRqQQA2AgAgAEKCgICAIDcDACACLQAIQR9HDQEgAi0ADEEDRw0BIAJBEGooAgAiACgCACAAKAIEKAIAEQMAIAAoAgQiAUEEaigCAARAIAFBCGooAgAaIAAoAgAQPQsgAigCEBA9DAELIABBAzYCACAAQgM3AwgLIAJB4ABqJAAPC0EUQQQQygMAC0GkyMAAQTcgAkHYAGpB3MjAAEG4ycAAENEBAAvABAEDfyMAQTBrIgIkAAJ/AkACQAJAAkAgACgCBCIDDgMAAgMBCyMAQRBrIgAkACAAQYjCwAA2AgggAEEONgIEIABB+sHAADYCACMAQRBrIgEkACABQQhqIABBCGooAgA2AgAgASAAKQIANwMAIwBBEGsiACQAIAAgASkCADcDCCAAQQhqQaDCwABBACABKAIIQQEQtQEACyACQSRqQQE2AgAgAkEsakEANgIAIAJB3MDAADYCICACQfi9wAA2AiggAkEANgIYQQEgASACQRhqEPMBDQIaIANBA3QhAyAAKAIAIQACQANAIAIgADYCFCAEBEAgAkEBNgIkIAJB6MDAADYCICACQQA2AiwgAkH4vcAANgIoIAJBADYCGCABIAJBGGoQ8wENAgsgAkECNgIkIAJB8MDAADYCICACQQE2AiwgAkEANgIYIAJB6AA2AgQgAiACNgIoIAIgAkEUajYCACABIAJBGGoQ8wENASAAQQhqIQAgBEEBayEEIANBCGsiAw0AC0EADAMLQQEMAgsgAkEkakECNgIAIAJBLGpBATYCACACQfDAwAA2AiAgAkEANgIYIAJB6QA2AgQgAiAAKAIANgIAIAIgAjYCKCABIAJBGGoQ8wEMAQsgAkEMakHpADYCACACQSRqQQM2AgAgAkEsakECNgIAIAJBiMHAADYCICACQQA2AhggAkHpADYCBCACIAAoAgAiADYCACACIABBCGo2AgggAiACNgIoIAEgAkEYahDzAQsgAkEwaiQAC9UDAgd/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OwE0IABBGGpBADYCACAAQTBqIgQoAgAiA0EBIAAtADgiBnQiBUECaiIBTwRAIAQgATYCACABIQMLIABBJGooAgAEQCAAQQE2AiQLAkAgASADTQRAIABBLGooAgAiBCECQQIgBnRBAmoiCUEBdkEBakEHcSIHBEADQCACQYDAADsBACACQQJqIQIgB0EBayIHDQALCyAJQQ5PBEAgBCABQQF0aiEBA0AgAkKAwICAgoCIgCA3AQAgAkEIakKAwICAgoCIgCA3AQAgAkEQaiICIAFHDQALCyADIAVNDQEgACAIrUL//wODNwMAIAAgBkEBaiIBOgAIIAAgAToACSAEIAVBAXRqQQA7AQAPCyABIANBiL3CABClAwALIAUgA0GYvcIAENgBAAu8AgEFfyAAKAIYIQMCQAJAIAAgACgCDEYEQCAAQRRBECAAQRRqIgEoAgAiBBtqKAIAIgINAUEAIQEMAgsgACgCCCICIAAoAgwiATYCDCABIAI2AggMAQsgASAAQRBqIAQbIQQDQCAEIQUgAiIBQRRqIgIgAUEQaiACKAIAIgIbIQQgAUEUQRAgAhtqKAIAIgINAAsgBUEANgIACwJAIANFDQACQCAAIAAoAhxBAnRBoJrDAGoiAigCAEcEQCADQRBBFCADKAIQIABGG2ogATYCACABRQ0CDAELIAIgATYCACABDQBBvJ3DAEG8ncMAKAIAQX4gACgCHHdxNgIADwsgASADNgIYIAAoAhAiAgRAIAEgAjYCECACIAE2AhgLIABBFGooAgAiAEUNACABQRRqIAA2AgAgACABNgIYCwu+BAEFfyMAQfAAayICJAAgACgCACEAIAJBxABqQdT8wAA2AgAgAkE8akHE/MAANgIAIAJBNGpBtPzAADYCACACQSxqQbT8wAA2AgAgAkEkakHE+sAANgIAIAJBHGpBxPrAADYCACACQRRqQcT6wAA2AgAgAkEMakHE+sAANgIAIAIgADYCTCACIABBBGo2AlAgAiAAQQhqNgJUIAIgAEEMajYCWCACIABBEGo2AlwgAiAAQRRqNgJgIAIgAEEWajYCZCACIABBGGo2AmggAkHE+sAANgIEIAIgAEEZajYCbCACIAJB7ABqNgJAIAIgAkHoAGo2AjggAiACQeQAajYCMCACIAJB4ABqNgIoIAIgAkHcAGo2AiAgAiACQdgA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AwA3AgAgAUEBNgIgIAEgAjYCHCABQQQ2AhggAUEwaiABQRBqKAIANgIAIAEgASkDCDcDKCABQThqIAFBKGoQSCABKAJUBEBBJCEHQQEhBQNAIAEoAhggBUYEQCABQRhqIAVBARClASABKAIcIQILIAIgB2oiBiABKQM4NwIAIAZBIGogCCgCADYCACAGQRhqIAkpAwA3AgAgBkEQaiAKKQMANwIAIAZBCGogCykDADcCACABIAVBAWoiBTYCICAHQSRqIQcgAUE4aiABQShqEEggASgCVA0ACwsgASgCKCABKAIsKAIAEQMAIAEoAiwiAkEEaigCAARAIAJBCGooAgAaIAEoAigQPQsgBCABKQMYNwIAIARBCGogAUEgaigCADYCAAsgAUHgAGokAAwBC0GQAUEEEMoDAAsCQCADKAIIQQZGBEAgACADKQMwNwIEIABBBjYCACAAQQxqIANBOGooAgA2AgAMAQsgACADKQMINwMAIABBIGogA0EoaikDADcDACAAQRhqIANBIGopAwA3AwAgAEEQaiADQRhqKQMANwMAIABBCGogA0EQaikDADcDACADKAI0IQEgAygCOCIABEAgAEEkbCECIAFBHGohAANAIABBBGsoAgAEQCAAKAIAED0LIABBJGohACACQSRrIgINAAsLIAMoAjBFDQAgARA9CyADQdAAaiQAC6UCAQV/IwBBMGsiAiQAIAACfwJAIAFBEGooAgAEQCACQRhqIAFBCGoQngIgAigCGA0BCyAAQQhqQQA2AgBBAAwBCyACQRBqIAIoAhwQhAIgAigCFCEFIAIoAhAhAyABIAEoAhRBAWo2AhQgAUEEaiEEAkAgASgCAEUNACAEKAIAIgZBhAFJDQAgBhAACyABQQE2AgAgBCAFNgIAIAIgAyIBNgIkIAJBCGogARACAkAgAigCCCIEBEAgAigCDCEDDAELIAJBJGogAkEoakG0pcAAEGUhA0EAIQQgAigCJCEBCyABQYQBTwRAIAEQAAsgBARAIAAgAzYCBCAAQQxqIAM2AgAgAEEIaiAENgIAQQAMAQsgACADNgIEQQELNgIAIAJBMGokAAuVAgEBfyMAQRBrIgIkACAAKAIAIQACfwJAIAEoAghBAUcEQCABKAIQQQFHDQELIAJBADYCDCABIAJBDGoCfyAAQYABTwRAIABBgBBPBEAg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IABBBGo2AgwgAUHG08AAQQcgAkEMakHI0sAAELgBDAELIAFBvNPAAEEKEIUDCyACQRBqJAALdwEBfwJAIAEoAgBFBEAgAEGABDsBBEEMQQQQjAMiAkUNASACIAEpAgA3AgAgAEEYakGoxsAANgIAIABBFGogAjYCACACQQhqIAFBCGooAgA2AgAgAEEANgIADwsgACABKQIENwIEIABBBTYCAA8LQQxBBBDKAwALcwAjAEEwayIBJABByJnDAC0AAARAIAFBFGpBAjYCACABQRxqQQE2AgAgAUHoysIANgIQIAFBADYCCCABQcQANgIkIAEgADYCLCABIAFBIGo2AhggASABQSxqNgIgIAFBCGpBkMvCABCsAgALIAFBMGokAAt2AQF/IAAtAAQhASAALQAFBEAgAUH/AXEhASAAAn9BASABDQAaIAAoAgAiAS0AGEEEcUUEQCABKAIAQdf3wgBBAiABKAIEKAIMEQIADAELIAEoAgBB1vfCAEEBIAEoAgQoAgwRAgALIgE6AAQLIAFB/wFxQQBHC20BA38gAUEEaigCACEEAkACQAJAIAFBCGooAgAiAUUEQEEBIQIMAQsgAUEATiIDRQ0BIAEgAxCMAyICRQ0CCyAAIAI2AgQgACABNgIAIAIgBCABENADGiAAIAE2AggPCxCgAgALIAEgAxDKAwALbQECfyMAQTBrIgAkACAAQQQ2AgwgAEH4qMAANgIIIABBHGpBAjYCACAAQSRqQQE2AgAgAEGkscAANgIYIABBADYCECAAQQo2AiwgACAAQShqNgIgIAAgAEEIajYCKCAAQRBqEL0BIABBMGokAAt1AQF/IwBBEGsiAiQAAn8gACgCACIAKAIARQRAIAIgAEEEajYCCCACIABBCGo2AgwgAUHN/cAAQQ9B3P3AAEEIIAJBCGpB5P3AAEH0/cAAQQYgAkEMakHk/cAAELoBDAELIAFBuP3AAEEVEIUDCyACQRBqJAALPgAgACgCEARAIABBFGooAgAQPQsgAEEcaigCAARAIABBIGooAgAQPQsgAEEoaigCAARAIABBLGooAgAQPQsLWAECfyMAQSBrIgIkACABKAIEIQMgASgCACACQRhqIAAoAgAiAEEQaikCADcDACACQRBqIABBCGopAgA3AwAgAiAAKQIANwMIIAMgAkEIahBTIAJBIGokAAtiAQF/IwBBIGsiBSQAIAUgAjYCBCAFIAE2AgAgBUEYaiADQRBqKQIANwMAIAVBEGogA0EIaikCADcDACAFIAMpAgA3AwggACAFQcCLwAAgBUEEakHAi8AAIAVBCGogBBBsAAtdAQJ/IwBBIGsiAiQAIAJBCGoiAyABQfyUwABBABC+AiACIAA2AhggAiAAQQRqNgIcIAMgAkEYakH8lMAAEIoBGiADIAJBHGpB/JTAABCKARogAxDMASACQSBqJAALZwEBfyMAQRBrIgIkAAJ/IAAoAgAiACkDAFAEQCACIABBCGo2AgggAUGsrMAAQQIgAkEIakGwrMAAELgBDAELIAIgAEEIajYCDCABQZiswABBAyACQQxqQZyswAAQuAELIAJBEGokAAuUAgECfyMAQRBrIgIkACACIAAoAgAiADYCBCACIABBBGo2AgggAiAAQQhqNgIMIwBBEGsiACQAIAEoAgBBr/rAAEEPIAEoAgQoAgwRAgAhAyAAQQA6AA0gACADOgAMIAAgATYCCCAAQQhqQb76wABBBCACQQRqQcT6wAAQeEHU+sAAQQQgAkEIakHE+sAAEHhB2PrAAEEEIAJBDGpB3PrAABB4IQECfyAALQAMIgMgAC0ADUUNABpBASADDQAaIAEoAgAiAS0AGEEEcUUEQCABKAIAQdf3wgBBAiABKAIEKAIMEQIADAELIAEoAgBB1vfCAEEBIAEoAgQoAgwRAgALIABBEGokAEH/AXFBAEcgAkEQaiQAC1kBAX8jAEEgayICJAAgAiAAKAIANgIEIAJBGGogAUEQaikCADcDACACQRBqIAFBCGopAgA3AwAgAiABKQIANwMIIAJBBGpB1KXAACACQQhqEFMgAkEgaiQAC1kBAX8jAEEgayICJAAgAiAAKAIANgIEIAJBGGogAUEQaikCADcDACACQRBqIAFBCGopAgA3AwAgAiABKQIANwMIIAJBBGpBxLvAACACQQhqEFMgAkEgaiQAC2oBAX4gASkCACECAkAgAS0AAEEERgRAIABBgAQ7AQRBCEEEEIwDIgFFDQEgASACNwIAIABBGGpB5MbAADYCACAAQRRqIAE2AgAgAEEBNgIADwsgACACNwIEIABBBTYCAA8LQQhBBBDKAwALWQEBfyMAQSBrIgIkACACIAAoAgA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakHc2cAAIAJBCGoQUyACQSBqJAALWQEBfyMAQSBrIgIkACACIAAoAgA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakHIwsIAIAJBCGoQUyACQSBqJAALWQEBfyMAQSBrIgIkACACIAAoAgA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakH8wsIAIAJBCGoQUyACQSBqJAALWQEBfyMAQSBrIgIkACACIAAoAgA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakGs2cIAIAJBCGoQUyACQSBqJAALUwECfyMAQSBrIgIkACABKAIEIQMgASgCACACQRhqIABBEGopAgA3AwAgAkEQaiAAQQhqKQIANwMAIAIgACkCADcDCCADIAJBCGoQUyACQSBqJAALWQEBfyMAQSBrIgIkACACIAAoAgA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakHo+cIAIAJBCGoQUyACQSBqJAALUwECfyMAQSBrIgIkACAAKAIEIQMgACgCACACQRhqIAFBEGopAgA3AwAgAkEQaiABQQhqKQIANwMAIAIgASkCADcDCCADIAJBCGoQUyACQSBqJAALVgEBfyMAQSBrIgIkACACIAA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakHUpcAAIAJBCGoQUyACQSBqJAALVgEBfyMAQSBrIgIkACACIAA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakHEu8AAIAJBCGoQUyACQSBqJAALVgEBfyMAQSBrIgIkACACIAA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakHc2cAAIAJBCGoQUyACQSBqJAALVgEBfyMAQSBrIgIkACACIAA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakHIwsIAIAJBCGoQUyACQSBqJAALVgEBfyMAQSBrIgIkACACIAA2AgQgAkEYaiABQRBqKQIANwMAIAJBEGogAUEIaikCADcDACACIAEpAgA3AwggAkEEakHo+cIAIAJBCGoQUyACQSBqJAALTQACf0EAIABBA0kNABpBASAAQQRNDQAaQQIgAEEJSQ0AGkEDIABBEUkNABpBBCAAQSFJDQAaQQUgAEHBAEkNABpBBkEHIABBgQFJGwsLOwAgACgCIARAIABBJGooAgAQPQsgAEEsaigCAARAIABBMGooAgAQPQsgAEEUaigCAARAIAAoAhAQPQsLawEBfQJAIAEqAgggApIiAkMAAAAAXUUEQEMAALRDIQMgAkMAALRDXkUNAQsgAyECCyAAIAEpAgw3AgwgACABKgIEOAIEIAAgASgCADYCACAAQwAAAAAgAiACQwAAtMOSi0MAAAA0XRs4AggLWgECfwJAIAAtAABBH0cNACAALQAEQQNHDQAgAEEIaigCACIBKAIAIAEoAgQoAgARAwAgASgCBCICQQRqKAIABEAgAkEIaigCABogASgCABA9CyAAKAIIED0LC2IBAX8jAEEQayICJAACfyAAKAIARQRAIAIgAEEEajYCCCABQfijwgBBBiACQQhqQYCkwgAQuAEMAQsgAiAAQQRqNgIMIAFB5KPCAEECIAJBDGpB6KPCABC4AQsgAkEQaiQAC2EBAX8jAEEQayICJAACfyAALQAAQQRGBEAgAiAAQQFqNgIIIAFB6LHCAEEGIAJBCGpB8LHCABC4AQwBCyACIAA2AgwgAUHUscIAQQIgAkEMakHYscIAELgBCyACQRBqJAALTQECfwJAIAAoAgAiAUECRg0AAkAgAEEUaigCACICRQ0AIAAoAhBFDQAgAhA9IAAoAgAhAQsgAUUNACAAKAIERQ0AIABBCGooAgAQPQsLWAECfyMAQRBrIgIkACABLQAAQQNHBH9BAAUgAkEIaiABKAIEIgEoAgAgASgCBCgCJBEBACACKAIMIQMgAigCCAshASAAIAM2AgQgACABNgIAIAJBEGokAAtYAQJ/IwBBEGsiAiQAIAEtAABBA0cEf0EABSACQQhqIAEoAgQiASgCACABKAIEKAIYEQEAIAIoAgwhAyACKAIICyEBIAAgAzYCBCAAIAE2AgAgAkEQ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fiAAIAHAQQN0QYD+wABqKQMAIAOtIAKtQv8Bg35+IgRC8f////8AVDYCACAAIARCB3xCA4inQQFqNgIEC0gBAX8gAiAAKAIAIgAoAgAgACgCCCIDa0sEQCAAIAMgAhCwASAAKAIIIQMLIAAoAgQgA2ogASACENADGiAAIAIgA2o2AghBAAtIAQF/IAIgACgCACIAKAIAIAAoAggiA2tLBEAgACADIAIQsQEgACgCCCEDCyAAKAIEIANqIAEgAhDQAxogACACIANqNgIIQQALRQEBfSAAAn8gASoCABD7AiICQwAAgE9dIAJDAAAAAGBxBEAgAqkMAQtBAAs6AAEgACACQwAAgENdIAJDAACAv15xOgAAC0gAIAAgAzYCDCAAIAI2AgggACAFNgIEIAAgBDYCACAAIAEpAgA3AhAgAEEgaiABQRBqKAIANgIAIABBGGogAUEIaikCADcCAAtDAQF/IAIgACgCACAAKAIIIgNrSwRAIAAgAyACEKwBIAAoAgghAwsgACgCBCADaiABIAIQ0AMaIAAgAiADajYCCEEAC0MBAX8gAiAAKAIAIAAoAggiA2tLBEAgACADIAIQrQEgACgCCCEDCyAAKAIEIANqIAEgAhDQAxogACACIANqNgIIQQALQQEBfyABKAIAIgIgASgCBE8Ef0EABSABIAJBAWo2AgAgASgCCCgCACACEAghAUEBCyECIAAgATYCBCAAIAI2AgALPgECfyAAIAAtAEYiAUEBaiICOgAKIABBASABQQ9xdEECajsBQCAAQX8gAkEPcXRBf3M7AQggAEEgaiABEGsLSgEBfyMAQSBrIgAkACAAQRRqQQE2AgAgAEEcakEANgIAIABB9NnCADYCECAAQcTZwgA2AhggAEEANgIIIABBCGpB/NnCABCsAgALPAAgACABKQMANwMAIABBGGogAUEYaikDADcDACAAQRBqIAFBEGopAwA3AwAgAEEIaiABQQhqKQMANwMAC0YBAn8gASgCBCECIAEoAgAhA0EIQQQQjAMiAUUEQEEIQQQQygMACyABIAI2AgQgASADNgIAIABBuMzCADYCBCAAIAE2AgALmXcDFn4ifwF8IAEoAhhBAXEhGCAAKwMAIToCQAJAAkAgASgCEEEBRgRAAn8gASEkIAFBFGooAgAhJyMAQfAIayIfJAAgOr0hAwJAIDogOmIEQEECIQEMAQsgA0L/////////B4MiBkKAgICAgICACIQgA0IBhkL+////////D4MgA0I0iKdB/w9xIgAbIgRCAYMhBUEDIQECQAJAAkBBAUECQQQgA0KAgICAgICA+P8AgyIHUCIZGyAHQoCAgICAgID4/wBRG0EDQQQgGRsgBlAbQQJrDgMAAQIDC0EEIQEMAgsgAEGzCGshHCAFUCEBQgEhAgwBC0KAgICAgICAICAEQgGGIARCgICAgICAgAhRIhkbIQRCAkIBIBkbIQIgBVAhAUHLd0HMdyAZGyAAaiEcCyAfIBw7AegIIB8gAjcD4AggH0IBNwPYCCAfIAQ3A9AIIB8gAToA6ggCf0Gs3MIAIAFBAkYNABogGEUEQCADQj+IpyEsQZv0wgBBrNzCACADQgBTGwwBC0EBISxBm/TCAEGc9MIAIANCAFMbCyEyQQEhAAJAAkACfwJAAkACQAJAQQMgAUECayABQQFNG0H/AXFBAWsOAwIBAAMLQXRBBSAcwSIAQQBIGyAAbCIAQb/9AEsNBCAfQZAIaiEgIB9BEGohIiAAQQR2QRVqIhohHEGAgH5BACAnayAnQYCAAk8bIRsCQAJAAkACQAJAAkACQCAfQdAIaiIAKQMAIgJQRQRAIAJC//////////8fVg0BIBxFDQNBoH8gAC8BGCIAQSBrIAAgAkKAgICAEFQiABsiAUEQayABIAJCIIYgAiAAGyICQoCAgICAgMAAVCIAGyIBQQhrIAEgAkIQhiACIAAbIgJCgICAgICAgIABVCIAGyIBQQRrIAEgAkIIhiACIAAbIgJCgICAgICAgIAQVCIAGyIBQQJrIAEgAkIEhiACIAAbIgJCgICAgICAgIDAAFQiABsgAkIChiACIAAbIgJCP4enQX9zaiIBa8FB0ABsQbCnBWpBzhBtIgBB0QBPDQIgAEEEdCIAQarkwgBqLwEAIR4CfwJAAkAgAEGg5MIAaikDACIDQv////8PgyIEIAIgAkJ/hUI/iIYiAkIgiCIFfiIGQiCIIANCIIgiAyAFfnwgAyACQv////8PgyICfiIDQiCIfCAGQv////8PgyACIAR+QiCIfCADQv////8Pg3xCgICAgAh8QiCIfCICQUAgASAAQajkwgBqLwEAamsiAUE/ca0iA4inIgBBkM4ATwRAIABBwIQ9SQ0BIABBgMLXL0kNAkEIQQkgAEGAlOvcA0kiGRshGEGAwtcvQYCU69wDIBkbDAMLIABB5ABPBEBBAkEDIABB6AdJIhkbIRhB5ABB6AcgGRsMAwsgAEEJSyEYQQFBCiAAQQpJGwwCC0EEQQUgAEGgjQZJIhkbIRhBkM4AQaCNBiAZGwwBC0EGQQcgAEGAreIESSIZGyEYQcCEPUGAreIEIBkbCyEZQgEgA4YhBAJAIBggHmtBEHRBgIAEakEQdSIeIBvBIiNKBEAgAiAEQgF9IgaDIQUgAUH//wNxISEgHiAba8EgHCAeICNrIBxJGyIjQQFrISVBACEBA0AgACAZbiEdIAEgHEYNByAAIBkgHWxrIQAgASAiaiAdQTBqOgAAIAEgJUYNCCABIBhGDQIgAUEBaiEBIBlBCkkgGUEKbiEZRQ0AC0Gg8MIAQRlBnPLCABCTAgALICAgIiAcQQAgHiAbIAJCCoAgGa0gA4YgBBBuDAgLIAFBAWoiASAcIAEgHEsbIQAgIUEBa0E/ca0hB0IBIQIDQCACIAeIUEUEQCAgQQA2AgAMCQsgACABRg0HIAEgImogBUIKfiIFIAOIp0EwajoAACACQgp+IQIgBSAGgyEFICMgAUEBaiIBRw0ACyAgICIgHCAjIB4gGyAFIAQgAhBuDAcLQePfwgBBHEHI8cIAEJMCAAtB2PHCAEEkQfzxwgAQkwIACyAAQdEAQeDuwgAQ2AEAC0H88MIAQSFBjPLCABCTAgALIBwgHEGs8sIAENgBAAsgICAiIBwgIyAeIBsgAK0gA4YgBXwgGa0gA4YgBBBuDAELIAAgHEG88sIAENgBAAsgG8EhLQJAIB8oApAIRQRAIB9BwAhqIS4gH0EQaiEeQQAhISMAQdAGayIdJAACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAIB9B0AhqIgApAwAiAlBFBEAgACkDCCIDUA0BIAApAxAiBFANAiACIAR8IAJUDQMgAiADVA0EIAAvARghACAdIAI+AgggHUEBQQIgAkKAgICAEFQiARs2AqgBIB1BACACQiCIpyABGzYCDCAdQRBqQQBBmAEQzgMaIB1BsAFqQQRyQQBBnAEQzgMaIB1BATYCsAEgHUEBNgLQAiAArcMgAkIBfXl9QsKawegEfkKAoc2gtAJ8QiCIpyIBwSElAkAgAMEiGEEATgRAIB1BCGogABA+GgwBCyAdQbABakEAIBhrwRA+GgsCQCAlQQBIBEAgHUEIakEAICVrwRBHDAELIB1BsAFqIAFB//8DcRBHCyAdKALQAiEcIB1BqAVqIB1BsAFqQaABENADGiAdIBw2AsgGAkAgGiIiQQpJDQACQCAcQShLBEAgHCEBDAELIB1BoAVqIRggHCEBA0ACQCABRQ0AIAFBAWtB/////wNxIhlBAWoiG0EBcSABQQJ0IQACfyAZRQRAQgAhAiAdQagFaiAAagwBCyAbQf7///8HcSEbIAAgGGohAUIAIQIDQCABQQRqIgAgADUCACACQiCGhCICQoCU69wDgCIDPgIAIAEgATUCACACIANCgJTr3AN+fUIghoQiAkKAlOvcA4AiAz4CACACIANCgJTr3AN+fSECIAFBCGshASAbQQJrIhsNAAsgAUEIagshAEUNACAAQQRrIgAgADUCACACQiCGhEKAlOvcA4A+AgALICJBCWsiIkEJTQ0CIB0oAsgGIgFBKUkNAAsLDA4LAn8CfwJAICJBAnRBtN3CAGooAgAiAQRAIB0oAsgGIgBBKU8NGkEAIABFDQMaIABBAWtB/////wNxIhhBAWoiGUEBcSEiIABBAnQhACABrSEDIBgNAUIAIQIgHUGoBWogAGoMAgtB347DAEEbQZiOwwAQkwIACyAZQf7///8HcSEbIAAgHWpBoAVqIQFCACECA0AgAUEEaiIAIAA1AgAgAkIghoQiAiADgCIEPgIAIAEgATUCACACIAMgBH59QiCGhCICIAOAIgQ+AgAgAiADIAR+fSECIAFBCGshASAbQQJrIhsNAAsgAUEIagshACAiBEAgAEEEayIAIAA1AgAgAkIghoQgA4A+AgALIB0oAsgGCyIAIB0oAqgBIhggACAYSxsiAEEoSw0WIABFBEBBACEADAcLIABBAXEhICAAQQFGBEBBACEiDAYLIABBfnEhI0EAISIgHUGoBWohASAdQQhqIRsDQCABIAEoAgAiJiAbKAIAaiIZICJBAXFqIi82AgAgAUEEaiIiICIoAgAiMCAbQQRqKAIAaiIiIBkgJkkgGSAvS3JqIhk2AgAgGSAiSSAiIDBJciEiIBtBCGohGyABQQhqIQEgIyAhQQJqIiFHDQALDAULQePfwgBBHEH84sIAEJMCAAtBkODCAEEdQYzjwgAQkwIAC0HA4MIAQRxBnOPCABCTAgALQezgwgBBNkGs48IAEJMCAAtBtOHCAEE3QbzjwgAQkwIACyAgBH8gIUECdCIBIB1BqAVqaiIZIBkoAgAiGSAdQQhqIAFqKAIAaiIBICJqIhs2AgAgASAZSSABIBtLcgUgIgtBAXFFDQAgAEEnSw0BIB1BqAVqIABBAnRqQQE2AgAgAEEBaiEACyAdIAA2AsgGIAAgHCAAIBxLGyIBQSlPDQYgAUECdCEBAkADQCABBEBBfyABQQRrIgEgHUGwAWpqKAIAIgAgASAdQagFamooAgAiGUcgACAZSxsiG0UNAQwCCwtBf0EAIAEbIRsLIBtBAU0EQCAlQQFqISUMBAsgGEEpTw0SIBhFBEBBACEYDAMLIBhBAWtB/////wNxIgBBAWoiAUEDcSEbIABBA0kEQCAdQQhqIQFCACECDAILIAFB/P///wdxIRkgHUEIaiEBQgAhAgNAIAEgATUCAEIKfiACfCICPgIAIAFBBGoiACAANQIAQgp+IAJCIIh8IgI+AgAgAUEIaiIAIAA1AgBCCn4gAkIgiHwiAj4CACABQQxqIgAgADUCAEIKfiACQiCIfCICPgIAIAJCIIghAiABQRBqIQEgGUEEayIZDQALDAELIABBKEGYjsMAENgBAAsgGwRAA0AgASABNQIAQgp+IAJ8IgI+AgAgAUEEaiEBIAJCIIghAiAbQQFrIhsNAAsLIAKnIgBFDQAgGEEnSw0RIB1BCGogGEECdGogADYCACAYQQFqIRgLIB0gGDYCqAELQQAhAAJAICXBIgEgLcEiGE4EQCAlIC1rwSAaIAEgGGsgGkkbIiINAQtBACEiDAELIB1B2AJqIgEgHUGwAWoiAEGgARDQAxogHSAcNgL4AyABQQEQPiEzIB0oAtACIQEgHUGABGoiGCAAQaABENADGiAdIAE2AqAFIBhBAhA+ITQgHSgC0AIhASAdQagFaiIYIABBoAEQ0AMaIB0gATYCyAYgHUGsAWohNSAdQdQCaiE2IB1B/ANqITcgHUGkBWohOCAYQQMQPiE5IB0oAqgBIQAgHSgC0AIhHCAdKAL4AyEvIB0oAqAFITAgHSgCyAYhKEEAISMCQANAICMhIAJAAkACQAJAAkAgAEEpSQRAICBBAWohIyAAQQJ0IRhBACEBAkACQAJAA0AgASAYRg0BIB1BCGogAWogAUEEaiEBKAIARQ0ACyAAICggACAoSxsiGEEpTw0ZIBhBAnQhAQJAA0AgAQRAQX8gASA4aigCACIZIAFBBGsiASAdQQhqaigCACIbRyAZIBtLGyIbRQ0BDAILC0F/QQAgARshGwtBACEmIBtBAkkEQCAYBEBBASEhQQAhACAYQQFHBEAgGEF+cSEmIB1BCGohASAdQagFaiEbA0AgASABKAIAIikgGygCAEF/c2oiGSAhQQFxaiIqNgIAIAFBBGoiISAhKAIAIisgG0EEaigCAEF/c2oiISAZIClJIBkgKktyaiIZNgIAICEgK0kgGSAhSXIhISAbQQhqIRsgAUEIaiEBICYgAEECaiIARw0ACwsgGEEBcQR/IABBAnQiACAdQQhqaiIBIAEoAgAiASAAIDlqKAIAQX9zaiIAICFqIhk2AgAgACABSSAAIBlLcgUgIQtBAXFFDRALIB0gGDYCqAFBCCEmIBghAAsgACAwIAAgMEsbIhlBKU8NBiAZQQJ0IQEDQCABRQ0CQX8gASA3aigCACIYIAFBBGsiASAdQQhqaigCACIbRyAYIBtLGyIbRQ0ACwwCCyAgICJLDQMgGiAiSQ0EICAgIkYNCyAeICBqQTAgIiAgaxDOAxoMCwtBf0EAIAEbIRsLAkAgG0EBSwRAIAAhGQwBCyAZBEBBASEhQQAhACAZQQFHBEAgGUF+cSEpIB1BCGohASAdQYAEaiEbA0AgASABKAIAIiogGygCAEF/c2oiGCAhQQFxaiIrNgIAIAFBBGoiISAhKAIAIjEgG0EEaigCAEF/c2oiISAYICpJIBggK0tyaiIYNgIAICEgMUkgGCAhSXIhISAbQQhqIRsgAUEIaiEBICkgAEECaiIARw0ACwsgGUEBcQR/IABBAnQiACAdQQhqaiIBIAEoAgAiASAAIDRqKAIAQX9zaiIAICFqIhg2AgAgACABSSAAIBhLcgUgIQtBAXFFDQ0LIB0gGTYCqAEgJkEEciEmCyAZIC8gGSAvSxsiGEEpTw0WIBhBAnQhAQJAA0AgAQRAQX8gASA2aigCACIAIAFBBGsiASAdQQhqaigCACIbRyAAIBtLGyIbRQ0BDAILC0F/QQAgARshGwsCQCAbQQFLBEAgGSEYDAELIBgEQEEBISFBACEAIBhBAUcEQCAYQX5xISkgHUEIaiEBIB1B2AJqIRsDQCABIAEoAgAiKiAbKAIAQX9zaiIZICFBAXFqIis2AgAgAUEEaiIhICEoAgAiMSAbQQRqKAIAQX9zaiIhIBkgKkkgGSArS3JqIhk2AgAgISAxSSAZICFJciEhIBtBCGohGyABQQhqIQEgKSAAQQJqIgBHDQALCyAYQQFxBH8gAEECdCIAIB1BCGpqIgEgASgCACIBIAAgM2ooAgBBf3NqIgAgIWoiGTYCACAAIAFJIAAgGUtyBSAhC0EBcUUNDQsgHSAYNgKoASAmQQJqISYLIBggHCAYIBxLGyIAQSlPDRMgAEECdCEBAkADQCABBEBBfyABIDVqKAIAIhkgAUEEayIBIB1BCGpqKAIAIhtHIBkgG0sbIhtFDQEMAgsLQX9BACABGyEbCwJAIBtBAUsEQCAYIQAMAQsgAARAQQEhIUEAIRggAEEBRwRAIABBfnEhKSAdQQhqIQEgHUGwAWohGwNAIAEgASgCACIqIBsoAgBBf3NqIhkgIUEBcWoiKzYCACABQQRqIiEgISgCACIxIBtBBGooAgBBf3NqIiEgGSAqSSAZICtLcmoiGTYCACAZICFJICEgMUlyISEgG0EIaiEbIAFBCGohASApIBhBAmoiGEcNAAsLIABBAXEEfyAYQQJ0IgEgHUEIamoiGCAYKAIAIhggHUGwAWogAWooAgBBf3NqIgEgIWoiGTYCACABIBhJIAEgGUtyBSAhC0EBcUUNDQsgHSAANgKoASAmQQFqISYLIBogIEcEQCAeICBqICZBMGo6AAAgAEEpTw0UIABFBEBBACEADAcLIABBAWtB/////wNxIgFBAWoiGEEDcSEbIAFBA0kEQCAdQQhqIQFCACECDAYLIBhB/P///wdxIRkgHUEIaiEBQgAhAgNAIAEgATUCAEIKfiACfCICPgIAIAFBBGoiGCAYNQIAQgp+IAJCIIh8IgI+AgAgAUEIaiIYIBg1AgBCCn4gAkIgiHwiAj4CACABQQxqIhggGDUCAEIKfiACQiCIfCICPgIAIAJCIIghAiABQRBqIQEgGUEEayIZDQALDAULIBogGkHc48IAENgBAAsMEgsgICAiQczjwgAQpgMACyAiIBpBzOPCABClAwALIBlBKEGYjsMAEKUDAAsgGwRAA0AgASABNQIAQgp+IAJ8IgI+AgAgAUEEaiEBIAJCIIghAiAbQQFrIhsNAAsLIAKnIgFFDQAgAEEnSw0CIB1BCGogAEECdGogATYCACAAQQFqIQALIB0gADYCqAEgIiAjRw0AC0EBIQAMAQsgAEEoQZiOwwAQ2AEACwJAAkACQAJAAkACQCAcQSlJBEAgHEUEQEEAIRwMAwsgHEEBa0H/////A3EiAUEBaiIYQQNxIRsgAUEDSQRAIB1BsAFqIQFCACECDAILIBhB/P///wdxIRkgHUGwAWohAUIAIQIDQCABIAE1AgBCBX4gAnwiAj4CACABQQRqIhggGDUCAEIFfiACQiCIfCICPgIAIAFBCGoiGCAYNQIAQgV+IAJCIIh8IgI+AgAgAUEMaiIYIBg1AgBCBX4gAkIgiHwiAj4CACACQiCIIQIgAUEQaiEBIBlBBGsiGQ0ACwwBCwwVCyAbBEADQCABIAE1AgBCBX4gAnwiAj4CACABQQRqIQEgAkIgiCECIBtBAWsiGw0ACwsgAqciAUUNACAcQSdLDQEgHUGwAWogHEECdGogATYCACAcQQFqIRwLIB0gHDYC0AIgHSgCqAEiASAcIAEgHEsbIgFBKU8NBSABQQJ0IQECQANAIAEEQEF/IAFBBGsiASAdQbABamooAgAiGCABIB1BCGpqKAIAIhlHIBggGUsbIhtFDQEMAgsLQX9BACABGyEbCwJAAkAgG0H/AXEOAgABBQsgAEUNBCAiQQFrIgAgGk8NAiAAIB5qLQAAQQFxRQ0ECyAaICJJDQJBACEBIB4hGwJAA0AgASAiRg0BIAFBAWohASAbQQFrIhsgImoiAC0AAEE5Rg0ACyAAIAAtAABBAWo6AAAgIiAiIAFrQQFqTQ0EIABBAWpBMCABQQFrEM4DGgwECwJ/QTEgIkUNABogHkExOgAAQTAgIkEBRg0AGiAeQQFqQTAgIkEBaxDOAxpBMAshACAlQRB0QYCABGpBEHUiJSAtwUwgGiAiTXINAyAeICJqIAA6AAAgIkEBaiEiDAMLIBxBKEGYjsMAENgBAAsgACAaQezjwgAQ2AEACyAiIBpB/OPCABClAwALIBogIk8NACAiIBpBjOTCABClAwALIC4gJTsBCCAuICI2AgQgLiAeNgIAIB1B0AZqJAAMAwsgAUEoQZiOwwAQpQMAC0GojsMAQRpBmI7DABCTAgALIB9ByAhqIB9BmAhqKAIANgIAIB8gHykDkAg3A8AICyAtIB8uAcgIIgBIBEAgH0EIaiAfKALACCAfKALECCAAICcgH0GQCGoQcSAfKAIMIQAgHygCCAwEC0ECIQAgH0ECOwGQCCAnBEAgH0GgCGogJzYCACAfQQA7AZwIIB9BAjYCmAggH0GY9MIANgKUCCAfQZAIagwEC0EBIQAgH0EBNgKYCCAfQZ30wgA2ApQIIB9BkAhqDAMLQQIhACAfQQI7AZAIICcEQCAfQaAIaiAnNgIAIB9BADsBnAggH0ECNgKYCCAfQZj0wgA2ApQIIB9BkAhqDAMLQQEhACAfQQE2ApgIIB9BnfTCADYClAggH0GQCGoMAgsgH0EDNgKYCCAfQZ70wgA2ApQIIB9BAjsBkAggH0GQCGoMAQsgH0EDNgKYCCAfQaH0wgA2ApQIIB9BAjsBkAggH0GQCGoLIQEgH0HMCGogADYCACAfIAE2AsgIIB8gLDYCxAggHyAyNgLACCAkIB9BwAhqEFYgH0HwCGokAAwCC0Gk9MIAQSVBzPTCABCTAgALIABBKEGYjsMAEKUDAAsPCyABQQAhASMAQYABayIgJAAgOr0hAgJAIDogOmIEQEECIQAMAQsgAkL/////////B4MiBkKAgICAgICACIQgAkIBhkL+////////D4MgAkI0iKdB/w9xIhkbIgNCAYMhBUEDIQACQAJAAkBBAUECQQQgAkKAgICAgICA+P8AgyIHUCIcGyAHQoCAgICAgID4/wBRG0EDQQQgHBsgBlAbQQJrDgMAAQIDC0EEIQAMAgsgGUGzCGshASAFUCEAQgEhBAwBC0KAgICAgICAICADQgGGIANCgICAgICAgAhRIgEbIQNCAkIBIAEbIQQgBVAhAEHLd0HMdyABGyAZaiEBCyAgIAE7AXggICAENwNwICBCATcDaCAgIAM3A2AgICAAOgB6An8gAEECRgRAQazcwgAhLUEADAELIBhFBEBBm/TCAEGs3MIAIAJCAFMbIS0gAkI/iKcMAQtBm/TCAEGc9MIAIAJCAFMbIS1BAQshMkEBIQECfwJAAkACQAJAQQMgAEECayAAQQFNG0H/AXFBAWsOAwIBAAMLICBBIGohGSAgQQ9qIRojAEEwayIYJAACQAJAAkACQAJAAkACQCAgQeAAaiIAKQMAIgJQRQRAIAApAwgiBFBFBEAgACkDECIDUEUEQCACIAIgA3wiA1gEQCACIARaBEACQAJAIANC//////////8fWARAIBggAC8BGCIAOwEIIBggAiAEfSIENwMAIAAgAEEgayAAIANCgICAgBBUIgEbIhxBEGsgHCADQiCGIAMgARsiA0KAgICAgIDAAFQiARsiHEEIayAcIANCEIYgAyABGyIDQoCAgICAgICAAVQiARsiHEEEayAcIANCCIYgAyABGyIDQoCAgICAgICAEFQiARsiHEECayAcIANCBIYgAyABGyIDQoCAgICAgICAwABUIgEbIANCAoYgAyABGyIFQj+Hp0F/c2oiAWvBIhxBAEgNAiAYQn8gHK0iBogiAyAEgzcDECADIARUDQ0gGCAAOwEIIBggAjcDACAYIAIgA4M3AxAgAiADVg0NQaB/IAFrwUHQAGxBsKcFakHOEG0iAEHRAE8NASAAQQR0IgBBoOTCAGopAwAiB0L/////D4MiAyACIAZCP4MiAoYiCEIgiCIOfiIJQiCIIhQgB0IgiCIGIA5+fCAGIAhC/////w+DIgd+IghCIIgiFXwgCUL/////D4MgAyAHfkIgiHwgCEL/////D4N8QoCAgIAIfEIgiCEQQgFBACABIABBqOTCAGovAQBqa0E/ca0iCYYiB0IBfSEMIAMgBCAChiICQiCIIgR+IghC/////w+DIAMgAkL/////D4MiAn5CIIh8IAIgBn4iAkL/////D4N8QoCAgIAIfEIgiCENIAQgBn4hBCACQiCIIQIgCEIgiCEIIABBquTCAGovAQAhAAJ/AkACQCAGIAUgBUJ/hUI/iIYiBUIgiCIRfiIWIAMgEX4iCkIgiCISfCAGIAVC/////w+DIgV+Ig9CIIgiE3wgCkL/////D4MgAyAFfkIgiHwgD0L/////D4N8QoCAgIAIfEIgiCIPfEIBfCIKIAmIpyIBQZDOAE8EQCABQcCEPUkNASABQYDC1y9JDQJBCEEJIAFBgJTr3ANJIhwbIRtBgMLXL0GAlOvcAyAcGwwDCyABQeQATwRAQQJBAyABQegHSSIcGyEbQeQAQegHIBwbDAMLIAFBCUshG0EBQQogAUEKSRsMAgtBBEEFIAFBoI0GSSIcGyEbQZDOAEGgjQYgHBsMAQtBBkEHIAFBgK3iBEkiHBshG0HAhD1BgK3iBCAcGwshHCAQfCELIAogDIMhAyAbIABrQQFqISQgCiAEIAh8IAJ8IA18Ihd9QgF8Ig0gDIMhBEEAIQADQCABIBxuIR8CQAJAAkAgAEERRwRAIAAgGmoiISAfQTBqIh06AAAgDSABIBwgH2xrIgGtIAmGIgggA3wiAlYNDSAAIBtHDQNBESAAQQFqIgAgAEERTRshAUIBIQIDQCACIQUgBCEGIAAgAUYNAiAAIBpqIANCCn4iAyAJiKdBMGoiHDoAACAAQQFqIQAgBUIKfiECIAZCCn4iBCADIAyDIgNYDQALIABBAWsiG0ERTw0CIAQgA30iCSAHWiEBIAIgCiALfX4iCiACfCEIIAcgCVYNDiAKIAJ9IgkgA1gNDiAaIBtqIRsgBkIKfiADIAd8fSEKIAcgCX0hDCAJIAN9IQtCACEGA0AgAyAHfCICIAlUIAYgC3wgAyAMfFpyRQRAQQEhAQwQCyAbIBxBAWsiHDoAACAGIAp8Ig0gB1ohASACIAlaDRAgBiAHfSEGIAIhAyAHIA1YDQALDA8LQRFBEUG88MIAENgBAAsgAUERQdzwwgAQ2AEACyAAQRFB7PDCABClAwALIABBAWohACAcQQpJIBxBCm4hHEUNAAtBoPDCAEEZQZDwwgAQkwIAC0HQ78IAQS1BgPDCABCTAgALIABB0QBB4O7CABDYAQALQazcwgBBHUHs3MIAEJMCAAtBtOHCAEE3QbDvwgAQkwIAC0Hs4MIAQTZBoO/CABCTAgALQcDgwgBBHEGQ78IAEJMCAAtBkODCAEEdQYDvwgAQkwIAC0Hj38IAQRxB8O7CABCTAgALIABBAWohAQJAIABBEUkEQCANIAJ9IgQgHK0gCYYiBVohACAKIAt9IglCAXwhByAEIAVUIAlCAX0iCSACWHINASADIAV8IgIgFHwgFXwgEHwgBiAOIBF9fnwgEn0gE30gD30hBiASIBN8IA98IBZ8IQRCACALIAMgCHx8fSEMQgIgFyACIAh8fH0hCwNAIAIgCHwiDiAJVCAEIAx8IAYgCHxackUEQCADIAh8IQJBASEADAMLICEgHUEBayIdOgAAIAMgBXwhAyAEIAt8IQogCSAOVgRAIAIgBXwhAiAFIAZ8IQYgBCAFfSEEIAUgClgNAQsLIAUgClghACADIAh8IQIMAQsgAUERQczwwgAQpQMACwJAAkAgAEUgAiAHWnJFBEAgAiAFfCIDIAdUIAcgAn0gAyAHfVpyDQELIAIgDUIEfVggAkICWnENASAZQQA2AgAMBQsgGUEANgIADAQLIBkgJDsBCCAZIAE2AgQMAgsgAyECCwJAAkAgAUUgAiAIWnJFBEAgAiAHfCIDIAhUIAggAn0gAyAIfVpyDQELIAIgBUJYfiAEfFggAiAFQhR+WnENASAZQQA2AgAMAwsgGUEANgIADAILIBkgJDsBCCAZIAA2AgQLIBkgGjYCAAsgGEEwaiQADAELIBhBADYCICMAQSBrIgAkACAAIBg2AgQgACAYQRBqNgIAIABBGGogGEEYaiIBQRBqKQIANwMAIABBEGogAUEIaikCADcDACAAIAEpAgA3AwhBACAAQYD2wgAgAEEEakGA9sIAIABBCGpB/NzCABBsAAsCQCAgKAIgRQRAICBB0ABqIS4gIEEPaiEhIwBBwAprIgEkAAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQCAgQeAAaiIAKQMAIgJQRQRAIAApAwgiA1ANASAAKQMQIgRQDQIgAiAEfCIFIAJUDQMgAiADVA0EIAAsABohJiAALwEYIQAgASACPgIAIAFBAUECIAJCgICAgBBUIhgbNgKgASABQQAgAkIgiKcgGBs2AgQgAUEIakEAQZgBEM4DGiABIAM+AqgBIAFBAUECIANCgICAgBBUIhgbNgLIAiABQQAgA0IgiKcgGBs2AqwBIAFBsAFqQQBBmAEQzgMaIAEgBD4C0AIgAUEBQQIgBEKAgICAEFQiGBs2AvADIAFBACAEQiCIpyAYGzYC1AIgAUHYAmpBAEGYARDOAxogAUH4A2pBBHJBAEGcARDOAxogAUEBNgL4AyABQQE2ApgFIACtwyAFQgF9eX1CwprB6AR+QoChzaC0AnxCIIinIhjBISUCQCAAwSIZQQBOBEAgASAAED4aIAFBqAFqIAAQPhogAUHQAmogABA+GgwBCyABQfgDakEAIBlrwRA+GgsCQCAlQQBIBEAgAUEAICVrwSIAEEcgAUGoAWogABBHIAFB0AJqIAAQRwwBCyABQfgDaiAYQf//A3EQRwsgASgCoAEhGSABQZgJaiABQaABENADGiABIBk2ArgKIBkgASgC8AMiHCAZIBxLGyIYQShLDQ8gGEUEQEEAIRgMBwsgGEEBcSEkIBhBAUYNBSAYQX5xIR0gAUGYCWohACABQdACaiEaA0AgACAeIAAoAgAiHyAaKAIAaiIbaiInNgIAIABBBGoiHiAeKAIAIiwgGkEEaigCAGoiHiAbIB9JIBsgJ0tyaiIbNgIAIB4gLEkgGyAeSXIhHiAaQQhqIRogAEEIaiEAIB0gI0ECaiIjRw0ACwwFC0Hj38IAQRxBgODCABCTAgALQZDgwgBBHUGw4MIAEJMCAAtBwODCAEEcQdzgwgAQkwIAC0Hs4MIAQTZBpOHCABCTAgALQbThwgBBN0Hs4cIAEJMCAAsgJAR/ICNBAnQiACABQZgJamoiGyAbKAIAIhsgAUHQAmogAGooAgBqIgAgHmoiGjYCACAAIBtJIAAgGktyBSAeC0UNACAYQSdLDRQgAUGYCWogGEECdGpBATYCACAYQQFqIRgLIAEgGDYCuAogASgCmAUiGyAYIBggG0kbIgBBKU8NCSAAQQJ0IQACQANAIAAEQEF/IABBBGsiACABQZgJamooAgAiGCAAIAFB+ANqaigCACIaRyAYIBpLGyIaRQ0BDAILC0F/QQAgABshGgsgGiAmTgRAIBlBKU8NDCAZRQRAQQAhGQwDCyAZQQFrQf////8DcSIAQQFqIhhBA3EhGiAAQQNJBEAgASEAQgAhAgwCCyAYQfz///8HcSEeIAEhAEIAIQIDQCAAIAA1AgBCCn4gAnwiAj4CACAAQQRqIhggGDUCAEIKfiACQiCIfCICPgIAIABBCGoiGCAYNQIAQgp+IAJCIIh8IgI+AgAgAEEMaiIYIBg1AgBCCn4gAkIgiHwiAj4CACACQiCIIQIgAEEQaiEAIB5BBGsiHg0ACwwBCyAlQQFqISUMBgsgGgRAA0AgACAANQIAQgp+IAJ8IgI+AgAgAEEEaiEAIAJCIIghAiAaQQFrIhoNAAsLIAKnIgBFDQAgGUEnSw0BIAEgGUECdGogADYCACAZQQFqIRkLIAEgGTYCoAEgASgCyAIiGEEpTw0GIBhFBEBBACEYDAMLIBhBAWtB/////wNxIgBBAWoiGUEDcSEaIABBA0kEQCABQagBaiEAQgAhAgwCCyAZQfz///8HcSEeIAFBqAFqIQBCACECA0AgACAANQIAQgp+IAJ8IgI+AgAgAEEEaiIZIBk1AgBCCn4gAkIgiHwiAj4CACAAQQhqIhkgGTUCAEIKfiACQiCIfCICPgIAIABBDGoiGSAZNQIAQgp+IAJCIIh8IgI+AgAgAkIgiCECIABBEGohACAeQQRrIh4NAAsMAQsgGUEoQZiOwwAQ2AEACyAaBEADQCAAIAA1AgBCCn4gAnwiAj4CACAAQQRqIQAgAkIgiCECIBpBAWsiGg0ACwsgAqciAEUNACAYQSdLDQ8gAUGoAWogGEECdGogADYCACAYQQFqIRgLIAEgGDYCyAIgHEEpTw0PIBxFBEAgAUEANgLwAwwCCyAcQQFrQf////8DcSIAQQFqIhhBA3EhGiAAQQNJBEAgAUHQAmohAEIAIQIMAQsgGEH8////B3EhHiABQdACaiEAQgAhAgNAIAAgADUCAEIKfiACfCICPgIAIABBBGoiGCAYNQIAQgp+IAJCIIh8IgI+AgAgAEEIaiIYIBg1AgBCCn4gAkIgiHwiAj4CACAAQQxqIhggGDUCAEIKfiACQiCIfCICPgIAIAJCIIghAiAAQRBqIQAgHkEEayIeDQALDAALIBoEQANAIAAgADUCAEIKfiACfCICPgIAIABBBGohACACQiCIIQIgGkEBayIaDQALCyABIAKnIgAEfyAcQSdLDQIgAUHQAmogHEECdGogADYCACAcQQFqBSAcCzYC8AMLIAFBoAVqIhggAUH4A2oiAEGgARDQAxogASAbNgLABiAYQQEQPiEzIAEoApgFIRggAUHIBmoiGSAAQaABENADGiABIBg2AugHIBlBAhA+ITQgASgCmAUhGCABQfAHaiIZIABBoAEQ0AMaIAEgGDYCkAkgGUEDED4hNQJAIAEoAqABIhkgASgCkAkiLCAZICxLGyIYQShNBEAgAUGcBWohNiABQcQGaiE3IAFB7AdqITggASgCmAUhJyABKALABiEvIAEoAugHITBBACEcA0AgGEECdCEAAkADQCAABEBBfyAAIDhqKAIAIhsgAEEEayIAIAFqKAIAIhpHIBogG0kbIhpFDQEMAgsLQX9BACAAGyEaC0EAISQgGkEBTQRAIBgEQEEBIR5BACEjIBhBAUcEQCAYQX5xISQgASIAQfAHaiEaA0AgACAeIAAoAgAiHSAaKAIAQX9zaiIZaiIeNgIAIABBBGoiGyAbKAIAIh8gGkEEaigCAEF/c2oiGyAZIB1JIBkgHktyaiIZNgIAIBkgG0kgGyAfSXIhHiAaQQhqIRogAEEIaiEAICQgI0ECaiIjRw0ACwsgGEEBcQR/IAEgI0ECdCIAaiIZIBkoAgAiGSAAIDVqKAIAQX9zaiIAIB5qIhs2AgAgACAZSSAAIBtLcgUgHgtFDQgLIAEgGDYCoAFBCCEkIBghGQsgGSAwIBkgMEsbIhhBKU8NBCAcIRsgGEECdCEAAkADQCAABEBBfyAAIDdqKAIAIhwgAEEEayIAIAFqKAIAIhpHIBogHEkbIhpFDQEMAgsLQX9BACAAGyEaCwJAIBpBAUsEQCAZIRgMAQsgGARAQQEhHkEAISMgGEEBRwRAIBhBfnEhHSABIgBByAZqIRoDQCAAIB4gACgCACIfIBooAgBBf3NqIhlqIh42AgAgAEEEaiIcIBwoAgAiKCAaQQRqKAIAQX9zaiIcIBkgH0kgGSAeS3JqIhk2AgAgGSAcSSAcIChJciEeIBpBCGohGiAAQQhqIQAgHSAjQQJqIiNHDQALCyAYQQFxBH8gASAjQQJ0IgBqIhkgGSgCACIZIAAgNGooAgBBf3NqIgAgHmoiHDYCACAAIBlJIAAgHEtyBSAeC0UNCAsgASAYNgKgASAkQQRyISQLAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAIBggLyAYIC9LGyIcQSlJBEAgHEECdCEAAkADQCAABEBBfyAAIDZqKAIAIhkgAEEEayIAIAFqKAIAIhpHIBkgGksbIhpFDQEMAgsLQX9BACAAGyEaCwJAIBpBAUsEQCAYIRwMAQsgHARAQQEhHkEAISMgHEEBRwRAIBxBfnEhHSABIgBBoAVqIRoDQCAAIB4gACgCACIfIBooAgBBf3NqIhhqIh42AgAgAEEEaiIZIBkoAgAiKCAaQQRqKAIAQX9zaiIZIBggH0kgGCAeS3JqIhg2AgAgGCAZSSAZIChJciEeIBpBCGohGiAAQQhqIQAgHSAjQQJqIiNHDQALCyAcQQFxBH8gASAjQQJ0IgBqIhggGCgCACIYIAAgM2ooAgBBf3NqIgAgHmoiGTYCACAAIBhJIAAgGUtyBSAeC0UNGAsgASAcNgKgASAkQQJqISQLIBwgJyAcICdLGyIZQSlPDRcgGUECdCEAAkADQCAABEBBfyAAQQRrIgAgAUH4A2pqKAIAIhggACABaigCACIaRyAYIBpLGyIaRQ0BDAILC0F/QQAgABshGgsCQCAaQQFLBEAgHCEZDAELIBkEQEEBIR5BACEjIBlBAUcEQCAZQX5xIR0gASIAQfgDaiEaA0AgACAeIAAoAgAiHyAaKAIAQX9zaiIYaiIeNgIAIABBBGoiHCAcKAIAIiggGkEEaigCAEF/c2oiHCAYIB9JIBggHktyaiIYNgIAIBggHEkgHCAoSXIhHiAaQQhqIRogAEEIaiEAIB0gI0ECaiIjRw0ACwsgGUEBcQR/IAEgI0ECdCIAaiIYIBgoAgAiGCABQfgDaiAAaigCAEF/c2oiACAeaiIcNgIAIAAgGEkgACAcS3IFIB4LRQ0YCyABIBk2AqABICRBAWohJAsgG0ERRg0CIBsgIWogJEEwajoAACAZIAEoAsgCIh8gGSAfSxsiAEEpTw0VIBtBAWohHCAAQQJ0IQACQANAIAAEQEF/IABBBGsiACABQagBamooAgAiGCAAIAFqKAIAIhpHIBggGksbIhhFDQEMAgsLQX9BACAAGyEYCyABQZgJaiABQaABENADGiABIBk2ArgKIBkgASgC8AMiHSAZIB1LGyIkQShLDQQCQCAkRQRAQQAhJAwBC0EAIR5BACEjICRBAUcEQCAkQX5xITkgAUGYCWohACABQdACaiEaA0AgACAeIAAoAgAiKSAaKAIAaiIoaiIqNgIAIABBBGoiHiAeKAIAIisgGkEEaigCAGoiHiAoIClJICggKktyaiIoNgIAIB4gK0kgHiAoS3IhHiAaQQhqIRogAEEIaiEAIDkgI0ECaiIjRw0ACwsgJEEBcQR/ICNBAnQiACABQZgJamoiGiAeIBooAgAiGiABQdACaiAAaigCAGoiAGoiHjYCACAAIBpJIAAgHktyBSAeC0UNACAkQSdLDQIgAUGYCWogJEECdGpBATYCACAkQQFqISQLIAEgJDYCuAogJyAkICQgJ0kbIgBBKU8NFSAAQQJ0IQACQANAIAAEQEF/IABBBGsiACABQZgJamooAgAiGiAAIAFB+ANqaigCACIeRyAaIB5LGyIaRQ0BDAILC0F/QQAgABshGgsgGCAmSCAaICZIckUEQCAZQSlPDRggGUUEQEEAIRkMCQsgGUEBa0H/////A3EiAEEBaiIYQQNxIRogAEEDSQRAIAEhAEIAIQIMCAsgGEH8////B3EhHiABIQBCACECA0AgACAANQIAQgp+IAJ8IgI+AgAgAEEEaiIYIBg1AgBCCn4gAkIgiHwiAj4CACAAQQhqIhggGDUCAEIKfiACQiCIfCICPgIAIABBDGoiGCAYNQIAQgp+IAJCIIh8IgI+AgAgAkIgiCECIABBEGohACAeQQRrIh4NAAsMBwsgGiAmTg0FIBggJkgEQCABQQEQPhogASgCoAEiACABKAKYBSIYIAAgGEsbIgBBKU8NFiAAQQJ0IQAgAUEEayEYIAFB9ANqIRkCQANAIAAEQCAAIBhqIRogACAZaiEeIABBBGshAEF/IB4oAgAiHiAaKAIAIhpHIBogHkkbIhpFDQEMAgsLQX9BACAAGyEaCyAaQQJPDQYLIBtBEU8NA0F/IRogGyEAAkADQCAAQX9GDQEgGkEBaiEaIAAgIWogAEEBayEALQAAQTlGDQALIAAgIWoiGEEBaiIZIBktAABBAWo6AAAgGyAAQQJqSQ0GIBhBAmpBMCAaEM4DGgwGCyAhQTE6AAAgGwRAICFBAWpBMCAbEM4DGgsgHEERSQRAIBwgIWpBMDoAACAlQQFqISUgG0ECaiEcDAYLIBxBEUHc4sIAENgBAAsMHwsgJEEoQZiOwwAQ2AEAC0ERQRFBvOLCABDYAQALIBxBEUHM4sIAEKUDAAsgJEEoQZiOwwAQpQMACyAcQRFNBEAgLiAlOwEIIC4gHDYCBCAuICE2AgAgAUHACmokAAwUCyAcQRFB7OLCABClAwALIBoEQANAIAAgADUCAEIKfiACfCICPgIAIABBBGohACACQiCIIQIgGkEBayIaDQALCyACpyIARQ0AIBlBJ0sNASABIBlBAnRqIAA2AgAgGUEBaiEZCyABIBk2AqABIB9BKU8NASAfRQRAQQAhHwwECyAfQQFrQf////8DcSIAQQFqIhhBA3EhGiAAQQNJBEAgAUGoAWohAEIAIQIMAwsgGEH8////B3EhHiABQagBaiEAQgAhAgNAIAAgADUCAEIKfiACfCICPgIAIABBBGoiGCAYNQIAQgp+IAJCIIh8IgI+AgAgAEEIaiIYIBg1AgBCCn4gAkIgiHwiAj4CACAAQQxqIhggGDUCAEIKfiACQiCIfCICPgIAIAJCIIghAiAAQRBqIQAgHkEEayIeDQALDAILIBlBKEGYjsMAENgBAAsgH0EoQZiOwwAQpQMACyAaBEADQCAAIAA1AgBCCn4gAnwiAj4CACAAQQRqIQAgAkIgiCECIBpBAWsiGg0ACwsgAqciAEUNACAfQSdLDQEgAUGoAWogH0ECdGogADYCACAfQQFqIR8LIAEgHzYCyAIgHUEpTw0BIB1FBEBBACEdDAQLIB1BAWtB/////wNxIgBBAWoiGEEDcSEaIABBA0kEQCABQdACaiEAQgAhAgwDCyAYQfz///8HcSEeIAFB0AJqIQBCACECA0AgACAANQIAQgp+IAJ8IgI+AgAgAEEEaiIYIBg1AgBCCn4gAkIgiHwiAj4CACAAQQhqIhggGDUCAEIKfiACQiCIfCICPgIAIABBDGoiGCAYNQIAQgp+IAJCIIh8IgI+AgAgAkIgiCECIABBEGohACAeQQRrIh4NAAsMAgsgH0EoQZiOwwAQ2AEACyAdQShBmI7DABClAwALIBoEQANAIAAgADUCAEIKfiACfCICPgIAIABBBGohACACQiCIIQIgGkEBayIaDQALCyACpyIARQ0AIB1BJ0sNAyABQdACaiAdQQJ0aiAANgIAIB1BAWohHQsgASAdNgLwAyAZICwgGSAsSxsiGEEoTQ0ACwsMAgsgHUEoQZiOwwAQ2AEACyAcQShBmI7DABDYAQALIBhBKEGYjsMAEKUDAAsgAEEoQZiOwwAQpQMAC0GojsMAQRpBmI7DABCTAgALIBlBKEGYjsMAEKUDAAsgIEHYAGogIEEoaigCADYCACAgICApAyA3A1ALICAgICgCUCAgKAJUICAvAVhBACAgQSBqEHEgICgCBCEBICAoAgAMAwsgIEECOwEgICBBATYCKCAgQZ30wgA2AiQgIEEgagwCCyAgQQM2AiggIEGe9MIANgIkICBBAjsBICAgQSBqDAELICBBAzYCKCAgQaH0wgA2AiQgIEECOwEgICBBIGoLIQAgIEHcAGogATYCACAgIAA2AlggICAyNgJUICAgLTYCUCAgQdAAahBWICBBgAFqJAAPCyAYQShBmI7DABClAwALIBhBKEGYjsMAENgBAAsgHEEoQZiOwwAQpQMACzoBAX8jAEEQayIDJAAgA0EIaiABIAIQWAJAIAMoAghFBEAgACABEDcMAQsgAEEHNgIACyADQRBqJAALOQACQAJ/IAJBgIDEAEcEQEEBIAAgAiABKAIQEQAADQEaCyADDQFBAAsPCyAAIAMgBCABKAIMEQIACzsBAX8jAEEQayICJAAgAiAAKAIANgIMIAFB2sTAAEEMQebEwABBDyACQQxqQfjEwAAQvgEgAkEQaiQACzsBAX8jAEEQayICJAAgAiAAKAIANgIMIAFB+NPAAEEKQaTSwABBBCACQQxqQYTUwAAQvgEgAkEQaiQACzsBAX8jAEEQayICJAAgAiAAKAIANgIMIAFBsPLAAEELQbvywABBBSACQQxqQcDywAAQvgEgAkEQaiQACzsBAX8jAEEQayICJAAgAiAAKAIANgIMIAFBk/3AAEEOQaH9wABBBSACQQxqQaj9wAAQvgEgAkEQaiQACzsBAX8jAEEQayICJAAgAiAAKAIANgIMIAFBtqPCAEETQcmjwgBBCiACQQxqQdSjwgAQvgEgAkEQaiQACzsBAX8jAEEQayICJAAgAiAAKAIANgIMIAFBrLHCAEETQb+xwgBBBCACQQxqQcSxwgAQvgEgAkEQaiQAC+QCAQJ/IwBBIGsiAiQAIAJBAToAGCACIAE2AhQgAiAANgIQIAJB6PXCADYCDCACQazcwgA2AggjAEEQayIBJAACQCACQQhqIgAoAgwiAgRAIAAoAggiA0UNASABIAI2AgggASAANgIEIAEgAzYCACMAQRBrIgAkACAAQQhqIAFBCGooAgA2AgAgACABKQIANwMAIwBBEGsiASQAIAAoAgAiAkEUaigCACEDAkACfwJAAkAgAkEMaigCAA4CAAEDCyADDQJBACECQZTDwgAMAQsgAw0BIAIoAggiAygCBCECIAMoAgALIQMgASACNgIEIAEgAzYCACABQdzMwgAgACgCBCIBKAIIIAAoAgggAS0AEBC1AQALIAFBADYCBCABIAI2AgwgAUHIzMIAIAAoAgQiASgCCCAAKAIIIAEtABAQtQEAC0GUw8IAQStBmMzCABCTAgALQZTDwgBBK0GIzMIAEJMCAAs2AQF/IwBBEGsiAiQAIAJBCGogARDEAiACKAIMIQEgACACKAIINgIAIAAgATYCBCACQRBqJAALNgEBfyMAQRBrIgIkACACQQhqIAEQ7AIgAigCDCEBIAAgAigCCDYCACAAIAE2AgQgAkEQaiQAC0kBAn9BjvvAACECQQQhAwJAAkACQCAAKAIALQAAQQFrDgIAAQILIAFBhPvAAEEKEIUDDwtB/PrAACECQQghAwsgASACIAMQhQML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QdcAIABBD3EiBEEKSRsgBGo6AAAgAkEBayECIAAiBEEEdiEAIARBD0sNAAsgAkGAAWoiAEGBAU8EQCAAQYABQYz4wgAQpAMACyABQQFBnPjCAEECIAIgA2pBgAFqQQAgAmsQSSADQYABaiQACywBAX8jAEEQayIAJAAgAEEIaiICIAFBv8PCAEELEMcCIAIQ4AEgAEEQaiQACy4AIABBBDoABCAAQQQ2AgAgAEEGaiACOgAAIABBBWogAToAACAAQRRqQQA7AQALKwAgASACTwRAIAEgAmsiASAAIAFqIAIQQA8LQYCvwABBIUGkr8AAEJMCAAssACAAIAEpAgA3AgAgAEEQaiABQRBqKAIANgIAIABBCGogAUEIaikCADcCAAsxACAAIAEoAgAgAiADIAEoAgQoAgwRAgA6AAggACABNgIEIAAgA0U6AAkgAEEANgIACykAIAEgAk8EQCACIAAgAmogASACaxBADwtBwKzAAEEjQfCuwAAQkwIACy4AIAEgACgCAC0AAEEEc0EHcUECdCIAQdj/wABqKAIAIABBuP/AAGooAgAQhQMLKgAgACgCAEUEQCAAKAIEIAEgAEEIaigCACgCEBEAAA8LIABBBGogARBwCywAAkAgARCbA0UEQCABEJwDDQEgACABEMsCDwsgACABEMUBDwsgACABEMYBCycAIAAgACgCBEEBcSABckECcjYCBCAAIAFqIgAgACgCBEEBcjYCBAstAQF/IABB4LDCAEGksMIAIAEtAABBBEYiAhs2AgQgACABQQFqIAEgAhs2AgALOgECf0HMmcMALQAAIQFBzJnDAEEAOgAAQdCZwwAoAgAhAkHQmcMAQQA2AgAgACACNgIEIAAgATYCAAsxACAAQQM6ACAgAEKAgICAgAQ3AhggAEEANgIQIABBADYCCCAAIAI2AgQgACABNgIACy0AIAEoAgAgAiADIAEoAgQoAgwRAgAhAiAAQQA6AAUgACACOgAEIAAgATYCAAsgAQF/AkAgAEEEaigCACIBRQ0AIAAoAgBFDQAgARA9CwsjAAJAIAFB/P///wdNBEAgACABQQQgAhD/AiIADQELAAsgAAsjACACIAIoAgRBfnE2AgQgACABQQFyNgIEIAAgAWogATYCAAsfACAAKAIAIgCtQgAgAKx9IABBAE4iABsgACABEIABCyUAIABFBEBBxL3AAEEyEMUDAAsgACACIAMgBCAFIAEoAhARDAALIwAgAEEANgIQIAAgASkCADcCACAAQQhqIAFBCGopAgA3AgALKAAgASAAKAIALQAAQQJ0IgBBoNnAAGooAgAgAEHk2MAAaigCABCFAwsoACABIAAoAgAtAABBAnQiAEGMicEAaigCACAAQeyIwQBqKAIAEIUDCygAIAEgACgCAC0AAEECdCIAQYTXwgBqKAIAIABB4NXCAGooAgAQhQMLIAECfiAAKQMAIgIgAkI/hyIDhSADfSACQgBZIAEQgAELIwAgAEUEQEHEvcAAQTIQxQMACyAAIAIgAyAEIAEoAhARBgALIwAgAEUEQEHEvcAAQTIQxQMACyAAIAIgAyAEIAEoAhARFgALIwAgAEUEQEHEvcAAQTIQxQMACyAAIAIgAyAEIAEoAhARJAALIwAgAEUEQEHEvcAAQTIQxQMACyAAIAIgAyAEIAEoAhARJgALIwAgAEUEQEHEvcAAQTIQxQMACyAAIAIgAyAEIAEoAhARKAALJQAgASAALQAAQQJ0IgBBgNjAAGooAgAgAEHY18AAaigCABCFAwshACAAQYzbwAA2AgQgACABQQRqQQAgAS0AAEEfRhs2AgALJQAgASAALQAAQQJ0IgBBhNfCAGooAgAgAEHg1cIAaigCABCFAwseACAAIAFBA3I2AgQgACABaiIAIAAoAgRBAXI2AgQLCgAgAEEIEMoDAAsUACAAKAIABEAgAEEEaigCABA9CwsiAQF/IAEoAgAQCSECIAAgATYCCCAAIAI2AgQgAEEANgIACyEAIABFBEBBxL3AAEEyEMUDAAsgACACIAMgASgCEBEFAAsjACABQez6wABB8frAACAAKAIALQAAIgAbQQVBCyAAGxCFAwsjACABQZL7wABBlvvAACAAKAIALQAAIgAbQQRBBiAAGxCFAwssAQF/AkACQCAAQf8BcUEBaw4QAAABAAEBAQABAQEBAQEBAAELIAAhAQsgAQvvDAEEfyAAIAApAwAgAq18NwMAIABBCGoiBSgCAEF/cyEDIAJBwABPBEADQCABLQAzIAEtACMgAS0AEyABLQAAIANB/wFxc0ECdEHYlMIAaigCACABQQFqLQAAIANBCHZB/wFxc0ECdEHYjMIAaigCACABQQJqLQAAIANBEHZB/wFxc0ECdEHYhMIAaigCACABQQNqLQAAIANBGHZzQQJ0Qdj8wQBqKAIAIAFBBGotAABBAnRB2PTBAGooAgAgAUEFai0AAEECdEHY7MEAaigCACABQQZqLQAAQQJ0QdjkwQBqKAIAIAFBB2otAABBAnRB2NzBAGooAgAgAUEIai0AAEECdEHY1MEAaigCACABQQlqLQAAQQJ0QdjMwQBqKAIAIAFBCmotAABBAnRB2MTBAGooAgAgAUELai0AAEECdEHYvMEAaigCACABQQxqLQAAQQJ0Qdi0wQBqKAIAIAFBDWotAABBAnRB2KzBAGooAgAgAUEPai0AAEECdEHYnMEAaigCACABQQ5qLQAAQQJ0QdikwQBqKAIAc3Nzc3Nzc3Nzc3Nzc3NzIgBBGHZzQQJ0Qdj8wQBqKAIAIAEtABRBAnRB2PTBAGooAgAgAS0AFUECdEHY7MEAaigCACABLQAWQQJ0QdjkwQBqKAIAIAEtABdBAnRB2NzBAGooAgAgAS0AGEECdEHY1MEAaigCACABLQAZQQJ0QdjMwQBqKAIAIAEtABpBAnRB2MTBAGooAgAgAS0AG0ECdEHYvMEAaigCACABLQAcQQJ0Qdi0wQBqKAIAIAEtAB1BAnRB2KzBAGooAgAgAS0AH0ECdEHYnMEAaigCACABLQAeQQJ0QdikwQBqKAIAc3Nzc3Nzc3Nzc3NzIAEtABIgAEEQdkH/AXFzQQJ0QdiEwgBqKAIAcyABLQARIABBCHZB/wFxc0ECdEHYjMIAaigCAHMgAS0AECAAQf8BcXNBAnRB2JTCAGooAgBzIgBBGHZzQQJ0Qdj8wQBqKAIAIAEtACRBAnRB2PTBAGooAgAgAS0AJUECdEHY7MEAaigCACABLQAmQQJ0QdjkwQBqKAIAIAEtACdBAnRB2NzBAGooAgAgAS0AKEECdEHY1MEAaigCACABLQApQQJ0QdjMwQBqKAIAIAEtACpBAnRB2MTBAGooAgAgAS0AK0ECdEHYvMEAaigCACABLQAsQQJ0Qdi0wQBqKAIAIAEtAC1BAnRB2KzBAGooAgAgAS0AL0ECdEHYnMEAaigCACABLQAuQQJ0QdikwQBqKAIAc3Nzc3Nzc3Nzc3NzIAEtACIgAEEQdkH/AXFzQQJ0QdiEwgBqKAIAcyABLQAhIABBCHZB/wFxc0ECdEHYjMIAaigCAHMgAS0AICAAQf8BcXNBAnRB2JTCAGooAgBzIgBBGHZzQQJ0Qdj8wQBqKAIAIAEtADRBAnRB2PTBAGooAgAgAS0ANUECdEHY7MEAaigCACABLQA2QQJ0QdjkwQBqKAIAIAEtADdBAnRB2NzBAGooAgAgAS0AOEECdEHY1MEAaigCACABLQA5QQJ0QdjMwQBqKAIAIAEtADpBAnRB2MTBAGooAgAgAS0AO0ECdEHYvMEAaigCACABLQA8QQJ0Qdi0wQBqKAIAIAEtAD1BAnRB2KzBAGooAgAgAS0APkECdEHYpMEAaigCACABLQA/QQJ0QdicwQBqKAIAc3Nzc3Nzc3Nzc3NzIAEtADIgAEEQdkH/AXFzQQJ0QdiEwgBqKAIAcyABLQAxIABBCHZB/wFxc0ECdEHYjMIAaigCAHMgAS0AMCAAQf8BcXNBAnRB2JTCAGooAgBzIQMgAUFAayEBIAJBQGoiAkE/Sw0ACwsCQCACRQ0AIAJBAWsCQCACQQNxIgRFBEAgASEADAELIAEhAANAIAAtAAAgA3NB/wFxQQJ0QdicwQBqKAIAIANBCHZzIQMgAEEBaiEAIARBAWsiBA0ACwtBA0kNACABIAJqIQEDQCAALQAAIANzQf8BcUECdEHYnMEAaigCACADQQh2cyICIABBAWotAABzQf8BcUECdEHYnMEAaigCACACQQh2cyICIABBAmotAABzQf8BcUECdEHYnMEAaigCACACQQh2cyICIABBA2otAABzQf8BcUECdEHYnMEAaigCACACQQh2cyEDIABBBGoiACABRw0ACwsgBSADQX9zNgIACyMAIAFBjLHCAEGfscIAIAAoAgAtAAAiABtBE0ENIAAbEIUDCyIAIAAtAABFBEAgAUGg+8IAQQUQQw8LIAFBnPvCAEEEEEMLHwAgAEUEQEHEvcAAQTIQxQMACyAAIAIgASgCEBEAAAsdACABKAIARQRAAAsgAEG0wsAANgIEIAAgATYCAAsiACAAQQA2AhggAEEANgIQIABCgICAgAI3AwggAEIBNwMACxsAIAAoAgAiAEEEaigCACAAQQhqKAIAIAEQRAscACAAKAIAIgBBBGooAgAgAEEIaigCACABEMsDCxwAIAAgASkCADcCACAAQQhqIAFBCGooAgA2AgALHQAgASgCAEUEQAALIABB7JHBADYCBCAAIAE2AgALIQAgACABQQRqNgIAIABB8J3CAEGsnsIAIAEoAgAbNgIECx0AIAEoAgBFBEAACyAAQcilwgA2AgQgACABNgIACxwAIAAoAgAiACgCACABIABBBGooAgAoAgwRAAALHAAgACgCACIAKAIAIAEgAEEEaigCACgCEBEAAAsXACAAQfgAakEAIABBkQFqLQAAQQJHGwscACAAIAEoAgAgAiADIAQgBSABKAIEKAIMEQcACxkBAX8gACgCECIBBH8gAQUgAEEUaigCAAsLFAAgASABIAAgACABXRsgACAAXBsLFAAgACAAIAEgACABXRsgASABXBsLEQAgAMBBAnRBuP7AAGooAgALGAAgACgCACIAKAIAIABBBGooAgAgARBECxcAIABBBGooAgAgAEEIaigCACABEMsDCxYAIABBBGooAgAgAEEIaigCACABEEQLEgBBGSAAQQF2a0EAIABBH0cbCxYAIAAgAUEBcjYCBCAAIAFqIAE2AgALGAAgALxBgICAgHhxQf////cDcr4gAJKPCyEAIAC9QoCAgICAgICAgH+DQv/////////vP4S/IACgnQsTAQF/IAAtADkgAEEBOgA5QQFxCxAAIAAgAWpBAWtBACABa3ELkAYBBn8CfyAAIQUCQAJAAkAgAkEJTwRAIAMgAhBtIgcNAUEADAQLQQhBCBD+AiEAQRRBCBD+AiEBQRBBCBD+AiECQQBBEEEIEP4CQQJ0ayIEQYCAfCACIAAgAWpqa0F3cUEDayIAIAAgBEsbIANNDQFBECADQQRqQRBBCBD+AkEFayADSxtBCBD+AiECIAUQ3wMiACAAEMYDIgQQ3AMhAQJAAkACQAJAAkACQAJAIAAQnwNFBEAgAiAETQ0BIAFBzJ3DACgCAEYNAiABQcidwwAoAgBGDQMgARCYAw0HIAEQxgMiBiAEaiIIIAJJDQcgCCACayEEIAZBgAJJDQQgARCHAQwFCyAAEMYDIQEgAkGAAkkNBiABIAJrQYGACEkgAkEEaiABTXENBSABIAAoAgAiAWpBEGohBCACQR9qQYCABBD+AiECDAYLQRBBCBD+AiAEIAJrIgFLDQQgACACENwDIQQgACACEMMCIAQgARDDAiAEIAEQXAwEC0HEncMAKAIAIARqIgQgAk0NBCAAIAIQ3AMhASAAIAIQwwIgASAEIAJrIgJBAXI2AgRBxJ3DACACNgIAQcydwwAgATYCAAwDC0HAncMAKAIAIARqIgQgAkkNAwJAQRBBCBD+AiAEIAJrIgFLBEAgACAEEMMCQQAhAUEAIQQMAQsgACACENwDIgQgARDcAyEGIAAgAhDDAiAEIAEQ+gIgBiAGKAIEQX5xNgIEC0HIncMAIAQ2AgBBwJ3DACABNgIADAILIAFBDGooAgAiCSABQQhqKAIAIgFHBEAgASAJNgIMIAkgATYCCAwBC0G4ncMAQbidwwAoAgBBfiAGQQN2d3E2AgALQRBBCBD+AiAETQRAIAAgAhDcAyEBIAAgAhDDAiABIAQQwwIgASAEEFwMAQsgACAIEMMCCyAADQMLIAMQKyIBRQ0BIAEgBSAAEMYDQXhBfCAAEJ8DG2oiACADIAAgA0kbENADIAUQPQwDCyAHIAUgASADIAEgA0kbENADGiAFED0LIAcMAQsgABCfAxogABDeAwsLFgAgACgCACIAKAIAIAAoAgQgARDLAwsOACAAwEG518AAai0AAAsLACABBEAgABA9CwsPACAAQQF0IgBBACAAa3ILFQAgASAAKAIAIgAoAgAgACgCBBBDCxYAIAAoAgAgASACIAAoAgQoAgwRAgALGQAgASgCAEG0j8MAQQUgASgCBCgCDBECAAsRACAAQbwBakEAIAAoArgBGwsUACAAKAIAIAEgACgCBCgCEBEAAAsUACAAKAIAIAEgACgCBCgCDBEAAAvQCAEDfyMAQfAAayIFJAAgBSADNgIMIAUgAjYCCAJAAkACQAJAIAUCfwJAAkAgAUGBAk8EQANAIAAgBmogBkEBayEGQYACaiwAAEG/f0wNAAsgBkGBAmoiByABSQ0CIAFBgQJrIAZHDQQgBSAHNgIUDAELIAUgATYCFAsgBSAANgIQQazcwgAhBkEADAELIAAgBmpBgQJqLAAAQb9/TA0BIAUgBzYCFCAFIAA2AhBBgIDDACEGQQULNgIcIAUgBjYCGAJAIAEgAkkiBiABIANJckUEQAJ/AkACQCACIANNBEACQAJAIAJFDQAgASACTQRAIAEgAkYNAQwCCyAAIAJqLAAAQUBIDQELIAMhAgsgBSACNgIgIAIgASIGSQRAIAJBAWoiBiACQQNrIgNBACACIANPGyIDSQ0GIAAgBmogACADamshBgNAIAZBAWshBiAAIAJqIAJBAWshAiwAAEFASA0ACyACQQFqIQYLAkAgBkUNACABIAZNBEAgASAGRg0BDAoLIAAgBmosAABBv39MDQkLIAEgBkYNBwJAIAAgBmoiAiwAACIDQQBIBEAgAi0AAUE/cSEAIANBH3EhASADQV9LDQEgAUEGdCAAciEADAQLIAUgA0H/AXE2AiRBAQwECyACLQACQT9xIABBBnRyIQAgA0FwTw0BIAAgAUEMdHIhAAwCCyAFQeQAakG8AjYCACAFQdwAakG8AjYCACAFQdQAakHEADYCACAFQTxqQQQ2AgAgBUHEAGpBBDYCACAFQeSAwwA2AjggBUEANgIwIAVBxAA2AkwgBSAFQcgAajYCQCAFIAVBGGo2AmAgBSAFQRBqNgJYIAUgBUEMajYCUCAFIAVBCGo2AkgMCAsgAUESdEGAgPAAcSACLQADQT9xIABBBnRyciIAQYCAxABGDQULIAUgADYCJEEBIABBgAFJDQAaQQIgAEGAEEkNABpBA0EEIABBgIAESRsLIQAgBSAGNgIoIAUgACAGajYCLCAFQTxqQQU2AgAgBUHEAGpBBTYCACAFQewAakG8AjYCACAFQeQAakG8AjYCACAFQdwAakHAAjYCACAFQdQAakHBAjYCACAFQbiBwwA2AjggBUEANgIwIAVBxAA2AkwgBSAFQcgAajYCQCAFIAVBGGo2AmggBSAFQRBqNgJgIAUgBUEoajYCWCAFIAVBJGo2AlAgBSAFQSBqNgJIDAULIAUgAiADIAYbNgIoIAVBPGpBAzYCACAFQcQAakEDNgIAIAVB3ABqQbwCNgIAIAVB1ABqQbwCNgIAIAVBqIDDADYCOCAFQQA2AjAgBUHEADYCTCAFIAVByABqNgJAIAUgBUEYajYCWCAFIAVBEGo2AlAgBSAFQShqNgJIDAQLIAMgBkH8gcMAEKYDAAsgACABQQAgByAEEIoDAAtBnfHCAEErIAQQkwIACyAAIAEgBiABIAQQigMACyAFQTBqIAQQrAIACxEAIAAoAgAgACgCBCABEMsDCwgAIAAgARBtCyYAAkAgACABEG0iAUUNACABEN8DEJ8DDQAgAUEAIAAQzgMaCyABCxAAIAAoAgAgACgCBCABEEQLEwAgAEEoNgIEIABBsMTAADYCAAsQACAAIAI2AgQgACABNgIACxMAIABBKDYCBCAAQfTZwAA2AgALEAAgAEEANgIIIABCADcDAAsTACAAQSg2AgQgAEHYnMIANgIACxMAIABBKDYCBCAAQYCvwgA2AgALEAAgAEEEOgAAIAAgAToAAQsWAEHQmcMAIAA2AgBBzJnDAEEBOgAACxMAIABBuMzCADYCBCAAIAE2AgALDQAgAC0ABEECcUEBdgsPACAAIAFBBGopAgA3AwALEAAgASAAKAIAIAAoAgQQQwsNACAALQAYQRBxQQR2Cw0AIAAtABhBIHFBBXYLDQAgAEEAQaAbEM4DGgsKAEEAIABrIABxCwsAIAAtAARBA3FFCwwAIAAgAUEDcjYCBAsNACAAKAIAIAAoAgRqC5QEAQV/IAAoAgAhACMAQRBrIgMkAAJAAn8CQCABQYABTwRAIANBADYCDCABQYAQTw0BIAMgAUE/cUGAAXI6AA0gAyABQQZ2QcABcjoADEECDAILIAAoAggiAiAAKAIARgRAIwBBIGsiBCQAAkACQCACQQFqIgJFDQBBCCAAKAIAIgVBAXQiBiACIAIgBkkbIgIgAkEITRsiAkF/c0EfdiEGAkAgBQRAIARBATYCGCAEIAU2AhQgBCAAQQRqKAIANgIQDAELIARBADYCGAsgBCACIAYgBEEQahC3ASAEKAIEIQUgBCgCAEUEQCAAIAI2AgAgACAFNgIEDAILIARBCGooAgAiAkGBgICAeEYNASACRQ0AIAUgAhDKAwALEKACAAsgBEEgaiQAIAAoAgghAgsgACACQQFqNgIIIAAoAgQgAmogAToAAAwCCyABQYCABE8EQCADIAFBP3FBgAFyOgAPIAMgAUEGdkE/cUGAAXI6AA4gAyABQQx2QT9xQYABcjoADSADIAFBEnZBB3FB8AFyOgAMQQQMAQsgAyABQT9xQYABcjoADiADIAFBDHZB4AFyOgAMIAMgAUEGdkE/cUGAAXI6AA1BAwshASABIAAoAgAgACgCCCICa0sEQCAAIAIgARCxASAAKAIIIQILIAAoAgQgAmogA0EMaiABENADGiAAIAEgAmo2AggLIANBEGokAEEACw4AIAAoAgAaA0AMAAsAC3kBAX8jAEEwayIDJAAgAyABNgIEIAMgADYCACADQRRqQQI2AgAgA0EcakECNgIAIANBLGpBxAA2AgAgA0Gw/MIANgIQIANBADYCCCADQcQANgIkIAMgA0EgajYCGCADIANBBGo2AiggAyADNgIgIANBCGogAhCsAgALeQEBfyMAQTBrIgMkACADIAE2AgQgAyAANgIAIANBFGpBAjYCACADQRxqQQI2AgAgA0EsakHEADYCACADQdD8wgA2AhAgA0EANgIIIANBxAA2AiQgAyADQSBqNgIYIAMgA0EEajYCKCADIAM2AiAgA0EIaiACEKwCAAt5AQF/IwBBMGsiAyQAIAMgATYCBCADIAA2AgAgA0EUakECNgIAIANBHGpBAjYCACADQSxqQcQANgIAIANBhP3CADYCECADQQA2AgggA0HEADYCJCADIANBIGo2AhggAyADQQRqNgIoIAMgAzYCICADQQhqIAIQrAIACw4AIAA1AgBBASABEIABC20BAX8jAEEQayIDJAAgAyABNgIMIAMgADYCCCMAQSBrIgAkACAAQQxqQQE2AgAgAEEUakEBNgIAIABB+PXCADYCCCAAQQA2AgAgAEG8AjYCHCAAIANBCGo2AhggACAAQRhqNgIQIAAgAhCsAgALDQAgACgCACABIAIQZwsOACAAMQAAQQEgARCAAQsOACAAKQMAQQEgARCAAQvMAgEDfyAAKAIALQAAIQIjAEGAAWsiBCQAAkACQAJAAkAgASgCGCIAQRBxRQRAIABBIHENASACrUL/AYNBASABEIABIQIMBAtBACEAA0AgACAEakH/AGpBMEHXACACQQ9xIgNBCkkbIANqOgAAIABBAWshACACQf8BcSIDQQR2IQIgA0EPSw0ACyAAQYABaiICQYEBTw0BIAFBAUGc+MIAQQIgACAEakGAAWpBACAAaxBJIQIMAwtBACEAA0AgACAEakH/AGpBMEE3IAJBD3EiA0EKSRsgA2o6AAAgAEEBayEAIAJB/wFxIgNBBHYhAiADQQ9LDQALIABBgAFqIgJBgQFPDQEgAUEBQZz4wgBBAiAAIARqQYABakEAIABrEEkhAgwCCyACQYABQYz4wgAQpAMACyACQYABQYz4wgAQpAMACyAEQYABaiQAIAILyAMCAX4EfyAAKAIAKQMAIQIjAEGAAWsiBSQAAkACQAJAAkAgASgCGCIAQRBxRQRAIABBIHENASACQQEgARCAASEADAQLQYABIQAgBUGAAWohBAJAAkADQCAARQRAQQAhAAwDCyAEQQFrQTBB1wAgAqciA0EPcSIGQQpJGyAGajoA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akHw78AAELgBDAcLIAAgAkEBajYCDCABQefzwABBEyAAQQxqQfDvwAAQuAEMBgsgACACQQFqNgIMIAFB0fPAAEEWIABBDGpB8O/AABC4AQwFCyABQcDzwABBERCFAwwECyAAIAJBAWo2AgwgAUGb88AAQRJBrfPAAEEDIABBDGpBsPPAABC+AQwDCyABQYzzwABBDxCFAwwCCyAAIAJBBGo2AgwgAUHw8sAAQQkgAEEMakH88sAAELgBDAELIAAgAkEBajYCDCABQdDywABBDyAAQQxqQeDywAAQuAELIABBEGokAAvIHAEBfyAAKAIAIQIjAEFAaiIAJAACfwJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAAkACQAJAIAItAABBAWsOHgECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaHhscHQALIAAgAkEIajYCBCAAIAJBDGo2AiAgACACQRBqNgIkIABBFGpBBDYCACAAQRxqQQM2AgAgAEE8akGsATYCACAAQTRqQa0BNgIAIABBuOvAADYCECAAQQA2AgggAEGtATYCLCAAIABBKGo2AhggACAAQSRqNgI4IAAgAEEgajYCMCAAIABBBGo2AiggASAAQQhqEPMBDB4LIABBNGpBATYCACAAQTxqQQA2AgAgAEH46sAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDB0LIABBNGpBATYCACAAQTxqQQA2AgAgAEHY6sAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDBwLIABBNGpBATYCACAAQTxqQQA2AgAgAEGo6sAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDBsLIABBNGpBATYCACAAQTxqQQA2AgAgAEH46cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDBoLIABBNGpBATYCACAAQTxqQQA2AgAgAEHc6cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDBkLIABBNGpBATYCACAAQTxqQQA2AgAgAEGs6cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDBgLIAAgAkEBajYCJCAAQTRqQQI2AgAgAEE8akEBNgIAIABB/OjAADYCMCAAQQA2AiggAEGsATYCDCAAIABBCGo2AjggACAAQSRqNgIIIAEgAEEoahDzAQwXCyAAIAJBAWo2AiQgAEE0akECNgIAIABBPGpBATYCACAAQcjowAA2AjAgAEEANgIoIABBrAE2AgwgACAAQQhqNgI4IAAgAEEkajYCCCABIABBKGoQ8wEMFgsgACACQQFqNgIkIABBNGpBAjYCACAAQTxqQQE2AgAgAEGY6MAANgIwIABBADYCKCAAQawBNgIMIAAgAEEIajYCOCAAIABBJGo2AgggASAAQShqEPMBDBULIAAgAkEBajYCJCAAQTRqQQI2AgAgAEE8akEBNgIAIABB6OfAADYCMCAAQQA2AiggAEGsATYCDCAAIABBCGo2AjggACAAQSRqNgIIIAEgAEEoahDzAQwUCyAAIAJBAWo2AiQgAEE0akECNgIAIABBPGpBATYCACAAQaznwAA2AjAgAEEANgIoIABBrAE2AgwgACAAQQhqNgI4IAAgAEEkajYCCCABIABBKGoQ8wEMEwsgACACQQRqNgIgIAAgAkEIajYCJCAAQTRqQQM2AgAgAEE8akECNgIAIABBFGpBrgE2AgAgAEH05sAANgIwIABBADYCKCAAQa4BNgIMIAAgAEEIajYCOCAAIABBIGo2AhAgACAAQSRqNgIIIAEgAEEoahDzAQwSCyAAIAJBBGo2AiAgACACQQhqNgIkIABBNGpBAzYCACAAQTxqQQI2AgAgAEEUakGvATYCACAAQbDmwAA2AjAgAEEANgIoIABBrwE2AgwgACAAQQhqNgI4IAAgAEEkajYCECAAIABBIGo2AgggASAAQShqEPMBDBELIABBNGpBATYCACAAQTxqQQA2AgAgAEGA5sAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDBALIAAgAkECajYCICAAIAJBAWo2AiQgAEE0akECNgIAIABBPGpBAjYCACAAQRRqQbABNgIAIABBzOXAADYCMCAAQQA2AiggAEGxATYCDCAAIABBCGo2AjggACAAQSRqNgIQIAAgAEEgajYCCCABIABBKGoQ8wEMDwsgACACQQFqNgIkIABBNGpBAjYCACAAQTxqQQE2AgAgAEGQ5cAANgIwIABBADYCKCAAQbEBNgIMIAAgAEEIajYCOCAAIABBJGo2AgggASAAQShqEPMBDA4LIAAgAkEBajYCJCAAQTRqQQI2AgAgAEE8akEBNgIAIABB2OTAADYCMCAAQQA2AiggAEGyATYCDCAAIABBCGo2AjggACAAQSRqNgIIIAEgAEEoahDzAQwNCyAAIAJBAWo2AiQgAEE0akECNgIAIABBPGpBATYCACAAQazkwAA2AjAgAEEANgIoIABBsgE2AgwgACAAQQhqNgI4IAAgAEEkajYCCCABIABBKGoQ8wEMDAsgACACQQFqNgIkIABBNGpBAjYCACAAQTxqQQE2AgAgAEGI5MAANgIwIABBADYCKCAAQbIBNgIMIAAgAEEIajYCOCAAIABBJGo2AgggASAAQShqEPMBDAsLIAAgAkEBajYCJCAAQTRqQQI2AgAgAEE8akEBNgIAIABB5OPAADYCMCAAQQA2AiggAEGyATYCDCAAIABBCGo2AjggACAAQSRqNgIIIAEgAEEoahDzAQwKCyAAIAJBAWo2AiQgAEE0akECNgIAIABBPGpBATYCACAAQcDjwAA2AjAgAEEANgIoIABBsgE2AgwgACAAQQhqNgI4IAAgAEEkajYCCCABIABBKGoQ8wEMCQsgACACQQFqNgIkIABBNGpBAjYCACAAQTxqQQE2AgAgAEGM48AANgIwIABBADYCKCAAQbIBNgIMIAAgAEEIajYCOCAAIABBJGo2AgggASAAQShqEPMBDAgLIAAgAkEBajYCJCAAQTRqQQI2AgAgAEE8akEBNgIAIABB3OLAADYCMCAAQQA2AiggAEGyATYCDCAAIABBCGo2AjggACAAQSRqNgIIIAEgAEEoahDzAQwHCyAAIAJBAWo2AiQgAEE0akECNgIAIABBPGpBATYCACAAQbDiwAA2AjAgAEEANgIoIABBsgE2AgwgACAAQQhqNgI4IAAgAEEkajYCCCABIABBKGoQ8wEMBgsgACACQQFqNgIkIABBNGpBAjYCACAAQTxqQQE2AgAgAEGI4sAANgIwIABBADYCKCAAQbIBNgIMIAAgAEEIajYCOCAAIABBJGo2AgggASAAQShqEPMBDAULIABBNGpBATYCACAAQTxqQQA2AgAgAEHk4cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAQLIABBNGpBATYCACAAQTxqQQA2AgAgAEHI38AANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAMLIAAgAkEEajYCJCAAQTRqQQI2AgAgAEE8akEBNgIAIABBhN/AADYCMCAAQQA2AiggAEGzATYCDCAAIABBCGo2AjggACAAQSRqNgIIIAEgAEEoahDzAQwCCwJAAkACQAJAAkACQAJAAkAgAi0AAUEBaw4HAQIDBAUGBwALIABBNGpBATYCACAAQTxqQQA2AgAgAEH43sAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAgLIABBNGpBATYCACAAQTxqQQA2AgAgAEHM3sAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAcLIABBNGpBATYCACAAQTxqQQA2AgAgAEGc3sAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAYLIABBNGpBATYCACAAQTxqQQA2AgAgAEH03cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAULIABBNGpBATYCACAAQTxqQQA2AgAgAEHM3cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAQLIABBNGpBATYCACAAQTxqQQA2AgAgAEGQ3cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAMLIABBNGpBATYCACAAQTxqQQA2AgAgAEHU3MAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAILIABBNGpBATYCACAAQTxqQQA2AgAgAEGE3MAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAELIAAgAkEBaiICNgIkIABBNGpBATYCACAAQTxqQQA2AgAgAEHo38AANgIwIABB/NrAADYCOCAAQQA2AihBASABIABBKGoQ8wENABoCQAJAAkACQCACLQAAIgIOAwECAwALAkACQAJAAkAgAkH8AWsOAwECAwALIABBNGpBAjYCACAAQTxqQQE2AgAgAEGA4MAANgIwIABBADYCKCAAQbQBNgIMIAAgAEEIajYCOCAAIABBJGo2AgggASAAQShqEPMBDAYLIABBNGpBATYCACAAQTxqQQA2AgAgAEHA4cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAULIABBNGpBATYCACAAQTxqQQA2AgAgAEGg4cAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAQLIABBNGpBATYCACAAQTxqQQA2AgAgAEH84MAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAMLIABBNGpBATYCACAAQTxqQQA2AgAgAEHc4MAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAILIABBNGpBATYCACAAQTxqQQA2AgAgAEG84MAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBDAELIABBNGpBATYCACAAQTxqQQA2AgAgAEGg4MAANgIwIABB/NrAADYCOCAAQQA2AiggASAAQShqEPMBCyAAQUBrJAALDAAgACABKQJANwMAC9ABAQF/IAAoAgAhAiMAQRBrIgAkACAAIAFB+P/AAEEJEMcCIAAgAigAACIBNgIIIABBgYDBAEEEIABBCGpBiIDBABB4IAAgAUF/c0EFdkEBcToADEGYgMEAQQggAEEMakGggMEAEHggACABQQ12QQFxOgANQbCAwQBBByAAQQ1qQaCAwQAQeCAAIAFBFXZBAXE6AA5Bt4DBAEEIIABBDmpBoIDBABB4IAAgAUEddkEBcToAD0G/gMEAQQggAEEPakGggMEAEHgQ4AEgAEEQaiQACzQAIAEgACgCAC0AAEEYdEGAgIAgakEYdUECdCIAQbycwQBqKAIAIABBoJzBAGooAgAQhQMLCwAgACgCACABEHALDAAgACgCACABEOQCCwwAIAAoAgAgARCnAwsMACAAKAIAIAEQqgMLDAAgACgCACABEMUBCw4AIAFBkLvCAEELEIUDCwkAIAAgARAgAAsKACAAKAIEQXhxCwoAIAAoAgRBAXELCgAgACgCDEEBcQsKACAAKAIMQQF2CxoAIAAgAUHsmcMAKAIAIgBBoQIgABsRAQAACwoAIAIgACABEEMLDAAgACgCACABEIQBCw0AIAFByPvCAEECEEMLrwEBA38gASEFAkAgAkEPTQRAIAAhAQwBCyAAQQAgAGtBA3EiA2ohBCADBEAgACEBA0AgASAFOgAAIAFBAWoiASAESQ0ACwsgBCACIANrIgJBfHEiA2ohASADQQBKBEAgBUH/AXFBgYKECGwhAwNAIAQgAzYCACAEQQRqIgQgAUkNAAsLIAJBA3Eh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L3ZlYy9tb2QucnOIABAATAAAANQHAAAkAAAAcmVzaXplAAABAAAAAAAAAAEAAAACAAAAAwAAAAQAAABvbmUtdGltZSBpbml0aWFsaXphdGlvbiBtYXkgbm90IGJlIHBlcmZvcm1lZCByZWN1cnNpdmVseQQBEAA4AAAAT25jZSBpbnN0YW5jZSBoYXMgcHJldmlvdXNseSBiZWVuIHBvaXNvbmVkAABEARAAKgAAAGNhbGxlZCBgT3B0aW9uOjp1bndyYXAoKWAgb24gYSBgTm9uZWAgdmFsdWUvcnVzdGMvOWViM2FmZTllYmU5YzdkMmI4NGI3MTAwMmQ0NGY0YTBlZGFjOTVlMC9saWJyYXJ5L3N0ZC9zcmMvc3luYy9vbmNlLnJzAKMBEABMAAAAjwAAADIAAAAvcnVzdGMvOWViM2FmZTllYmU5YzdkMmI4NGI3MTAwMmQ0NGY0YTBlZGFjOTVlMC9saWJyYXJ5L2NvcmUvc3JjL29wcy9hcml0aC5ycwAAAAACEABNAAAA6AEAAAEAAABhdHRlbXB0IHRvIGRpdmlkZSBieSB6ZXJvQzpcVXNlcnNcWWVudGxcLmNhcmdvXHJlZ2lzdHJ5XHNyY1xnaXRodWIuY29tLTFlY2M2Mjk5ZGI5ZWM4MjNcY29uc29sZV9lcnJvcl9wYW5pY19ob29rLTAuMS43XHNyY1xsaWIucnMAAAB5AhAAaAAAAJUAAAAOAAAAc3BlZWRoeXBlcnNwZWVkcmV2ZXJzZXJhaW5ib3dyb3RhdGVzcGlucmV2c2xpZGV3aWdnbGVzaGFrZWFzc2VydGlvbiBmYWlsZWQ6IHggYXMgdTY0ICsgd2lkdGggYXMgdTY0IDw9IHNlbGYud2lkdGgoKSBhcyB1NjRDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyM1xpbWFnZS0wLjI0LjZcLi9zcmNcaW1hZ2UucnNuAxAAWgAAAL0DAAAJAAAAYXNzZXJ0aW9uIGZhaWxlZDogeSBhcyB1NjQgKyBoZWlnaHQgYXMgdTY0IDw9IHNlbGYuaGVpZ2h0KCkgYXMgdTY0AABuAxAAWgAAAL4DAAAJAAAAQzpcVXNlcnNcWWVudGxcLmNhcmdvXHJlZ2lzdHJ5XHNyY1xnaXRodWIuY29tLTFlY2M2Mjk5ZGI5ZWM4MjNcaW1hZ2UtMC4yNC42XC4vc3JjXGJ1ZmZlci5ycwAsBBAAWwAAAMoCAAAKAAAAY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZQAsBBAAWwAAAMkCAABDAAAALAQQAFsAAAC3AwAARgAAAEltYWdlIGluZGV4ICBvdXQgb2YgYm91bmRzIADkBBAADAAAAPAEEAAPAAAALAQQAFsAAACyAwAAFQAAACwEEABbAAAAfAMAAA4AAAAsBBAAWwAAAHsDAABDAAAALAQQAFsAAAAGAwAAPgAAACwEEABbAAAAAQMAABUAAABCdWZmZXIgbGVuZ3RoIGluIGBJbWFnZUJ1ZmZlcjo6bmV3YCBvdmVyZmxvd3MgdXNpemUALAQQAFsAAADfBAAADgAAAGEgc2VxdWVuY2UAAAYAAAAEAAAABAAAAAcAAAAGAAAABAAAAAQAAAAIAAAAc3JjXHNoYWtlLnJz0AUQAAwAAAAcAAAAFQAAAAAAAABhdHRlbXB0IHRvIGNhbGN1bGF0ZSB0aGUgcmVtYWluZGVyIHdpdGggYSBkaXZpc29yIG9mIHplcm9jYWxsZWQgYE9wdGlvbjo6dW53cmFwKClgIG9uIGEgYE5vbmVgIHZhbHVlQzpcVXNlcnNcWWVudGxcLmNhcmdvXHJlZ2lzdHJ5XHNyY1xnaXRodWIuY29tLTFlY2M2Mjk5ZGI5ZWM4MjNcaW1hZ2UtMC4yNC42XC4vc3JjXGNvZGVjc1xwbmcucnMAVAYQAF8AAADLAQAALwAAAGludGVybmFsIGVycm9yOiBlbnRlcmVkIHVucmVhY2hhYmxlIGNvZGU6IAAAxAYQACoAAABJbnZhbGlkIHBuZyBjb2xvcgAAAPgGEAARAAAAVAYQAF8AAACZAQAAEgAAADE2LWJpdCBhcG5nIG5vdCB5ZXQgc3VwcG9ydAAkBxAAGwAAAFQGEABfAAAAlwEAABEAAABUBhAAXwAAAJQBAABcAAAAVAYQAF8AAACRAQAAVwAAAFQGEABfAAAAjQEAAFkAAABJbnZhbGlkIHBuZyBpbWFnZSBub3QgZGV0ZWN0ZWQgaW4gcG5nAAAACwAAACgAAAAIAAAADAAAAFQGEABfAAAAoAEAABYAAABUBhAAXwAAAIkBAABYAAAAIG5vdCBhIHZhbGlkIHBuZyBjb2xvcgAAxAYQACoAAADgBxAAFgAAAFQGEABfAAAAtwEAABIAAABDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyM1xpbWFnZS0wLjI0LjZcLi9zcmNcYnVmZmVyLnJzABgIEABbAAAAtwMAAEYAAABJbWFnZSBpbmRleCAgb3V0IG9mIGJvdW5kcyAAhAgQAAwAAACQCBAADwAAABgIEABbAAAAsgMAABUAAABDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyM1xieXRlb3JkZXItMS40LjNcc3JjXGxpYi5ycwAAAMAIEABZAAAAtQcAABwAAABUBhAAXwAAAPsAAAAJAAAAVAYQAF8AAAABAQAAEwAAAAAAAABhdHRlbXB0IHRvIGRpdmlkZSBieSB6ZXJvaW50ZXJuYWwgZXJyb3I6IGVudGVyZWQgdW5yZWFjaGFibGUgY29kZQAAAFQGEABfAAAACQEAABIAAAANAAAAOAIAAAgAAAAOAAAADwAAABAAAAARAAAAEgAAAAwAAAAEAAAAEwAAABQAAAAVAAAAYSBEaXNwbGF5IGltcGxlbWVudGF0aW9uIHJldHVybmVkIGFuIGVycm9yIHVuZXhwZWN0ZWRseQAWAAAAAAAAAAEAAAAXAAAAL3J1c3RjLzllYjNhZmU5ZWJlOWM3ZDJiODRiNzEwMDJkNDRmNGEwZWRhYzk1ZTAvbGlicmFyeS9hbGxvYy9zcmMvc3RyaW5nLnJzACAKEABLAAAA6QkAAA4AAAAWAAAABAAAAAQAAAAYAAAAQzpcVXNlcnNcWWVudGxcLmNhcmdvXHJlZ2lzdHJ5XHNyY1xnaXRodWIuY29tLTFlY2M2Mjk5ZGI5ZWM4MjNcaW1hZ2UtMC4yNC42XC4vc3JjXGJ1ZmZlci5ycwCMChAAWwAAALcDAABGAAAATWFwQWNjZXNzOjpuZXh0X3ZhbHVlIGNhbGxlZCBiZWZvcmUgbmV4dF9rZXlDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVj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AAAAAwEAABsAAADjERAAWAAAAP0AAAAmAAAA4xEQAFgAAADlAAAAJgAAAEdJRjg5YQAA4xEQAFgAAADEAAAAJgAAAAIAAAArAAAAAAAAAAEAAAAsAAAAKwAAAAAAAAABAAAALQAAACsAAAAAAAAAAQAAAC4AAAArAAAABAAAAAQAAAAvAAAAMAAAADEAAAAvcnVzdGMvOWViM2FmZTllYmU5YzdkMmI4NGI3MTAwMmQ0NGY0YTBlZGFjOTVlMC9saWJyYXJ5L2NvcmUvc3JjL3N0ci9wYXR0ZXJuLnJzYXNzZXJ0aW9uIGZhaWxlZDogc3RlcCAhPSAwL3J1c3RjLzllYjNhZmU5ZWJlOWM3ZDJiODRiNzEwMDJkNDRmNGEwZWRhYzk1ZTAvbGlicmFyeS9jb3JlL3NyYy9pdGVyL2FkYXB0ZXJzL3N0ZXBfYnkucnMAVhMQAFkAAAAVAAAACQAAAEM6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXGltYWdlLTAuMjQuNlwuL3NyY1xidWZmZXIucnMAwBMQAFsAAAC3AwAARgAAAEltYWdlIGluZGV4ICBvdXQgb2YgYm91bmRzIAAsFBAADAAAADgUEAAPAAAAwBMQAFsAAACyAwAAFQAAAOwSEABPAAAAuAEAACYAAABuYW1lcGFyYW0AAAB4FBAABAAAAHwUEAAFAEGaqcAAC9cGgL8AAADAAACAvwAAAAAAAIA/AAAAQAAAgD8AAAAAY2h1bmtzIGNhbm5vdCBoYXZlIGEgc2l6ZSBvZiB6ZXJvAAAAuBQQACEAAAAvcnVzdGMvOWViM2FmZTllYmU5YzdkMmI4NGI3MTAwMmQ0NGY0YTBlZGFjOTVlMC9saWJyYXJ5L2NvcmUvc3JjL3NsaWNlL21vZC5ycwAAAOQUEABNAAAAcQMAAAkAAABDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyM1xpbWFnZXByb2MtMC4yMy4wXHNyY1xnZW9tZXRyaWNfdHJhbnNmb3JtYXRpb25zLnJzRBUQAHAAAACJAgAADQAAAGB1bndyYXBfdGhyb3dgIGZhaWxlZAAAADIAAAAMAAAABAAAADMAAAAyAAAADAAAAAQAAAA0AAAAMwAAANwVEAA1AAAANgAAADcAAAA4AAAAOQAAAEVycgA6AAAABAAAAAQAAAA7AAAAT2sAADoAAAAEAAAABAAAADwAAABhc3NlcnRpb24gZmFpbGVkOiBtaWQgPD0gc2VsZi5sZW4oKQBAAAAADAAAAAQAAABBAAAAQgAAABUAAABhIERpc3BsYXkgaW1wbGVtZW50YXRpb24gcmV0dXJuZWQgYW4gZXJyb3IgdW5leHBlY3RlZGx5AEMAAAAAAAAAAQAAABcAAAAvcnVzdGMvOWViM2FmZTllYmU5YzdkMmI4NGI3MTAwMmQ0NGY0YTBlZGFjOTVlMC9saWJyYXJ5L2FsbG9jL3NyYy9zdHJpbmcucnMAxBYQAEsAAADpCQAADgAAAC9ydXN0Yy85ZWIzYWZlOWViZTljN2QyYjg0YjcxMDAyZDQ0ZjRhMGVkYWM5NWUwL2xpYnJhcnkvY29yZS9zcmMvc2xpY2UvbW9kLnJzAAAAIBcQAE0AAAANDAAACQAAAGFzc2VydGlvbiBmYWlsZWQ6IGsgPD0gc2VsZi5sZW4oKQAAACAXEABNAAAAOAwAAAkAAAAAAAAAY2h1bmtzIGNhbm5vdCBoYXZlIGEgc2l6ZSBvZiB6ZXJvAAAAuBcQACEAAAAgFxAATQAAAMADAAAJAEGAsMAAC8UCYXR0ZW1wdCB0byBjYWxjdWxhdGUgdGhlIHJlbWFpbmRlciB3aXRoIGEgZGl2aXNvciBvZiB6ZXJvL3J1c3RjLzllYjNhZmU5ZWJlOWM3ZDJiODRiNzEwMDJkNDRmNGEwZWRhYzk1ZTAvbGlicmFyeS9hbGxvYy9zcmMvc2xpY2UucnMAORgQAEoAAACSAAAAEQAAAG1pc3NpbmcgZmllbGQgYGCUGBAADwAAAKMYEAABAAAAdW5rbm93biBmaWVsZCBgYCwgZXhwZWN0ZWQgALQYEAAPAAAAwxgQAAwAAABgLCB0aGVyZSBhcmUgbm8gZmllbGRzAAC0GBAADwAAAOAYEAAWAAAAZ2lmcG5nVW5zdXBwb3J0ZWQgZm9ybWF0OiAAAA4ZEAAUAAAAc3JjXHV0aWxzLnJzLBkQAAwAAAA7AAAAEgBB0LLAAAvRBWF0dGVtcHQgdG8gZGl2aWRlIGJ5IHplcm8AAAAsGRAADAAAAEEAAAAgAAAALBkQAAwAAABUAAAAGAAAACwZEAAMAAAAVwAAABgAAABDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyM1xnaWYtMC4xMi4wXHNyY1xyZWFkZXJcbW9kLnJzAJwZEABbAAAAeAEAACMAAACcGRAAWwAAAHoBAAAYAAAAY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZQCcGRAAWwAAAIIBAAArAAAAnBkQAFsAAACDAQAAIAAAAG5vIGNvbG9yIHRhYmxlIGF2YWlsYWJsZSBmb3IgY3VycmVudCBmcmFtZQAAnBkQAFsAAAA/AQAAKwAAAGltYWdlIHRydW5jYXRlZACcGRAAWwAAAEQBAAAcAAAAaW50ZXJuYWwgZXJyb3I6IGVudGVyZWQgdW5yZWFjaGFibGUgY29kZZwZEABbAAAA7wAAABUAAABmaWxlIGRvZXMgbm90IGNvbnRhaW4gYW55IGltYWdlIGRhdGF1bmV4cGVjdGVkIEVPRkltYWdlIGRpbWVuc2lvbnMgKCwgKSBhcmUgdG9vIGxhcmdlAAAAKhsQABIAAAA8GxAAAgAAAD4bEAAPAAAAL3J1c3RjLzllYjNhZmU5ZWJlOWM3ZDJiODRiNzEwMDJkNDRmNGEwZWRhYzk1ZTAvbGlicmFyeS9zdGQvc3JjL2lvL2N1cnNvci5yc2gbEABMAAAA6wAAAAoAAAAvcnVzdGMvOWViM2FmZTllYmU5YzdkMmI4NGI3MTAwMmQ0NGY0YTBlZGFjOTVlMC9saWJyYXJ5L2NvcmUvc3JjL29wcy9hcml0aC5ycwAAAMQbEABNAAAA6AEAAAEAQbC4wAAL0lFhdHRlbXB0IHRvIGRpdmlkZSBieSB6ZXJvAAAAY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZUM6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXGltYWdlLTAuMjQuNlwuL3NyY1xjb2RlY3NcZ2lmLnJzAAB3HBAAXwAAACsCAAA1AAAAdxwQAF8AAAAiAgAAKAAA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ZC4AAABcLhAAMQAAAE91dCBvZiBkZWNvbXByZXNzaW9uIHNwYWNlLiBUcnkgd2l0aCBhIGxhcmdlciBsaW1pdC6YLhAANAAAAEludmFsaWQgY29tcHJlc3NlZCB0ZXh0IGRhdGEuAAAA1C4QAB0AAABObyBudWxsIHNlcGFyYXRvciBpbiB0RVh0IGNodW5rLvwuEAAgAAAAS2V5d29yZCBlbXB0eSBvciBsb25nZXIgdGhhbiA3OSBieXRlcy4AACQvEAAmAAAAVW5yZXByZXNlbnRhYmxlIGRhdGEgaW4gdEVYdCBjaHVuay4AVC8QACMAAAAuAAAAfC0QAAAAAACALxAAAQAAAElEQVQgb3IgZkRBVCBjaHVuayBpcyBoYXMgbm90IGVub3VnaCBkYXRhIGZvciBpbWFnZS6ULxAANAAAAENvcnJ1cHQgZGVmbGF0ZSBzdHJlYW0uINAvEAAYAAAARXJyb3IgbnVtYmVyIAAAAPAvEAANAAAAgC8QAAEAAABIYXMgbW9yZSBvdXRwdXQuEDAQABAAAABOZWVkcyBtb3JlIGlucHV0LgAAACgwEAARAAAAVW5leHBlY3RlZCBkb25lIHN0YXR1cy4ARDAQABcAAABBZGxlcjMyIGNoZWNrc3VtIGZhaWxlZC5kMBAAGAAAAEludmFsaWQgaW5wdXQgcGFyYW1ldGVycy4AAACEMBAAGQAAAFVuZXhwZWN0ZWQgZW5kIG9mIGRhdGEuAKgwEAAXAAAAU3ViIGZyYW1lIGlzIG91dC1vZi1ib3VuZHMuAMgwEAAbAAAAVW5rbm93biBpbnRlcmxhY2UgbWV0aG9kIAAAAOwwEAAZAAAAgC8QAAEAAABVbmtub3duIGZpbHRlciBtZXRob2QgAAAYMRAAFgAAAIAvEAABAAAAVW5rbm93biBjb21wcmVzc2lvbiBtZXRob2QgAEAxEAAbAAAAgC8QAAEAAABJbnZhbGlkIHNSR0IgcmVuZGVyaW5nIGludGVudCAAAGwxEAAeAAAAgC8QAAEAAABJbnZhbGlkIHBoeXNpY2FsIHBpeGVsIHNpemUgdW5pdCAAAACcMRAAIQAAAIAvEAABAAAASW52YWxpZCBibGVuZCBvcCAAAADQMRAAEQAAAIAvEAABAAAASW52YWxpZCBkaXNwb3NlIG9wIAD0MRAAEwAAAIAvEAABAAAASW52YWxpZCBjb2xvciB0eXBlIAAYMhAAEwAAAIAvEAABAAAASW52YWxpZCBkaXNwb3NlIG9wZXJhdGlvbiAAADwyEAAaAAAAgC8QAAEAAABUcmFuc3BhcmVuY3kgY2h1bmsgZm91bmQgZm9yIGNvbG9yIHR5cGUgaDIQACgAAACALxAAAQAAAEludmFsaWQgY29sb3IvZGVwdGggY29tYmluYXRpb24gaW4gaGVhZGVyOiAvoDIQACsAAADLMhAAAQAAAE1pc3NpbmcgcGFsZXR0ZSBvZiBpbmRleGVkIGltYWdlLgAAANwyEAAhAAAATm90IGVub3VnaCBwYWxldHRlIGVudHJpZXMsIGV4cGVjdCAgZ290IAgzEAAjAAAAKzMQAAUAAACALxAAAQAAAFNlcXVlbmNlIGlzIG5vdCBpbiBvcmRlciwgZXhwZWN0ZWQgIyBnb3QgIwAASDMQACQAAABsMxAABgAAAIAvEAABAAAAQ2h1bmsgIG11c3QgYXBwZWFyIGF0IG1vc3Qgb25jZS6MMxAABgAAAJIzEAAaAAAAIG11c3QgYXBwZWFyIGJldHdlZW4gUExURSBhbmQgSURBVCBjaHVua3MuAACMMxAABgAAALwzEAAqAAAAIGlzIGludmFsaWQgYWZ0ZXIgUExURSBjaHVuay4AAACMMxAABgAAAPgzEAAdAAAAIGlzIGludmFsaWQgYWZ0ZXIgSURBVCBjaHVuay4AAACMMxAABgAAACg0EAAdAAAAIGNodW5rIGFwcGVhcmVkIGJlZm9yZSBJSERSIGNodW5rAAAAfC0QAAAAAABYNBAAIQAAAElEQVQgb3IgZkRBVCBjaHVuayBpcyBtaXNzaW5nLgAAjDQQAB4AAABmY1RMIGNodW5rIG1pc3NpbmcgYmVmb3JlIGZkQVQgY2h1bmsuAAAAtDQQACUAAABJSERSIGNodW5rIG1pc3NpbmcAAOQ0EAASAAAAVW5leHBlY3RlZCBlbmQgb2YgZGF0YSB3aXRoaW4gYSBjaHVuay4AAAA1EAAmAAAAVW5leHBlY3RlZCBlbmQgb2YgZGF0YSBiZWZvcmUgaW1hZ2UgZW5kLjA1EAAoAAAASW52YWxpZCBQTkcgc2lnbmF0dXJlLgAAYDUQABYAAABDUkMgZXJyb3I6IGV4cGVjdGVkIDB4IGhhdmUgMHggd2hpbGUgZGVjb2RpbmcgIGNodW5rLgAAAIA1EAAWAAAAljUQAAgAAACeNRAAEAAAAK41EAAHAAAAQzpcVXNlcnNcWWVudGxcLmNhcmdvXHJlZ2lzdHJ5XHNyY1xnaXRodWIuY29tLTFlY2M2Mjk5ZGI5ZWM4MjNccG5nLTAuMTcuN1xzcmNcZGVjb2RlclxzdHJlYW0ucnMA2DUQAF8AAADnAQAAHAAAANg1EABfAAAA5QEAADkAAADYNRAAXwAAAKkCAAAjAAAAY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZQDYNRAAXwAAACUDAAAcAAAA2DUQAF8AAAAkAwAAHAAAANg1EABfAAAANAMAACAAAADYNRAAXwAAADoDAAAnAAAA2DUQAF8AAABHAwAAJwAAANg1EABfAAAAhAMAACcAAADYNRAAXwAAAKEDAAAnAAAA2DUQAF8AAADTAwAAJwAAANg1EABfAAAA7AMAACcAAADYNRAAXwAAACwEAAAYAAAA2DUQAF8AAAAFBAAAJwAAANg1EABfAAAAmQQAAA4AAADYNRAAXwAAAKsEAAAcAAAA2DUQAF8AAADGBAAAIwAAANg1EABfAAAAyAQAACUAAADYNRAAXwAAAM8EAAAOAAAA2DUQAF8AAADRBAAAGwAAANg1EABfAAAA0wQAABwAAADAAAAABAAAAAQAAACsAAAAwAAAAAQAAAAEAAAAwQAAAMAAAAAEAAAABAAAAMIAAABQYXJ0aWFsQ2h1bmvAAAAABAAAAAQAAADDAAAASW1hZ2VFbmRJbWFnZURhdGFGbHVzaGVkSW1hZ2VEYXRhRnJhbWVDb250cm9sAAAAwAAAAAQAAAAEAAAAxAAAAEFuaW1hdGlvbkNvbnRyb2zAAAAABAAAAAQAAADFAAAAUGl4ZWxEaW1lbnNpb25zAMAAAAAEAAAABAAAAMYAAABDaHVua0NvbXBsZXRlQ2h1bmtCZWdpbkhlYWRlcgAAAMAAAAAEAAAABAAAALAAAADAAAAABAAAAAQAAACxAAAAwAAAAAQAAAAEAAAAxwAAAE5vdGhpbmdMaW1pdHNFeGNlZWRlZFBhcmFtZXRlcgAAwAAAAAQAAAAEAAAAyAAAAEZvcm1hdAAAwAAAAAQAAAAEAAAAyQAAAElvRXJyb3IAwAAAAAQAAAAEAAAAygAAAEZvcm1hdEVycm9yaW5uZXLAAAAABAAAAAQAAADLAAAAQmFkVGV4dEVuY29kaW5nAMAAAAAEAAAABAAAAMwAAABCYWRGaWx0ZXIAAADAAAAABAAAAAQAAADNAAAATm9Nb3JlSW1hZ2VEYXRhQ29ycnVwdEZsYXRlU3RyZWFtZXJywAAAAAQAAAAEAAAAtAAAAEJhZFN1YkZyYW1lQm91bmRzVW5rbm93bkludGVybGFjZU1ldGhvZFVua25vd25GaWx0ZXJNZXRob2RVbmtub3duQ29tcHJlc3Npb25NZXRob2RJbnZhbGlkU3JnYlJlbmRlcmluZ0ludGVudEludmFsaWRVbml0SW52YWxpZEJsZW5kT3BJbnZhbGlkRGlzcG9zZU9wSW52YWxpZENvbG9yVHlwZUludmFsaWRCaXREZXB0aENvbG9yV2l0aEJhZFRybnNJbnZhbGlkQ29sb3JCaXREZXB0aGNvbG9yX3R5cGViaXRfZGVwdGhQYWxldHRlUmVxdWlyZWRTaG9ydFBhbGV0dGVleHBlY3RlZGxlbkFwbmdPcmRlcnByZXNlbnREdXBsaWNhdGVDaHVua2tpbmRPdXRzaWRlUGx0ZUlkYXRBZnRlclBsdGVBZnRlcklkYXRDaHVua0JlZm9yZUloZHJNaXNzaW5nSW1hZ2VEYXRhTWlzc2luZ0ZjdGxNaXNzaW5nSWhkclVuZXhwZWN0ZWRFbmRPZkNodW5rVW5leHBlY3RlZEVvZkludmFsaWRTaWduYXR1cmVDcmNNaXNtYXRjaHJlY292ZXJjcmNfdmFsY3JjX3N1bWNodW5rAGludGVybmFsIGVycm9yOiBlbnRlcmVkIHVucmVhY2hhYmxlIGNvZGU6IAAAoDsQACoAAABDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyM1xwbmctMC4xNy43XHNyY1xjb21tb24ucnMAAAAAAGF0dGVtcHQgdG8gZGl2aWRlIGJ5IHplcm8AAADUOxAAVwAAAEAAAAAdAAAATm90IGEgcG9zc2libGUgYnl0ZSByb3VuZGVkIHBpeGVsIHdpZHRoAFw8EAAnAAAA1DsQAFcAAABeAgAAEgAAAEVuZCBvZiBpbWFnZSBoYXMgYmVlbiByZWFjaGVkAAAAnDwQAB0AAAB3cm9uZyBkYXRhIHNpemUsIGV4cGVjdGVkICBnb3QgAMQ8EAAaAAAA3jwQAAUAAABSZ2JhR3JheXNjYWxlQWxwaGFJbmRleGVkUmdiR3JheXNjYWxlU2l4dGVlbkVpZ2h0Rm91clR3b09uZVBpeGVsRGltZW5zaW9uc3hwcHUAAM8AAAAEAAAABAAAAMEAAAB5cHB1dW5pdM8AAAAEAAAABAAAANAAAABNZXRlclVuc3BlY2lmaWVkUHJldmlvdXNCYWNrZ3JvdW5kTm9uZU92ZXJTb3VyY2VzZXF1ZW5jZV9udW1iZXJ3aWR0aGhlaWdodHhfb2Zmc2V0eV9vZmZzZXRkZWxheV9udW1kZWxheV9kZW5kaXNwb3NlX29wYmxlbmRfb3AAAJw9EAAPAAAAqz0QAAUAAACwPRAABgAAALY9EAAIAAAAvj0QAAgAAADGPRAACQAAAM89EAAJAAAA2D0QAAoAAADiPRAACAAAAM8AAAAEAAAABAAAANEAAADPAAAABAAAAAQAAADSAAAAzwAAAAQAAAAEAAAA0wAAAEZyYW1lQ29udHJvbEFuaW1hdGlvbkNvbnRyb2xudW1fZnJhbWVzbnVtX3BsYXlzUGFyYW1ldGVyRXJyb3Jpbm5lcgAAzwAAAAQAAAAEAAAA1AAAAFBvbGxlZEFmdGVyRW5kT2ZJbWFnZUltYWdlQnVmZmVyU2l6ZWV4cGVjdGVkzwAAAAQAAAAEAAAAwgAAAGFjdHVhbAAAAAAAAAEAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAEAAAAAAAAAAgAAAAAAAAABAAAAAAAAAAQAAAAAAAAAAQAAAAEAAAADAAAAAQAAAAIAAAABAAAABAAAAAAAAAACAAAAAAAAAAEAAAAAAAAABAAAAAAAAAABAAAAAAAAAAEAAAAAAAAAAQAAAAAAAAADAAAAAAAAAAEAAAAAAAAAAgAAAAEAAAAEAAAAAQAAAAEAAAABAAAAAwAAAAEAAAAOAAAACQAAAAQAAAAJAAAACQAAAAkAAAADAAAABwAAAPg8EAAQPRAA9DwQABA9EAAQPRAAED0QAA09EAAGPRAAQ2h1bmtUeXBldHlwZQAAANYAAAAEAAAAAQAAANcAAABjcml0aWNhbNYAAAABAAAAAQAAANgAAABwcml2YXRlcmVzZXJ2ZWRzYWZlY29weQD4PxAAAAAAAEM6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXHBuZy0wLjE3Ljdcc3JjXGRlY29kZXJcemxpYi5ycwAAAFBAEABdAAAASAAAABIAAABQQBAAXQAAAIAAAAAVAAAAUEAQAF0AAACMAAAAFgAAAE5vIG1vcmUgZm9yd2FyZCBwcm9ncmVzcyBtYWRlIGluIHN0cmVhbSBkZWNvZGluZy4AAABQQBAAXQAAAJ4AAAAVAAAAYXNzZXJ0aW9uIGZhaWxlZDogc3RlcCAhPSAwL3J1c3RjLzllYjNhZmU5ZWJlOWM3ZDJiODRiNzEwMDJkNDRmNGEwZWRhYzk1ZTAvbGlicmFyeS9jb3JlL3NyYy9pdGVyL2FkYXB0ZXJzL3N0ZXBfYnkucnM/QRAAWQAAABUAAAAJAAAAQzpcVXNlcnNcWWVudGxcLmNhcmdvXHJlZ2lzdHJ5XHNyY1xnaXRodWIuY29tLTFlY2M2Mjk5ZGI5ZWM4MjNccG5nLTAuMTcuN1xzcmNcZmlsdGVyLnJzRmlsdGVyaW5nIGZhaWxlZDogYnl0ZXMgcGVyIHBpeGVsIGlzIGdyZWF0ZXIgdGhhbiBsZW5ndGggb2Ygcm93AACoQRAAVwAAALIAAAAeAAAAY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZQCoQRAAVwAAALgAAAAwAAAAqEEQAFcAAAB3AAAAHgAAAKhBEABXAAAAYwAAADYAAABGaWx0ZXJpbmcgZmFpbGVkOiBub3QgZW5vdWdoIGRhdGEgaW4gcHJldmlvdXMgcm93AAAAqEEQAFcAAACYAAAADQAAAKhBEABXAAAAmQAAAA0AAACoQRAAVwAAAJoAAAANAAAAqEEQAFcAAACbAAAADQAAAKhBEABXAAAAnAAAAA0AAACoQRAAVwAAAJ0AAAANAAAAdW5yZWFjaGFibGUA2QAAAAgAAAAEAAAA2gAAAEM6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXHBuZy0wLjE3Ljdcc3JjXHRleHRfbWV0YWRhdGEucnMAAFxDEABeAAAAuQAAACYAAABJbnZhbGlkS2V5d29yZFNpemVVbnJlcHJlc2VudGFibGVNaXNzaW5nQ29tcHJlc3Npb25GbGFnSW52YWxpZENvbXByZXNzaW9uRmxhZ0ludmFsaWRDb21wcmVzc2lvbk1ldGhvZE91dE9mRGVjb21wcmVzc2lvblNwYWNlSW5mbGF0aW9uRXJyb3JNaXNzaW5nTnVsbFNlcGFyYXRvcgAADwAAABIAAAAUAAAADgAAABcAAAAYAAAAFgAAABYAAADeQxAAzEMQAFZEEABIRBAAMUQQABlEEAADRBAA7UMQAEM6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXHBuZy0wLjE3Ljdcc3JjXHV0aWxzLnJzAEGQisEAC40HYXR0ZW1wdCB0byBkaXZpZGUgYnkgemVybwAAAKxEEABWAAAAJAAAABYAAACsRBAAVgAAACUAAAAaAAAA/0M6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXHBuZy0wLjE3Ljdcc3JjXGRlY29kZXJcbW9kLnJzAAAATUUQAFwAAACaAwAACQAAAE1FEABcAAAAoAMAABkAAAACAAAAAQAAAAQAAAABAAAAAQAAAAEAAAADAAAAAQAAAC9ydXN0Yy85ZWIzYWZlOWViZTljN2QyYjg0YjcxMDAyZDQ0ZjRhMGVkYWM5NWUwL2xpYnJhcnkvYWxsb2Mvc3JjL3ZlYy9tb2QucnPsRRAATAAAANQHAAAkAAAAQzpcVXNlcnNcWWVudGxcLmNhcmdvXHJlZ2lzdHJ5XHNyY1xnaXRodWIuY29tLTFlY2M2Mjk5ZGI5ZWM4MjNccG5nLTAuMTcuN1xzcmNcdXRpbHMucnMAAEhGEABWAAAALwAAABIAAABhdHRlbXB0IHRvIGRpdmlkZSBieSB6ZXJvAAAASEYQAFYAAAA2AAAADQAAAEhGEABWAAAANwAAAA0AAABIRhAAVgAAADkAAAANAAAASEYQAFYAAAA8AAAAIAAAAEhGEABWAAAAPAAAAA0AAABIRhAAVgAAAEgAAAASAAAA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Y2sgdGVybWluYXRvciBub3QgZm91bmR1bmtub3duIGJsb2NrIHR5cGUgZW5jb3VudGVyZWRYjxAAXwAAAPoBAAAvAAAAZnJhbWUgZGVzY3JpcHRvciBpcyBvdXQtb2YtYm91bmRzdW5zdXBwb3J0ZWQgR0lGIHZlcnNpb25tYWxmb3JtZWQgR0lGIGhlYWRlcmNvbnRyb2wgZXh0ZW5zaW9uIGhhcyB3cm9uZyBsZW5ndGhEZWNvZGluZ0Zvcm1hdEVycm9ydW5kZXJseWluZwDrAAAABAAAAAQAAADsAAAASW8AAOsAAAAEAAAABAAAAO0AAABGb3JtYXQAAOsAAAAEAAAABAAAAO4AAABjYW5ub3QgYWNjZXNzIGEgVGhyZWFkIExvY2FsIFN0b3JhZ2UgdmFsdWUgZHVyaW5nIG9yIGFmdGVyIGRlc3RydWN0aW9uAADvAAAAAAAAAAEAAADwAAAAL3J1c3RjLzllYjNhZmU5ZWJlOWM3ZDJiODRiNzEwMDJkNDRmNGEwZWRhYzk1ZTAvbGlicmFyeS9zdGQvc3JjL3RocmVhZC9sb2NhbC5ycwBokhAATwAAAKYBAAAaAAAA8QAAAAgAAAAEAAAA8gAAAGFzc2VydGlvbiBmYWlsZWQ6IHBpeGVsLmxlbigpID09IDRDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyM1xjb2xvcl9xdWFudC0xLjEuMFxzcmNcbGliLnJzAAAA+pIQAFsAAAC6AAAACQAAAEM6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXGdpZi0wLjEyLjBcc3JjXGNvbW1vbi5ycwBokxAAVwAAAPUAAAAiAAAAaJMQAFcAAAD1AAAALAAAAGiTEABXAAAA9QAAADYAAABokxAAVwAAAPUAAABAAAAAY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZQBokxAAVwAAAPUAAABLAAAA8wAAAAgAAAAEAAAA9AAAAPUAAAD2AAAADAAAAAQAAAAzAAAA9gAAAAwAAAAEAAAANAAAADMAAABQlBAA9wAAAPgAAAA3AAAA+QAAAPoAAABjYXBhY2l0eSBvdmVyZmxvdwAAAIyUEAARAAAAL3J1c3RjLzllYjNhZmU5ZWJlOWM3ZDJiODRiNzEwMDJkNDRmNGEwZWRhYzk1ZTAvbGlicmFyeS9hbGxvYy9zcmMvdmVjL3NwZWNfZnJvbV9pdGVyX25lc3RlZC5ycwAAqJQQAF4AAAA7AAAAEgAAAC9ydXN0Yy85ZWIzYWZlOWViZTljN2QyYjg0YjcxMDAyZDQ0ZjRhMGVkYWM5NWUwL2xpYnJhcnkvY29yZS9zcmMvc2xpY2UvaXRlci5ycwAAGJUQAE4AAABVBwAAEQBBgKvCAAvyMmF0dGVtcHQgdG8gZGl2aWRlIGJ5IHplcm9JbmRleCBvdXQgb2YgYm91bmRzmZUQABMAAAAvcnVzdGMvOWViM2FmZTllYmU5YzdkMmI4NGI3MTAwMmQ0NGY0YTBlZGFjOTVlMC9saWJyYXJ5L2NvcmUvc3JjL3NsaWNlL3NvcnQucnMAALSVEABOAAAAywQAABUAAAC0lRAATgAAANkEAAAeAAAAtJUQAE4AAADiBAAAGAAAALSVEABOAAAA5wQAABwAAABUb28gbXVjaCBvciB0b28gbGl0dGxlIHBpeGVsIGRhdGEgZm9yIHRoZSBnaXZlbiB3aWR0aCBhbmQgaGVpZ2h0IHRvIGNyZWF0ZSBhIEdJRiBGcmFtZQAARJYQAFYAAABDOlxVc2Vyc1xZZW50bFwuY2FyZ29ccmVnaXN0cnlcc3JjXGdpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyM1xnaWYtMC4xMi4wXHNyY1xjb21tb24ucnMApJYQAFcAAADQAAAACQAAAHNwZWVkIG5lZWRzIHRvIGJlIGluIHRoZSByYW5nZSBbMSwgMzBdAACklhAAVwAAANEAAAAJAAAAY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZQCklhAAVwAAAPUAAABLAAAAZGVzY3JpcHRpb24oKSBpcyBkZXByZWNhdGVkOyB1c2UgRGlzcGxheXRoZSBHSUYgZm9ybWF0IHJlcXVpcmVzIGEgY29sb3IgcGFsZXR0ZSBidXQgbm9uZSB3YXMgZ2l2ZW4AAKiXEAA6AAAAdGhlIGltYWdlIGhhcyB0b28gbWFueSBjb2xvcnMAAADs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AAAA1J0QAFgAAACQAwAAEQAAANSdEABYAAAAjAMAADcAAABNYXhpbXVtIGNvZGUgc2l6ZSAxMiByZXF1aXJlZCwgZ290IAA4nxAAIwAAAEM6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXHdlZXpsLTAuMS43XHNyY1xsaWIucnMAAABknxAAVQAAAF8AAAAFAAAATWluaW11bSBjb2RlIHNpemUgMiByZXF1aXJlZCwgZ290IAAAzJ8QACIAAABknxAAVQAAAGgAAAAFAAAAZJ8QAFUAAABpAAAABQAAAEM6XFVzZXJzXFllbnRsXC5jYXJnb1xyZWdpc3RyeVxzcmNcZ2l0aHViLmNvbS0xZWNjNjI5OWRiOWVjODIzXHdlZXpsLTAuMS43XHNyY1xlbmNvZGUucnMYoBAAWAAAAP8BAAAVAAAAFAEAAAwAAAAEAAAAFQEAABYBAAAXAQAAYSBEaXNwbGF5IGltcGxlbWVudGF0aW9uIHJldHVybmVkIGFuIGVycm9yIHVuZXhwZWN0ZWRseQAYAQAAAAAAAAEAAAAXAAAAL3J1c3RjLzllYjNhZmU5ZWJlOWM3ZDJiODRiNzEwMDJkNDRmNGEwZWRhYzk1ZTAvbGlicmFyeS9hbGxvYy9zcmMvc3RyaW5nLnJzAOCgEABLAAAA6QkAAA4AAAAKClN0YWNrOgoKAAAZAQAABAAAAAQAAAAaAQAAGwEAABwBAABKc1ZhbHVlKCkAAABgoRAACAAAAGihEAABAAAAIgEAAAQAAAAEAAAAIwEAACQBAAAlAQAAY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZUFjY2Vzc0Vycm9yAACUoRAAAAAAAHVuY2F0ZWdvcml6ZWQgZXJyb3JvdGhlciBlcnJvcm91dCBvZiBtZW1vcnl1bmV4cGVjdGVkIGVuZCBvZiBmaWxldW5zdXBwb3J0ZWRvcGVyYXRpb24gaW50ZXJydXB0ZWRhcmd1bWVudCBsaXN0IHRvbyBsb25naW52YWxpZCBmaWxlbmFtZXRvbyBtYW55IGxpbmtzY3Jvc3MtZGV2aWNlIGxpbmsgb3IgcmVuYW1lZGVhZGxvY2tleGVjdXRhYmxlIGZpbGUgYnVzeXJlc291cmNlIGJ1c3lmaWxlIHRvbyBsYXJnZWZpbGVzeXN0ZW0gcXVvdGEgZXhjZWVkZWRzZWVrIG9uIHVuc2Vla2FibGUgZmlsZW5vIHN0b3JhZ2Ugc3BhY2V3cml0ZSB6ZXJvdGltZWQgb3V0aW52YWxpZCBkYXRhaW52YWxpZCBpbnB1dCBwYXJhbWV0ZXJzdGFsZSBuZXR3b3JrIGZpbGUgaGFuZGxlZmlsZXN5c3RlbSBsb29wIG9yIGluZGlyZWN0aW9uIGxpbWl0IChlLmcuIHN5bWxpbmsgbG9vcClyZWFkLW9ubHkgZmlsZXN5c3RlbSBvciBzdG9yYWdlIG1lZGl1bWRpcmVjdG9yeSBub3QgZW1wdHlpcyBhIGRpcmVjdG9yeW5vdCBhIGRpcmVjdG9yeW9wZXJhdGlvbiB3b3VsZCBibG9ja2VudGl0eSBhbHJlYWR5IGV4aXN0c2Jyb2tlbiBwaXBlbmV0d29yayBkb3duYWRkcmVzcyBub3QgYXZhaWxhYmxlYWRkcmVzcyBpbiB1c2Vub3QgY29ubmVjdGVkY29ubmVjdGlvbiBhYm9ydGVkbmV0d29yayB1bnJlYWNoYWJsZWhvc3QgdW5yZWFjaGFibGVjb25uZWN0aW9uIHJlc2V0Y29ubmVjdGlvbiByZWZ1c2VkcGVybWlzc2lvbiBkZW5pZWRlbnRpdHkgbm90IGZvdW5kRXJyb3JraW5kAAAiAQAAAQAAAAEAAAAmAQAAbWVzc2FnZQAiAQAACAAAAAQAAAAnAQAAS2luZE9zY29kZQAAIgEAAAQAAAAEAAAAKAEAACkBAAAMAAAABAAAACoBAAAgKG9zIGVycm9yICmUoRAAAAAAACClEAALAAAAK6UQAAEAAABtZW1vcnkgYWxsb2NhdGlvbiBvZiAgYnl0ZXMgZmFpbGVkAABEpRAAFQAAAFmlEAANAAAAbGlicmFyeS9zdGQvc3JjL2FsbG9jLnJzeKUQABgAAABVAQAACQAAAGNhbm5vdCBtb2RpZnkgdGhlIHBhbmljIGhvb2sgZnJvbSBhIHBhbmlja2luZyB0aHJlYWSgpRAANAAAAGxpYnJhcnkvc3RkL3NyYy9wYW5pY2tpbmcucnPcpRAAHAAAAIYAAAAJAAAA3KUQABwAAAA+AgAAHgAAANylEAAcAAAAPQIAAB8AAAApAQAADAAAAAQAAAArAQAAIgEAAAgAAAAEAAAALAEAAC0BAAAQAAAABAAAAC4BAAAvAQAAIgEAAAgAAAAEAAAAMAEAADEBAAAiAQAAAAAAAAEAAAAyAQAAVW5zdXBwb3J0ZWQAIgEAAAQAAAAEAAAAMwEAAEN1c3RvbWVycm9yACIBAAAEAAAABAAAADQBAABVbmNhdGVnb3JpemVkT3RoZXJPdXRPZk1lbW9yeVVuZXhwZWN0ZWRFb2ZJbnRlcnJ1cHRlZEFyZ3VtZW50TGlzdFRvb0xvbmdJbnZhbGlkRmlsZW5hbWVUb29NYW55TGlua3NDcm9zc2VzRGV2aWNlc0RlYWRsb2NrRXhlY3V0YWJsZUZpbGVCdXN5UmVzb3VyY2VCdXN5RmlsZVRvb0xhcmdlRmlsZXN5c3RlbVF1b3RhRXhjZWVkZWROb3RTZWVrYWJsZVN0b3JhZ2VGdWxsV3JpdGVaZXJvVGltZWRPdXRJbnZhbGlkRGF0YUludmFsaWRJbnB1dFN0YWxlTmV0d29ya0ZpbGVIYW5kbGVGaWxlc3lzdGVtTG9vcFJlYWRPbmx5RmlsZXN5c3RlbURpcmVjdG9yeU5vdEVtcHR5SXNBRGlyZWN0b3J5Tm90QURpcmVjdG9yeVdvdWxkQmxvY2tBbHJlYWR5RXhpc3RzQnJva2VuUGlwZU5ldHdvcmtEb3duQWRkck5vdEF2YWlsYWJsZUFkZHJJblVzZU5vdENvbm5lY3RlZENvbm5lY3Rpb25BYm9ydGVkTmV0d29ya1VucmVhY2hhYmxlSG9zdFVucmVhY2hhYmxlQ29ubmVjdGlvblJlc2V0Q29ubmVjdGlvblJlZnVzZWRQZXJtaXNzaW9uRGVuaWVkTm90Rm91bmRvcGVyYXRpb24gc3VjY2Vzc2Z1bAAOAAAAEAAAABYAAAAVAAAACwAAABYAAAANAAAACwAAABMAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAARAAAAEgAAABAAAAAQAAAAEwAAABIAAAANAAAADgAAABUAAAAMAAAACwAAABUAAAAVAAAADwAAAA4AAAATAAAAJgAAADgAAAAZAAAAFwAAAAwAAAAJAAAACgAAABAAAAAXAAAAGQAAAA4AAAANAAAAFAAAAAgAAAAbAAAAW6IQAEuiEAA1ohAAIKIQABWiEAD/oRAA8qEQAOehEADUoRAAsaQQALGkEACxpBAAsaQQALGkEACxpBAAsaQQALGkEACxpBAAsaQQALGkEACxpBAAsaQQALGkEACxpBAAsaQQALGkEACxpBAAsaQQALGkEACxpBAAsaQQALGkEACxpBAAoKQQAI6kEAB+pBAAbqQQAFukEABJpBAAPKQQAC6kEAAZpBAADaQQAAKkEADtoxAA2KMQAMmjEAC7oxAAqKMQAIKjEABKoxAAMaMQABqjEAAOoxAABaMQAPuiEADrohAA1KIQALuiEACtohAAoKIQAIyiEACEohAAaaIQAAgAAAAQAAAAEQAAAA8AAAAPAAAAEgAAABEAAAAMAAAACQAAABAAAAALAAAACgAAAA0AAAAKAAAADQAAAAwAAAARAAAAEgAAAA4AAAAWAAAADAAAAAsAAAAIAAAACQAAAAsAAAALAAAAFwAAAAwAAAAMAAAAEgAAAAgAAAAOAAAADAAAAA8AAAATAAAACwAAAAsAAAANAAAACwAAAAUAAAANAAAAw6gQALOoEACiqBAAk6gQAISoEAByqBAAYagQAFWoEABMqBAAPKgQADGoEAAnqBAAGqgQABCoEAADqBAA96cQAOanEADUpxAAxqcQALCnEACkpxAAmacQAJGnEACIpxAAfacQAHKnEABbpxAAT6cQAEOnEAAxpxAAKacQABunEAAPpxAAAKcQAO2mEADiphAAgKYQANWmEADKphAAxaYQALimEABIYXNoIHRhYmxlIGNhcGFjaXR5IG92ZXJmbG93KKwQABwAAAAvY2FyZ28vcmVnaXN0cnkvc3JjL2dpdGh1Yi5jb20tMWVjYzYyOTlkYjllYzgyMy9oYXNoYnJvd24tMC4xMi4zL3NyYy9yYXcvbW9kLnJzAEysEABPAAAAWgAAACgAAAA1AQAABAAAAAQAAAA2AQAANwEAADgBAABsaWJyYXJ5L2FsbG9jL3NyYy9yYXdfdmVjLnJzY2FwYWNpdHkgb3ZlcmZsb3cAAADgrBAAEQAAAMSsEAAcAAAABgIAAAUAAABhIGZvcm1hdHRpbmcgdHJhaXQgaW1wbGVtZW50YXRpb24gcmV0dXJuZWQgYW4gZXJyb3IANQEAAAAAAAABAAAAFwAAAGxpYnJhcnkvYWxsb2Mvc3JjL2ZtdC5yc1CtEAAYAAAAZAIAACAAAAApIHNob3VsZCBiZSA8IGxlbiAoaXMgKWxpYnJhcnkvYWxsb2Mvc3JjL3ZlYy9tb2QucnNpbnNlcnRpb24gaW5kZXggKGlzICkgc2hvdWxkIGJlIDw9IGxlbiAoaXMgAACrrRAAFAAAAL+tEAAXAAAAjq0QAAEAAACPrRAAHAAAAKsFAAANAAAAcmVtb3ZhbCBpbmRleCAoaXMgAAAArhAAEgAAAHitEAAWAAAAjq0QAAEAAABhc3NlcnRpb24gZmFpbGVkOiBlZGVsdGEgPj0gMGxpYnJhcnkvY29yZS9zcmMvbnVtL2RpeV9mbG9hdC5ycwAASa4QACEAAABMAAAACQAAAEmuEAAhAAAATgAAAAkAAAABAAAACgAAAGQAAADoAwAAECcAAKCGAQBAQg8AgJaYAADh9QUAypo7AgAAABQAAADIAAAA0AcAACBOAABADQMAgIQeAAAtMQEAwusLAJQ1dwAAwW/yhiMAAAAAAIHvrIVbQW0t7gQAQfzdwgALEwEfar9k7Thu7Zen2vT5P+kDTxgAQaDewgALJgE+lS4Jmd8D/TgVDy/kdCPs9c/TCNwExNqwzbwZfzOmAyYf6U4CAEHo3sIAC6QKAXwumFuH075yn9nYhy8VEsZQ3mtwbkrPD9iV1W5xsiawZsatJDYVHVrTQjwOVP9jwHNVzBfv+WXyKLxV98fcgNztbvTO79xf91MFAGxpYnJhcnkvY29yZS9zcmMvbnVtL2ZsdDJkZWMvc3RyYXRlZ3kvZHJhZ29uLnJzYXNzZXJ0aW9uIGZhaWxlZDogZC5tYW50ID4gMAC0rxAALwAAAHUAAAAFAAAAYXNzZXJ0aW9uIGZhaWxlZDogZC5taW51cyA+IDAAAAC0rxAALwAAAHYAAAAFAAAAYXNzZXJ0aW9uIGZhaWxlZDogZC5wbHVzID4gMLSvEAAvAAAAdwAAAAUAAABhc3NlcnRpb24gZmFpbGVkOiBkLm1hbnQuY2hlY2tlZF9hZGQoZC5wbHVzKS5pc19zb21lKCkAALSvEAAvAAAAeAAAAAUAAABhc3NlcnRpb24gZmFpbGVkOiBkLm1hbnQuY2hlY2tlZF9zdWIoZC5taW51cykuaXNfc29tZSgpALSvEAAvAAAAeQAAAAUAAABhc3NlcnRpb24gZmFpbGVkOiBidWYubGVuKCkgPj0gTUFYX1NJR19ESUdJVFMAAAC0rxAALwAAAHoAAAAFAAAAtK8QAC8AAADBAAAACQAAALSvEAAvAAAA+QAAAFQAAAC0rxAALwAAAPoAAAANAAAAtK8QAC8AAAABAQAAMwAAALSvEAAvAAAACgEAAAUAAAC0rxAALwAAAAsBAAAFAAAAtK8QAC8AAAAMAQAABQAAALSvEAAvAAAADQEAAAUAAAC0rxAALwAAAA4BAAAFAAAAtK8QAC8AAABLAQAAHwAAALSvEAAvAAAAZQEAAA0AAAC0rxAALwAAAHEBAAAkAAAAtK8QAC8AAAB2AQAAVAAAALSvEAAvAAAAgwEAADMAAAAAAAAA30UaPQPPGubB+8z+AAAAAMrGmscX/nCr3PvU/gAAAABP3Ly+/LF3//b73P4AAAAADNZrQe+RVr4R/OT+AAAAADz8f5CtH9CNLPzs/gAAAACDmlUxKFxR00b89P4AAAAAtcmmrY+scZ1h/Pz+AAAAAMuL7iN3Ipzqe/wE/wAAAABtU3hAkUnMrpb8DP8AAAAAV862XXkSPIKx/BT/AAAAADdW+002lBDCy/wc/wAAAABPmEg4b+qWkOb8JP8AAAAAxzqCJcuFdNcA/Sz/AAAAAPSXv5fNz4agG/00/wAAAADlrCoXmAo07zX9PP8AAAAAjrI1KvtnOLJQ/UT/AAAAADs/xtLf1MiEa/1M/wAAAAC6zdMaJ0TdxYX9VP8AAAAAlsklu86fa5Og/Vz/AAAAAISlYn0kbKzbuv1k/wAAAAD22l8NWGaro9X9bP8AAAAAJvHD3pP44vPv/XT/AAAAALiA/6qorbW1Cv58/wAAAACLSnxsBV9ihyX+hP8AAAAAUzDBNGD/vMk//oz/AAAAAFUmupGMhU6WWv6U/wAAAAC9filwJHf533T+nP8AAAAAj7jluJ+936aP/qT/AAAAAJR9dIjPX6n4qf6s/wAAAADPm6iPk3BEucT+tP8AAAAAaxUPv/jwCIrf/rz/AAAAALYxMWVVJbDN+f7E/wAAAACsf3vQxuI/mRT/zP8AAAAABjsrKsQQXOQu/9T/AAAAANOSc2mZJCSqSf/c/wAAAAAOygCD8rWH/WP/5P8AAAAA6xoRkmQI5bx+/+z/AAAAAMyIUG8JzLyMmf/0/wAAAAAsZRniWBe30bP//P8AQZbpwgALBUCczv8EAEGk6cIAC/AUEKXU6Oj/DAAAAAAAAABirMXreK0DABQAAAAAAIQJlPh4OT+BHgAcAAAAAACzFQfJe86XwDgAJAAAAAAAcFzqe84yfo9TACwAAAAAAGiA6aukONLVbQA0AAAAAABFIpoXJidPn4gAPAAAAAAAJ/vE1DGiY+2iAEQAAAAAAKityIw4Zd6wvQBMAAAAAADbZasajgjHg9gAVAAAAAAAmh1xQvkdXcTyAFwAAAAAAFjnG6YsaU2SDQFkAAAAAADqjXAaZO4B2icBbAAAAAAASnfvmpmjbaJCAXQAAAAAAIVrfbR7eAnyXAF8AAAAAAB3GN15oeRUtHcBhAAAAAAAwsWbW5KGW4aSAYwAAAAAAD1dlsjFUzXIrAGUAAAAAACzoJf6XLQqlccBnAAAAAAA41+gmb2fRt7hAaQAAAAAACWMOds0wpul/AGsAAAAAABcn5ijcprG9hYCtAAAAAAAzr7pVFO/3LcxArwAAAAAAOJBIvIX8/yITALEAAAAAACleFzTm84gzGYCzAAAAAAA31Mhe/NaFpiBAtQAAAAAADowH5fctaDimwLcAAAAAACWs+NcU9HZqLYC5AAAAAAAPESnpNl8m/vQAuwAAAAAABBEpKdMTHa76wL0AAAAAAAanEC2746riwYD/AAAAAAALIRXphDvH9AgAwQBAAAAACkxkenlpBCbOwMMAQAAAACdDJyh+5sQ51UDFAEAAAAAKfQ7YtkgKKxwAxwBAAAAAIXPp3peS0SAiwMkAQAAAAAt3awDQOQhv6UDLAEAAAAAj/9EXi+cZ47AAzQBAAAAAEG4jJydFzPU2gM8AQAAAACpG+O0ktsZnvUDRAEAAAAA2Xffum6/lusPBEwBAAAAAGxpYnJhcnkvY29yZS9zcmMvbnVtL2ZsdDJkZWMvc3RyYXRlZ3kvZ3Jpc3UucnMAADC3EAAuAAAAfQAAABUAAAAwtxAALgAAAKkAAAAFAAAAMLcQAC4AAACqAAAABQAAADC3EAAuAAAAqwAAAAUAAAAwtxAALgAAAKwAAAAFAAAAMLcQAC4AAACtAAAABQAAADC3EAAuAAAArgAAAAUAAABhc3NlcnRpb24gZmFpbGVkOiBkLm1hbnQgKyBkLnBsdXMgPCAoMSA8PCA2MSkAAAAwtxAALgAAAK8AAAAFAAAAMLcQAC4AAAAKAQAAEQAAAGF0dGVtcHQgdG8gZGl2aWRlIGJ5IHplcm8AAAAwtxAALgAAAA0BAAAJAAAAMLcQAC4AAAAWAQAAQgAAADC3EAAuAAAAQAEAAAkAAAAwtxAALgAAAEcBAABCAAAAYXNzZXJ0aW9uIGZhaWxlZDogIWJ1Zi5pc19lbXB0eSgpY2FsbGVkIGBPcHRpb246OnVud3JhcCgpYCBvbiBhIGBOb25lYCB2YWx1ZTC3EAAuAAAA3AEAAAUAAABhc3NlcnRpb24gZmFpbGVkOiBkLm1hbnQgPCAoMSA8PCA2MSkwtxAALgAAAN0BAAAFAAAAMLcQAC4AAADeAQAABQAAADC3EAAuAAAAIwIAABEAAAAwtxAALgAAACYCAAAJAAAAMLcQAC4AAABcAgAACQAAADC3EAAuAAAAvAIAAEcAAAAwtxAALgAAANMCAABLAAAAMLcQAC4AAADfAgAARwAAAGxpYnJhcnkvY29yZS9zcmMvbnVtL2ZsdDJkZWMvbW9kLnJzAHy5EAAjAAAAvAAAAAUAAABhc3NlcnRpb24gZmFpbGVkOiBidWZbMF0gPiBiXCcwXCcAAAB8uRAAIwAAAL0AAAAFAAAAYXNzZXJ0aW9uIGZhaWxlZDogcGFydHMubGVuKCkgPj0gNAAAfLkQACMAAAC+AAAABQAAADAuLi0rMGluZk5hTmFzc2VydGlvbiBmYWlsZWQ6IGJ1Zi5sZW4oKSA+PSBtYXhsZW4AAAB8uRAAIwAAAH8CAAANAAAAKS4uAF26EAACAAAAAGluZGV4IG91dCBvZiBib3VuZHM6IHRoZSBsZW4gaXMgIGJ1dCB0aGUgaW5kZXggaXMgAGm6EAAgAAAAiboQABIAAAA6AAAALK4QAAAAAACsuhAAAQAAAKy6EAABAAAAcGFuaWNrZWQgYXQgJycsINS6EAABAAAA1boQAAMAAABCAQAAAAAAAAEAAABDAQAALK4QAAAAAABCAQAABAAAAAQAAABEAQAAbWF0Y2hlcyE9PT1hc3NlcnRpb24gZmFpbGVkOiBgKGxlZnQgIHJpZ2h0KWAKICBsZWZ0OiBgYCwKIHJpZ2h0OiBgYDogAAAAG7sQABkAAAA0uxAAEgAAAEa7EAAMAAAAUrsQAAMAAABgAAAAG7sQABkAAAA0uxAAEgAAAEa7EAAMAAAAeLsQAAEAAAA6IAAALK4QAAAAAACcuxAAAgAAAEIBAAAMAAAABAAAAEUBAABGAQAARwEAACAgICAgewosCiwgIHsgfSB9KAooLAAAAEIBAAAEAAAABAAAAEgBAABsaWJyYXJ5L2NvcmUvc3JjL2ZtdC9udW0ucnMA8LsQABsAAABlAAAAFAAAADB4MDAwMTAyMDMwNDA1MDYwNzA4MDkxMDExMTIxMzE0MTUxNjE3MTgxOTIwMjEyMjIzMjQyNTI2MjcyODI5MzAzMTMyMzMzNDM1MzYzNzM4Mzk0MDQxNDI0MzQ0NDU0NjQ3NDg0OTUwNTE1MjUzNTQ1NTU2NTc1ODU5NjA2MTYyNjM2NDY1NjY2NzY4Njk3MDcxNzI3Mzc0NzU3Njc3Nzg3OTgwODE4MjgzODQ4NTg2ODc4ODg5OTA5MTkyOTM5NDk1OTY5Nzk4OTkAAEIBAAAEAAAABAAAAEkBAABKAQAASwEAAGxpYnJhcnkvY29yZS9zcmMvZm10L21vZC5ycwAAvRAAGwAAAEcGAAAeAAAAMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMAC9EAAbAAAAQQYAAC0AAAAAvRAAGwAAADMIAAAJAAAAQgEAAAgAAAAEAAAAPQEAAHRydWVmYWxzZQAAAAC9EAAbAAAAfwkAAB4AAAAAvRAAGwAAAIYJAAAWAAAAKClsaWJyYXJ5L2NvcmUvc3JjL3NsaWNlL21lbWNoci5ycwAAyr0QACAAAABoAAAAJwAAAHJhbmdlIHN0YXJ0IGluZGV4ICBvdXQgb2YgcmFuZ2UgZm9yIHNsaWNlIG9mIGxlbmd0aCD8vRAAEgAAAA6+EAAiAAAAcmFuZ2UgZW5kIGluZGV4IEC+EAAQAAAADr4QACIAAABzbGljZSBpbmRleCBzdGFydHMgYXQgIGJ1dCBlbmRzIGF0IABgvhAAFgAAAHa+EAANAAAAAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEAQdb+wgALMwICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgMDAwMDAwMDAwMDAwMDAwMEBAQEBABBlP/CAAtRbGlicmFyeS9jb3JlL3NyYy9zdHIvbG9zc3kucnMAAACUvxAAHQAAAFsAAAAmAAAAlL8QAB0AAABiAAAAHgAAAFx4AADUvxAAAgAAAAAAAAACAEHw/8IAC9gZAgAAAAgAAAAgAAAAAwAAAFsuLi5dYnl0ZSBpbmRleCAgaXMgb3V0IG9mIGJvdW5kcyBvZiBgAAAFwBAACwAAABDAEAAWAAAAeLsQAAEAAABiZWdpbiA8PSBlbmQgKCA8PSApIHdoZW4gc2xpY2luZyBgAABAwBAADgAAAE7AEAAEAAAAUsAQABAAAAB4uxAAAQAAACBpcyBub3QgYSBjaGFyIGJvdW5kYXJ5OyBpdCBpcyBpbnNpZGUgIChieXRlcyApIG9mIGAFwBAACwAAAITAEAAmAAAAqsAQAAgAAACywBAABgAAAHi7EAABAAAAbGlicmFyeS9jb3JlL3NyYy9zdHIvbW9kLnJzAODAEAAbAAAABwEAAB0AAABsaWJyYXJ5L2NvcmUvc3JjL3VuaWNvZGUvcHJpbnRhYmxlLnJzAAAADMEQACUAAAAKAAAAHAAAAAzBEAAlAAAAGgAAADYAAAAAAQMFBQYGAgcGCAcJEQocCxkMGg0QDgwPBBADEhITCRYBFwQYARkDGgcbARwCHxYgAysDLQsuATADMQIyAacCqQKqBKsI+gL7Bf0C/gP/Ca14eYuNojBXWIuMkBzdDg9LTPv8Li8/XF1f4oSNjpGSqbG6u8XGycre5OX/AAQREikxNDc6Oz1JSl2EjpKpsbS6u8bKzs/k5QAEDQ4REikxNDo7RUZJSl5kZYSRm53Jzs8NESk6O0VJV1tcXl9kZY2RqbS6u8XJ3+Tl8A0RRUlkZYCEsry+v9XX8PGDhYukpr6/xcfP2ttImL3Nxs7PSU5PV1leX4mOj7G2t7/BxsfXERYXW1z29/7/gG1x3t8OH25vHB1ffX6ur3+7vBYXHh9GR05PWFpcXn5/tcXU1dzw8fVyc490dZYmLi+nr7e/x8/X35pAl5gwjx/S1M7/Tk9aWwcIDxAnL+7vbm83PT9CRZCRU2d1yMnQ0djZ5/7/ACBfIoLfBIJECBsEBhGBrA6AqwUfCYEbAxkIAQQvBDQEBwMBBwYHEQpQDxIHVQcDBBwKCQMIAwcDAgMDAwwEBQMLBgEOFQVOBxsHVwcCBhcMUARDAy0DAQQRBg8MOgQdJV8gbQRqJYDIBYKwAxoGgv0DWQcWCRgJFAwUDGoGCgYaBlkHKwVGCiwEDAQBAzELLAQaBgsDgKwGCgYvMU0DgKQIPAMPAzwHOAgrBYL/ERgILxEtAyEPIQ+AjASClxkLFYiUBS8FOwcCDhgJgL4idAyA1hoMBYD/BYDfDPKdAzcJgVwUgLgIgMsFChg7AwoGOAhGCAwGdAseA1oEWQmAgxgcChYJTASAigarpAwXBDGhBIHaJgcMBQWAphCB9QcBICoGTASAjQSAvgMbAw8NAAYBAQMBBAIFBwcCCAgJAgoFCwIOBBABEQISBRMRFAEVAhcCGQ0cBR0IHwEkAWoEawKvA7ECvALPAtEC1AzVCdYC1wLaAeAF4QLnBOgC7iDwBPgC+gP7AQwnOz5OT4+enp97i5OWorK6hrEGBwk2PT5W89DRBBQYNjdWV3+qrq+9NeASh4mOngQNDhESKTE0OkVGSUpOT2RlXLa3GxwHCAoLFBc2OTqoqdjZCTeQkagHCjs+ZmmPkhFvX7/u71pi9Pz/U1Samy4vJyhVnaCho6SnqK26vMQGCwwVHTo/RVGmp8zNoAcZGiIlPj/n7O//xcYEICMlJigzODpISkxQU1VWWFpcXmBjZWZrc3h9f4qkqq+wwNCur25vvpNeInsFAwQtA2YDAS8ugIIdAzEPHAQkCR4FKwVEBA4qgKoGJAQkBCgINAtOQ4E3CRYKCBg7RTkDYwgJMBYFIQMbBQFAOARLBS8ECgcJB0AgJwQMCTYDOgUaBwQMB1BJNzMNMwcuCAqBJlJLKwgqFhomHBQXCU4EJAlEDRkHCgZICCcJdQtCPioGOwUKBlEGAQUQAwWAi2IeSAgKgKZeIkULCgYNEzoGCjYsBBeAuTxkUwxICQpGRRtICFMNSQcKgPZGCh0DR0k3Aw4ICgY5BwqBNhkHOwMcVgEPMg2Dm2Z1C4DEikxjDYQwEBaPqoJHobmCOQcqBFwGJgpGCigFE4KwW2VLBDkHEUAFCwIOl/gIhNYqCaLngTMPAR0GDgQIgYyJBGsFDQMJBxCSYEcJdDyA9gpzCHAVRnoUDBQMVwkZgIeBRwOFQg8VhFAfBgaA1SsFPiEBcC0DGgQCgUAfEToFAYHQKoLmgPcpTAQKBAKDEURMPYDCPAYBBFUFGzQCgQ4sBGQMVgqArjgdDSwECQcCDgaAmoPYBBEDDQN3BF8GDAQBDwwEOAgKBigIIk6BVAwdAwkHNggOBAkHCQeAyyUKhAZsaWJyYXJ5L2NvcmUvc3JjL3VuaWNvZGUvdW5pY29kZV9kYXRhLnJzbGlicmFyeS9jb3JlL3NyYy9udW0vYmlnbnVtLnJzAAD4xhAAHgAAAKwBAAABAAAAYXNzZXJ0aW9uIGZhaWxlZDogbm9ib3Jyb3dhc3NlcnRpb24gZmFpbGVkOiBkaWdpdHMgPCA0MGFzc2VydGlvbiBmYWlsZWQ6IG90aGVyID4gMFRyeUZyb21JbnRFcnJvcgAAAEIBAAAEAAAABAAAAEwBAABTb21lTm9uZUIBAAAEAAAABAAAAE0BAABFcnJvclV0ZjhFcnJvcnZhbGlkX3VwX3RvZXJyb3JfbGVuAABCAQAABAAAAAQAAABOAQAA0MYQACgAAABQAAAAKAAAANDGEAAoAAAAXAAAABYAAAAAAwAAgwQgAJEFYABdE6AAEhcgHwwgYB/vLKArKjAgLG+m4CwCqGAtHvtgLgD+IDae/2A2/QHhNgEKITckDeE3qw5hOS8YoTkwHGFI8x6hTEA0YVDwaqFRT28hUp28oVIAz2FTZdGhUwDaIVQA4OFVruJhV+zkIVnQ6KFZIADuWfABf1oAcAAHAC0BAQECAQIBAUgLMBUQAWUHAgYCAgEEIwEeG1sLOgkJARgEAQkBAwEFKwM8CCoYASA3AQEBBAgEAQMHCgIdAToBAQECBAgBCQEKAhoBAgI5AQQCBAICAwMBHgIDAQsCOQEEBQECBAEUAhYGAQE6AQECAQQIAQcDCgIeATsBAQEMAQkBKAEDATcBAQMFAwEEBwILAh0BOgECAQIBAwEFAgcCCwIcAjkCAQECBAgBCQEKAh0BSAEEAQIDAQEIAVEBAgcMCGIBAgkLB0kCGwEBAQEBNw4BBQECBQsBJAkBZgQBBgECAgIZAgQDEAQNAQICBgEPAQADAAMdAh4CHgJAAgEHCAECCwkBLQMBAXUCIgF2AwQCCQEGA9sCAgE6AQEHAQEBAQIIBgoCATAfMQQwBwEBBQEoCQwCIAQCAgEDOAEBAgMBAQM6CAICmAMBDQEHBAEGAQMCxkAAAcMhAAONAWAgAAZpAgAEAQogAlACAAEDAQQBGQIFAZcCGhINASYIGQsuAzABAgQCAicBQwYCAgICDAEIAS8BMwEBAwICBQIBASoCCAHuAQIBBAEAAQAQEBAAAgAB4gGVBQADAQIFBCgDBAGlAgAEAAJQA0YLMQR7ATYPKQECAgoDMQQCAgcBPQMkBQEIPgEMAjQJCgQCAV8DAgEBAgYBAgGdAQMIFQI5AgEBAQEWAQ4HAwXDCAIDAQEXAVEBAgYBAQIBAQIBAusBAgQGAgECGwJVCAIBAQJqAQEBAgYBAWUDAgQBBQAJAQL1AQoCAQEEAZAEAgIEASAKKAYCBAgBCQYCAy4NAQIABwEGAQFSFgIHAQIBAnoGAwEBAgEHAQFIAgMBAQEAAgsCNAUFAQEBAAEGDwAFOwcAAT8EUQEAAgAuAhcAAQEDBAUICAIHHgSUAwA3BDIIAQ4BFgUBDwAHARECBwECAQVkAaAHAAE9BAAEAAdtBwBggPAAAAAAAD8AAAC/AwAAAAQAAAAEAAAABgAAAIP5ogBETm4A/CkVANFXJwDdNPUAYtvAADyZlQBBkEMAY1H+ALveqwC3YcUAOm4kANJNQgBJBuAACeouAByS0QDrHf4AKbEcAOg+pwD1NYIARLsuAJzphAC0JnAAQX5fANaROQBTgzkAnPQ5AItfhAAo+b0A+B87AN7/lwAPmAUAES/vAApaiwBtH20Az342AAnLJwBGT7cAnmY/AC3qXwC6J3UA5evHAD178QD3OQcAklKKAPtr6gAfsV8ACF2NADADVgB7/EYA8KtrACC8zwA29JoA46kdAF5hkQAIG+YAhZllAKAUXwCNQGgAgNj/ACdzTQAGBjEAylYVAMmocwB74mAAa4zAAAAAAAAAAABA+yH5PwAAAAAtRHQ+AAAAgJhG+DwAAABgUcx4OwAAAICDG/A5AAAAQCAlejgAAACAIoLjNgAAAAAd82k1AHsJcHJvZHVjZXJzAghsYW5ndWFnZQEEUnVzdAAMcHJvY2Vzc2VkLWJ5AwVydXN0Yx0xLjY4LjIgKDllYjNhZmU5ZSAyMDIzLTAzLTI3KQZ3YWxydXMGMC4xOS4wDHdhc20tYmluZGdlbhIwLjIuODQgKGNlYThjYzNkMik=',
          imports
        );
      }

      onmessage = (message) => {
        const request = message.data;
        let response;
        let promise;

        switch (request.type) {
          case WorkerMessageType.INIT:
            promise = initWasm();
            break;
          case WorkerMessageType.APPLY_COMMANDS:
            promise = doApplyCommands(request);
            break;
          default:
            promise = Promise.reject(new Error('Unknown request type'));
            break;
        }

        promise
          .then((data) => {
            response = {
              type: request.type,
              data,
            };

            postMessage(response);
          })
          .catch((error) => {
            response = {
              type: request.type,
              data: error,
            };

            postMessage(response);
          });
      };

      async function initWasm() {
        const instance = await gifWasm();
        await init(instance);
        initPanicHook();
      }

      async function doApplyCommands(message) {
        const { data, formatType, commands } = message.data;

        const result = applyCommands(data, formatType, commands);
        return await Promise.resolve(result);
      }
    })();
  },
  null
);
/* eslint-enable */

var WorkerMessageType;
(function (WorkerMessageType) {
  const INIT = 0;
  WorkerMessageType[(WorkerMessageType['INIT'] = INIT)] = 'INIT';
  const APPLY_COMMANDS = INIT + 1;
  WorkerMessageType[(WorkerMessageType['APPLY_COMMANDS'] = APPLY_COMMANDS)] =
    'APPLY_COMMANDS';
})(WorkerMessageType || (WorkerMessageType = {}));

class GifWorker {
  worker;

  onterminate;
  onerror;
  onmessage;

  constructor(worker) {
    this.worker = worker;
    worker.onerror = (error) => {
      this.onerror?.(error);
    };
    worker.onmessage = (message) => {
      this.onmessage?.(message);
    };
  }

  postMessage(message) {
    this.worker.postMessage(message);
  }

  terminate() {
    this.onterminate?.();
    this.worker.terminate();
  }
}

class GifProcessingService extends BaseService {
  isProcessing = false;
  worker;

  async start() {
    await this.getWorker();
  }

  async getWorker() {
    if (this.worker) return this.worker;

    const worker = new GifWorker(new WorkerFactory());
    const request = {
      type: WorkerMessageType.INIT,
    };

    await Utils.workerMessagePromise(worker, request);

    this.worker = worker;
    return worker;
  }

  stopWorker() {
    this.isProcessing = false;
    if (!this.worker) return;

    this.worker.terminate();
    this.worker = undefined;
  }

  modifyGif(url, formatType, options) {
    if (this.isProcessing) {
      return {
        result: Promise.reject(new Error('Already processing, please wait.')),
      };
    }
    this.isProcessing = true;

    return {
      cancel: () => {
        this.stopWorker();
      },
      result: this.modifyGifImpl(url, formatType, options).finally(() => {
        this.isProcessing = false;
      }),
    };
  }

  async modifyGifImpl(url, formatType, options) {
    Logger.info('Got GIF request', url, options);
    const commands = this.getCommands(options);
    Logger.info('Processed request commands', commands);

    const result = await this.processCommands(url, formatType, commands);
    Logger.info('Processed modified emote', { length: result.length });

    return result;
  }

  getCommands(options) {
    const commands = [];

    options.forEach((option) => {
      switch (option[0]) {
        case 'resize': {
          const command = {
            name: option[0],
            param: option[1],
          };

          commands.push(command);
          break;
        }
        case 'reverse': {
          commands.push({ name: option[0] });
          break;
        }
        case 'flip':
          commands.push({ name: option[0], param: '0' });
          break;
        case 'flap':
          commands.push({ name: 'flip', param: '1' });
          break;
        case 'speed': {
          const param = option[1]?.toString() ?? '';

          commands.push({
            name: option[0],
            param: Math.max(2, parseFloat(param)).toString(),
          });
          break;
        }
        case 'hyperspeed':
          commands.push({ name: 'hyperspeed' });
          break;
        case 'rotate':
          commands.push({ name: option[0], param: option[1] });
          break;
        case 'rain':
          commands.push({
            name: option[0],
            param: option[1] === 'glitter' ? '1' : '0',
          });
          break;
        case 'spin':
        case 'spinrev':
        case 'shake':
        case 'rainbow':
        case 'infinite':
        case 'slide':
        case 'sliderev':
        case 'wiggle': {
          let speed = '8';
          const param = option[1];

          if (param === 'fast') speed = '6';
          else if (param === 'faster') speed = '4';
          else if (param === 'hyper') speed = '2';

          commands.push({ name: option[0], param: speed });
          break;
        }
      }
    });

    return commands;
  }

  async processCommands(url, formatType, commands) {
    const data = await Utils.urlGetBuffer(url);
    const worker = await this.getWorker();

    const request = {
      type: WorkerMessageType.APPLY_COMMANDS,
      data: { data, formatType, commands },
    };

    const response = await Utils.workerMessagePromise(worker, request);
    if (!(response instanceof Uint8Array)) throw Error('Did not process gif!');

    return response;
  }

  stop() {
    this.stopWorker();
  }
}

class ModulesService extends BaseService {
  channelStore;
  uploader;
  draft;
  draftStore;
  permissions;
  discordPermissions;
  dispatcher;
  componentDispatcher;
  pendingReplyDispatcher = {};
  emojiStore;
  emojiSearch;
  emojiDisabledReasons;
  stickerSendabilityStore;
  stickerType;
  stickerFormatType;
  stickerStore;
  userStore;
  messageStore;
  classes;
  cloudUploader;

  start() {
    this.channelStore = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('getChannel', 'hasChannel')
    );

    this.uploader = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('instantBatchUpload')
    );

    this.draft = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('changeDraft')
    );

    this.draftStore = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('getDraft', 'getRecentlyEditedDrafts')
    );

    this.permissions = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('getChannelPermissions')
    );

    this.discordPermissions = this.getModule(
      (module) => {
        return typeof module.CREATE_INSTANT_INVITE === 'bigint';
      },
      { searchExports: true }
    );

    this.dispatcher = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('dispatch', 'subscribe')
    );

    this.componentDispatcher = this.getModule(
      (module) => {
        if (module.dispatchToLastSubscribed !== undefined) {
          const componentDispatcher = module;
          return componentDispatcher.emitter.listeners('SHAKE_APP').length > 0;
        }

        return false;
      },
      { searchExports: true }
    );

    this.pendingReplyDispatcher.module = this.getModule((module) => {
      Object.entries(module).forEach(([key, value]) => {
        if (!(typeof value === 'function')) return;
        const valueString = value.toString();

        if (valueString.includes('DELETE_PENDING_REPLY')) {
          this.pendingReplyDispatcher.deletePendingReplyKey = key;
        } else if (valueString.includes('CREATE_PENDING_REPLY')) {
          this.pendingReplyDispatcher.createPendingReplyKey = key;
        } else if (valueString.includes('SET_PENDING_REPLY_SHOULD_MENTION')) {
          this.pendingReplyDispatcher.setPendingReplyShouldMentionKey = key;
        }
      });

      return this.pendingReplyDispatcher.deletePendingReplyKey !== undefined;
    });

    if (this.pendingReplyDispatcher.module === undefined) {
      Logger.error('pendingReplyDispatcher module not found!');
    }

    this.emojiStore = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('getEmojiUnavailableReason')
    );

    this.emojiSearch = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('getDisambiguatedEmojiContext')
    );

    this.emojiDisabledReasons = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('PREMIUM_LOCKED'),
      { searchExports: true }
    );

    this.stickerSendabilityStore = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('getStickerSendability')
    );

    this.stickerType = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('STANDARD', 'GUILD'),
      { searchExports: true }
    );

    this.stickerFormatType = this.getModule(
      (module) => {
        return (
          module.LOTTIE !== undefined &&
          module.GIF !== undefined &&
          module[1] !== undefined
        );
      },
      { searchExports: true }
    );

    this.stickerStore = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('getStickerById', 'getStickersByGuildId')
    );

    this.userStore = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('getCurrentUser')
    );

    this.messageStore = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('sendMessage')
    );

    this.cloudUploader = this.getModule((module) => {
      return Object.values(module).some((value) => {
        if (typeof value !== 'object' || value === null) return false;
        const curValue = value;

        return (
          curValue.NOT_STARTED !== undefined &&
          curValue.UPLOADING !== undefined &&
          module.CloudUpload !== undefined
        );
      });
    });

    const TextArea = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('channelTextArea', 'textArea')
    );
    if (TextArea === undefined) Logger.error('TextArea not found!');

    const Editor = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('editor', 'placeholder')
    );
    if (Editor === undefined) Logger.error('Editor not found!');

    const Autocomplete = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys(
        'autocomplete',
        'autocompleteInner',
        'autocompleteRowVertical'
      )
    );
    if (Autocomplete === undefined) Logger.error('Autocomplete not found!');

    const autocompleteAttached = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('autocomplete', 'autocompleteAttached')
    );
    if (autocompleteAttached === undefined)
      Logger.error('autocompleteAttached not found!');

    const Wrapper = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('wrapper', 'base')
    );
    if (Wrapper === undefined) Logger.error('Wrapper not found!');

    const Size = BdApi.Webpack.getModule(
      BdApi.Webpack.Filters.byKeys('size12')
    );
    if (Size === undefined) Logger.error('Size not found!');

    this.classes = {
      TextArea,
      Editor,

      Autocomplete: {
        ...Autocomplete,
        autocomplete: [
          autocompleteAttached?.autocomplete,
          autocompleteAttached?.autocompleteAttached,
          Autocomplete?.autocomplete,
        ].join(' '),
      },

      Wrapper,
      Size,
    };

    Object.entries(this).forEach(([key, value]) => {
      if (value !== undefined) return;
      Logger.error(`${key} not found!`);
    });

    return Promise.resolve();
  }

  getModule(filter, searchOptions) {
    return BdApi.Webpack.getModule((...args) => {
      try {
        return filter(...args);
      } catch (ignored) {
        return false;
      }
    }, searchOptions);
  }

  stop() {
    // Do nothing
  }
}

class SendMessageService extends BaseService {
  emoteService;
  attachService;
  modulesService;
  settingsService;
  gifProcessingService;

  start(
    emoteService,
    attachService,
    modulesService,
    settingsService,
    gifProcessingService
  ) {
    this.emoteService = emoteService;
    this.attachService = attachService;
    this.modulesService = modulesService;
    this.settingsService = settingsService;
    this.gifProcessingService = gifProcessingService;

    return Promise.resolve();
  }

  async onSendMessage(args, original) {
    const callDefault = original;

    const channelId = args[0];
    const message = args[1];
    const attachments = args[3];

    if (channelId === undefined || !message) {
      callDefault(...args);
      return;
    }

    const stickerId = attachments?.stickerIds?.[0];
    if (stickerId !== undefined) {
      const sentSticker = await this.sendSticker(
        stickerId,
        channelId,
        message.content
      );
      if (sentSticker) return;
    }

    try {
      const discordEmotes = this.getTargetEmoteFromMessage(message);
      let content = message.content;

      const foundEmote = this.getTextPos(content, {
        ...this.emoteService.emoteNames,
        ...discordEmotes,
      });

      if (!foundEmote) {
        callDefault(...args);
        return;
      }

      content = (
        content.substring(0, foundEmote.pos) +
        content.substring(foundEmote.pos + foundEmote.nameAndCommand.length)
      ).trim();

      foundEmote.content = content;
      foundEmote.channel = channelId;

      try {
        if (!this.attachService.canAttach) {
          throw new Error('This channel does not allow sending images!');
        }

        this.attachService.pendingUpload = this.fetchBlobAndUpload(foundEmote);
        await this.attachService.pendingUpload;
        return;
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : error;

        BdApi.UI.showToast(errorMessage, { type: 'error' });
        if (content === '') return;

        message.content = content;
      } finally {
        this.attachService.pendingUpload = undefined;
      }

      callDefault(...args);
      return;
    } catch (error) {
      Logger.warn('Error in onSendMessage', error);
    }
  }

  async onSendSticker(args, original) {
    const callDefault = original;

    const channelId = args[0];
    const stickerIdList = args[1];
    const stickerId = stickerIdList?.[0];

    if (channelId === undefined || stickerId === undefined) {
      callDefault(...args);
      return;
    }

    const sentSticker = await this.sendSticker(stickerId, channelId);
    if (!sentSticker) callDefault(...args);
  }

  async sendSticker(stickerId, channelId, content) {
    const sticker = this.modulesService.stickerStore.getStickerById(stickerId);
    const user = this.modulesService.userStore.getCurrentUser();
    const channel = this.modulesService.channelStore.getChannel(channelId);

    if (!channel) return false;
    if (!user) return false;

    const isSendable =
      this.modulesService.stickerSendabilityStore.isSendableStickerOriginal(
        sticker,
        user,
        channel
      );
    if (isSendable) return false;

    const url = `https://media.discordapp.net/stickers/${stickerId}`;
    const formatType = this.modulesService.stickerFormatType;
    let format;

    switch (sticker.format_type) {
      case formatType.APNG:
        format = 'apng';
        break;
      case formatType.GIF:
        format = 'gif';
        break;
      default:
        format = 'png';
        break;
    }

    const emote = {
      url,
      name: sticker.name,
      nameAndCommand: sticker.name,
      emoteLength: sticker.name.length,
      pos: 0,
      spoiler: false,
      commands: [['resize', '160']],
      channel: channelId,
      formatType: format,
      content,
    };

    try {
      this.attachService.pendingUpload = this.fetchBlobAndUpload(emote);
      await this.attachService.pendingUpload;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : error;

      BdApi.UI.showToast(errorMessage, { type: 'error' });
    } finally {
      this.attachService.pendingUpload = undefined;
    }

    return true;
  }

  getTargetEmoteFromMessage(message) {
    const invalidEmojis = message.invalidEmojis ?? [];
    const validNonShortcutEmojis = message.validNonShortcutEmojis ?? [];

    let emoji;
    let validEmoji = false;

    if (invalidEmojis.length > 0) {
      const count = invalidEmojis.length;
      emoji = invalidEmojis[count - 1];
    } else if (validNonShortcutEmojis?.length > 0) {
      const count = validNonShortcutEmojis.length;
      emoji = validNonShortcutEmojis[count - 1];

      // Ignore built-in emotes
      if (emoji?.managed === true) return {};
      validEmoji =
        emoji?.available === true &&
        !this.attachService.externalEmotes.has(emoji.id);
    } else return {};

    if (!emoji) return {};

    const emojiName = emoji.originalName ?? emoji.name;
    const allNamesString = emoji.allNamesString.replace(emoji.name, emojiName);
    const emojiText = `<${emoji.animated ? 'a' : ''}${allNamesString}${
      emoji.id
    }>`;

    const result = {};
    const url = emoji.url.split('?')[0] ?? '';
    if (!url) return {};
    const extensionIndex = url.lastIndexOf('.');

    result[emojiText] = {
      name: emojiName,
      url:
        url.substring(extensionIndex) === '.webp'
          ? `${url.substring(0, extensionIndex)}.png`
          : url,
    };

    const foundEmote = this.getTextPos(message.content, result);
    if (!foundEmote) return {};
    // Only parse valid emojis if they contain commands
    if (validEmoji && foundEmote.commands.length === 0) return {};

    return result;
  }

  getTextPos(content, emoteCandidates) {
    const foundEmotes = [];

    Object.entries(emoteCandidates).forEach(([key, value]) => {
      const regex = new RegExp('(?<!\\/)' + key + '(?<=\\b|>)', 'g');
      const regexCommand = new RegExp(key + '(\\.\\S{4,}\\b)+');
      const matches = content.match(regex);
      const command = content.match(regexCommand);

      if (!matches || matches.length === 0) return;
      for (let i = 0; i < matches.length; i++) {
        const pos = this.getNthIndexOf(content, key, i);
        const url = typeof value === 'string' ? value : value.url;

        const emote = {
          name: typeof value === 'string' ? key : value.name,
          nameAndCommand: key,
          url,
          emoteLength: key.length,
          pos,
          spoiler: false,
          commands: [],
          formatType: url.endsWith('.gif') ? 'gif' : 'png',
        };

        if (command) {
          const commands = command[0]?.split('.') ?? [];
          emote.commands = commands
            .filter((command) => command !== key)
            .map((command) => {
              const split = command.split('-');

              return [split[0] ?? '', split[1] ?? ''];
            });

          emote.nameAndCommand = command[0] ?? '';
        }

        const beforeEmote = content.substring(0, pos);
        const afterEmote = content.substring(pos + emote.nameAndCommand.length);

        if (beforeEmote.includes('||') && afterEmote.includes('||')) {
          const spoilerStart = beforeEmote.substring(beforeEmote.indexOf('||'));
          emote.nameAndCommand = spoilerStart + emote.nameAndCommand;
          emote.pos -= spoilerStart.length;

          const spoilerEnd = afterEmote.substring(
            0,
            afterEmote.indexOf('||') + 2
          );
          emote.nameAndCommand = emote.nameAndCommand + spoilerEnd;
          emote.spoiler = true;
        }

        if (!beforeEmote.includes('`') || !afterEmote.includes('`')) {
          foundEmotes.push(emote);
        }
      }
    });

    return foundEmotes.pop();
  }

  getNthIndexOf(input, search, nth) {
    const firstIndex = input.indexOf(search);
    const startPos = firstIndex + search.length;

    if (nth === 0) {
      return firstIndex;
    } else {
      const inputAfterFirstOccurrence = input.substring(startPos);
      const nextOccurrence = this.getNthIndexOf(
        inputAfterFirstOccurrence,
        search,
        nth - 1
      );

      if (nextOccurrence === -1) {
        return -1;
      } else {
        return startPos + nextOccurrence;
      }
    }
  }

  async fetchBlobAndUpload(emote) {
    const { url, name, commands, formatType } = emote;

    if (
      formatType === 'apng' ||
      formatType === 'gif' ||
      this.findCommand(commands, this.getGifModifiers())
    ) {
      return this.getMetaAndModifyGif(emote);
    }

    const resultBlob = (await this.compress(url, commands)) ?? new Blob([]);
    if (resultBlob.size === 0)
      throw new Error('Emote URL did not contain data');

    this.uploadFile({
      fileData: resultBlob,
      fullName: name + '.png',
      emote,
    });
  }

  findCommand(commands, names) {
    let foundCommand;

    commands.forEach((command) => {
      names.forEach((name) => {
        if (command[0] === name) foundCommand = command;
      });
    });

    return foundCommand;
  }

  getGifModifiers() {
    const gifModifiers = [];

    this.emoteService.modifiers.forEach((modifier) => {
      if (modifier.type === 'gif') {
        gifModifiers.push(modifier.name);
      }
    });

    return gifModifiers;
  }

  async getMetaAndModifyGif(emote) {
    const image = await Utils.loadImagePromise(emote.url);

    const commands = emote.commands;
    this.addResizeCommand(commands, image);
    let closeNotice;

    // Wait a bit before showing to prevent flickering
    const timeout = setTimeout(() => {
      closeNotice = BdApi.UI.showNotice(`Processing gif ${emote.name}...`, {
        type: 'info',
        buttons: [
          {
            label: 'Cancel',
            onClick: () => {
              cancel?.();
              cancel = undefined;

              closeNotice?.();
              closeNotice = undefined;
            },
          },
        ],
      });
    }, 250);

    let { cancel, result } = this.gifProcessingService.modifyGif(
      emote.url,
      emote.formatType,
      commands
    );

    const buffer = await result.finally(() => {
      cancel = undefined;
      clearTimeout(timeout);

      closeNotice?.();
      closeNotice = undefined;
    });

    if (buffer.length === 0) {
      throw Error('Failed to process gif');
    }

    this.uploadFile({
      fileData: buffer,
      fullName: emote.name + '.gif',
      emote,
    });
  }

  addResizeCommand(commands, image) {
    const scaleFactorNum = this.getScaleFactor(commands, image);
    let scaleFactor = scaleFactorNum.toString();

    const wideCommand = this.findCommand(commands, ['wide']);
    if (wideCommand) {
      const wideness = this.getEmoteWideness(wideCommand);
      scaleFactor = `${scaleFactorNum * wideness}x${scaleFactorNum}}`;
    }

    commands.push(['resize', scaleFactor]);
  }

  getScaleFactor(commands, image) {
    const size = this.getEmoteSize(commands);
    let scaleFactor;

    if (this.settingsService.settings.resizeMethod === 'largest') {
      if (image.width > image.height) {
        scaleFactor = size / image.width;
      } else scaleFactor = size / image.height;
    } else {
      if (image.width < image.height) {
        scaleFactor = size / image.width;
      } else scaleFactor = size / image.height;
    }

    return scaleFactor;
  }

  getEmoteSize(commands) {
    let resizeCommand = [];
    let size;

    commands.forEach((command, index, object) => {
      if (command[0] === 'resize') {
        resizeCommand = command;
        object.splice(index, 1);
      }
    });

    const resizeCommandSize = resizeCommand[1] ?? '';
    if (resizeCommandSize !== '') {
      size = resizeCommandSize;
    } else {
      size = Math.round(this.settingsService.settings.emoteSize);
    }

    if (size === 'large' || size === 'big') {
      return 128;
    } else if (size === 'medium' || size === 'normal') {
      return 64;
    } else {
      const sizeNumber = typeof size === 'string' ? parseInt(size) : size;
      if (!isNaN(sizeNumber)) {
        return Utils.clamp(sizeNumber, 32, 160);
      }

      return 48;
    }
  }

  getEmoteWideness(wideCommand) {
    const param = wideCommand[1];
    const paramNum = parseInt(param ?? '');

    if (!isNaN(paramNum)) {
      return Utils.clamp(paramNum, 2, 8);
    } else if (param === 'extreme') {
      return 8;
    } else if (param === 'huge') {
      return 6;
    } else if (param === 'big') {
      return 4;
    } else {
      return 2;
    }
  }

  uploadFile(params) {
    const { fileData, fullName, emote } = params;
    const content = emote.content ?? '';
    const channelId = emote.channel ?? '';
    if (!channelId) {
      Logger.error('Channel ID not found for emote:', emote);
      return;
    }

    const upload = new this.modulesService.cloudUploader.CloudUpload(
      { file: new File([fileData], fullName), platform: 1 },
      channelId
    );
    upload.spoiler = emote.spoiler;

    const uploadOptions = {
      channelId,
      uploads: [upload],
      draftType: 0,
      parsedMessage: {
        content,
        invalidEmojis: [],
        tts: false,
        channel_id: channelId,
      },
    };

    const pendingReply = this.attachService.pendingReply;
    if (pendingReply) {
      uploadOptions.options = {
        allowedMentions: {
          replied_user: pendingReply.shouldMention,
        },
        messageReference: {
          channel_id: pendingReply.message.channel_id,
          guild_id: pendingReply.channel.guild_id,
          message_id: pendingReply.message.id,
        },
      };
    }

    this.modulesService.uploader.uploadFiles(uploadOptions);
  }

  async compress(url, commands) {
    const image = await Utils.loadImagePromise(url);
    const canvas = await this.applyScaling(image, commands);

    return await new Promise((resolve) => {
      canvas.toBlob(
        (blob) => {
          resolve(blob ?? undefined);
        },
        'image/png',
        1
      );
    });
  }

  async applyScaling(image, commands) {
    const scaleFactor = this.getScaleFactor(commands, image);

    let canvas = document.createElement('canvas');
    canvas.width = image.width;
    canvas.height = image.height;

    if (commands.length > 0) {
      canvas = this.applyCommands(image, canvas, commands);
    } else {
      canvas.getContext('2d')?.drawImage(image, 0, 0);
    }

    const scaledBitmap = await createImageBitmap(canvas, {
      resizeWidth: Math.ceil(canvas.width * scaleFactor),
      resizeHeight: Math.ceil(canvas.height * scaleFactor),
      resizeQuality: 'high',
    });

    const resizedCanvas = document.createElement('canvas');
    resizedCanvas.width = scaledBitmap.width;
    resizedCanvas.height = scaledBitmap.height;

    const resizedContext = resizedCanvas.getContext('bitmaprenderer');
    if (!resizedContext) throw new Error('Bitmap context not found');
    resizedContext.transferFromImageBitmap(scaledBitmap);

    return resizedCanvas;
  }

  applyCommands(image, canvas, commands) {
    let scaleH = 1,
      scaleV = 1,
      posX = 0,
      posY = 0;

    if (this.findCommand(commands, ['flip'])) {
      scaleH = -1; // Set horizontal scale to -1 if flip horizontal
      posX = canvas.width * -1; // Set x position to -100% if flip horizontal
    }

    if (this.findCommand(commands, ['flap'])) {
      scaleV = -1; // Set vertical scale to -1 if flip vertical
      posY = canvas.height * -1; // Set y position to -100% if flip vertical
    }

    const ctx = canvas.getContext('2d');

    const wideCommand = this.findCommand(commands, ['wide']);
    if (wideCommand) {
      const wideness = this.getEmoteWideness(wideCommand);
      image.width = image.width * wideness;
      canvas.width = canvas.width * wideness;
    }

    const rotateCommand = this.findCommand(commands, ['rotate']);
    if (rotateCommand) {
      const angle = (parseInt(rotateCommand[1] ?? '0') * Math.PI) / 180,
        sin = Math.sin(angle),
        cos = Math.cos(angle);

      const newWidth =
        Math.abs(canvas.width * cos) + Math.abs(canvas.height * sin);
      const newHeight =
        Math.abs(canvas.width * sin) + Math.abs(canvas.height * cos);

      canvas.width = newWidth;
      canvas.height = newHeight;

      ctx?.translate(canvas.width / 2, canvas.height / 2);
      ctx?.rotate(angle);

      posX = -image.width / 2;
      posY = -image.height / 2;
    }

    ctx?.scale(scaleH, scaleV); // Set scale to flip the image
    ctx?.drawImage(image, posX, posY, image.width, image.height);

    return canvas;
  }

  stop() {
    // Do nothing
  }
}

class HtmlService extends BaseService {
  modulesService;

  start(modulesService) {
    this.modulesService = modulesService;
    return Promise.resolve();
  }

  addClasses(element, ...classes) {
    for (const curClass of classes) {
      if (!curClass) continue;
      const split = curClass.split(' ');

      for (const curClassItem of split) {
        element.classList.add(curClassItem);
      }
    }
  }

  getClassSelector(classes) {
    return classes
      .split(' ')
      .map((curClass) =>
        !curClass.startsWith('.') ? `.${curClass}` : curClass
      )
      .join(' ');
  }

  getTextAreaField(editor) {
    const textArea = this.modulesService.classes.TextArea.textArea;
    return editor?.closest(this.getClassSelector(textArea)) ?? undefined;
  }

  getTextAreaContainer(editor) {
    const channelTextArea =
      this.modulesService.classes.TextArea.channelTextArea;
    return editor?.closest(this.getClassSelector(channelTextArea)) ?? undefined;
  }

  getEditors() {
    const editor = this.modulesService.classes.Editor.editor;
    return document.querySelectorAll(this.getClassSelector(editor)) ?? [];
  }

  stop() {
    // Do nothing
  }
}

class PatchesService extends BaseService {
  sendMessageService;
  attachService;
  completionsService;
  emoteService;
  modulesService;

  start(
    sendMessageService,
    attachService,
    completionsService,
    emoteService,
    modulesService
  ) {
    this.sendMessageService = sendMessageService;
    this.attachService = attachService;
    this.completionsService = completionsService;
    this.emoteService = emoteService;
    this.modulesService = modulesService;

    this.messageStorePatch();
    this.changeDraftPatch();
    this.pendingReplyPatch();
    this.emojiSearchPatch();
    this.lockedEmojisPatch();
    this.stickerSendablePatch();

    return Promise.resolve();
  }

  messageStorePatch() {
    BdApi.Patcher.instead(
      this.plugin.meta.name,
      this.modulesService.messageStore,
      'sendMessage',
      (_, args, original) =>
        this.sendMessageService.onSendMessage(args, original)
    );

    BdApi.Patcher.instead(
      this.plugin.meta.name,
      this.modulesService.messageStore,
      'sendStickers',
      (_, args, original) =>
        this.sendMessageService.onSendSticker(args, original)
    );
  }

  changeDraftPatch() {
    BdApi.Patcher.before(
      this.plugin.meta.name,
      this.modulesService.draft,
      'changeDraft',
      (_, args) => this.onChangeDraft(args)
    );
  }

  onChangeDraft(args) {
    const channelId = args[0];
    if (channelId !== undefined) this.attachService.setCanAttach(channelId);
    if (!this.attachService.canAttach) return;

    const draft = args[1];
    if (draft === undefined) return;
    this.completionsService.draft = draft;

    try {
      const lastText = this.completionsService.cached?.draft;

      if (
        !this.emoteService.shouldCompleteEmote(draft) &&
        !this.emoteService.shouldCompleteCommand(draft)
      ) {
        this.completionsService.destroyCompletions();
        return;
      }

      if (lastText !== draft) {
        this.completionsService.renderCompletions();
      }
    } catch (err) {
      Logger.warn('Error in onChangeDraft', err);
    }
  }

  pendingReplyPatch() {
    const pendingReplyDispatcher = this.modulesService.pendingReplyDispatcher;

    const createPendingReply = pendingReplyDispatcher.createPendingReplyKey;
    if (createPendingReply === undefined) {
      Logger.warn('Create pending reply function name not found');
      return;
    }

    const deletePendingReply = pendingReplyDispatcher.deletePendingReplyKey;
    if (deletePendingReply === undefined) {
      Logger.warn('Delete pending reply function name not found');
      return;
    }

    const setPendingReplyShouldMention =
      pendingReplyDispatcher.setPendingReplyShouldMentionKey;
    if (setPendingReplyShouldMention === undefined) {
      Logger.warn('Set pending reply should mention function name not found');
      return;
    }

    BdApi.Patcher.before(
      this.plugin.meta.name,
      pendingReplyDispatcher.module,
      createPendingReply,
      (_, args) => {
        if (!args[0]) return;
        const reply = args[0];

        this.attachService.pendingReply = reply;
      }
    );

    BdApi.Patcher.instead(
      this.plugin.meta.name,
      pendingReplyDispatcher.module,
      deletePendingReply,
      (_, args, original) => this.onDeletePendingReply(args, original)
    );

    BdApi.Patcher.before(
      this.plugin.meta.name,
      pendingReplyDispatcher.module,
      setPendingReplyShouldMention,
      (_, args) => {
        if (typeof args[0] !== 'string' || typeof args[1] !== 'boolean') return;
        const channelId = args[0];
        const shouldMention = args[1];

        if (this.attachService.pendingReply?.channel.id !== channelId) return;
        this.attachService.pendingReply.shouldMention = shouldMention;
      }
    );
  }

  async onDeletePendingReply(args, original) {
    const callDefault = original;

    try {
      // Prevent Discord from deleting the pending reply until our emote has been uploaded
      if (this.attachService.pendingUpload)
        await this.attachService.pendingUpload;
      callDefault(...args);
    } catch (err) {
      Logger.warn('Error in onDeletePendingReply', err);
    } finally {
      this.attachService.pendingReply = undefined;
    }
  }

  emojiSearchPatch() {
    BdApi.Patcher.after(
      this.plugin.meta.name,
      this.modulesService.emojiSearch,
      'search',
      (_, _2, result) => this.onEmojiSearch(result)
    );
  }

  onEmojiSearch(result) {
    const searchResult = result;

    searchResult.unlocked.push(...searchResult.locked);
    searchResult.locked = [];
  }

  lockedEmojisPatch() {
    const emojiStore = this.modulesService.emojiStore;

    BdApi.Patcher.after(
      this.plugin.meta.name,
      emojiStore,
      'getEmojiUnavailableReason',
      (_, args, result) => this.onGetEmojiUnavailableReason(args, result)
    );

    BdApi.Patcher.after(
      this.plugin.meta.name,
      emojiStore,
      'isEmojiDisabled',
      (_, args) => this.onIsEmojiDisabled(args, emojiStore)
    );
  }

  onGetEmojiUnavailableReason(args, result) {
    const EmojiDisabledReasons = this.modulesService.emojiDisabledReasons;
    const options = args[0];

    const isReactIntention = options?.intention === 0;
    if (isReactIntention) return result;

    if (result === EmojiDisabledReasons.DISALLOW_EXTERNAL) {
      const emojiId = options?.emoji?.id;
      if (emojiId === undefined) return result;

      this.attachService.externalEmotes.add(emojiId);
      result = null;
    } else if (
      result === EmojiDisabledReasons.PREMIUM_LOCKED ||
      result === EmojiDisabledReasons.GUILD_SUBSCRIPTION_UNAVAILABLE
    ) {
      result = null;
    }

    return result;
  }

  onIsEmojiDisabled(args, emojiStore) {
    const [emoji, channel, intention] = args;

    const reason = emojiStore.getEmojiUnavailableReason({
      emoji,
      channel,
      intention,
    });

    return reason !== null;
  }

  stickerSendablePatch() {
    const stickerSendabilityStore = this.modulesService.stickerSendabilityStore;
    stickerSendabilityStore.isSendableStickerOriginal =
      stickerSendabilityStore.isSendableSticker;

    BdApi.Patcher.after(
      this.plugin.meta.name,
      stickerSendabilityStore,
      'getStickerSendability',
      (_, args) => {
        const sticker = args[0];
        if (!this.isSendableSticker(sticker)) return;

        return stickerSendabilityStore.StickerSendability.SENDABLE;
      }
    );

    BdApi.Patcher.after(
      this.plugin.meta.name,
      stickerSendabilityStore,
      'isSendableSticker',
      (_, args) => {
        const sticker = args[0];
        if (!this.isSendableSticker(sticker)) return;

        return true;
      }
    );
  }

  isSendableSticker(sticker) {
    return sticker?.type === this.modulesService.stickerType.GUILD;
  }

  stop() {
    BdApi.Patcher.unpatchAll(this.plugin.meta.name);
  }
}

class EmoteReplacerPlugin {
  settingsService;
  emoteService;
  completionsService;
  attachService;
  listenersService;
  gifProcessingService;
  modulesService;
  sendMessageService;
  htmlService;
  patchesService;

  meta;

  constructor(meta) {
    this.meta = meta;
    Logger.setLogger(meta.name);
  }

  start() {
    this.doStart().catch((error) => {
      Logger.error(error);
    });
  }

  async doStart() {
    const zeresPluginLibrary = window.ZeresPluginLibrary;

    this.showChangelogIfNeeded(zeresPluginLibrary);
    await this.startServicesAndPatches();
  }

  showChangelogIfNeeded(zeresPluginLibrary) {
    const currentVersionInfo =
      BdApi.Data.load(this.meta.name, CURRENT_VERSION_INFO_KEY) ?? {};

    if (
      currentVersionInfo.hasShownChangelog !== true ||
      currentVersionInfo.version !== this.meta.version
    ) {
      zeresPluginLibrary.Modals.showChangelogModal(
        `${this.meta.name} Changelog`,
        this.meta.version,
        PLUGIN_CHANGELOG
      );

      const newVersionInfo = {
        version: this.meta.version,
        hasShownChangelog: true,
      };

      BdApi.Data.save(this.meta.name, CURRENT_VERSION_INFO_KEY, newVersionInfo);
    }
  }

  async startServicesAndPatches() {
    const zeresPluginLibrary = window.ZeresPluginLibrary;

    this.listenersService = new ListenersService(this, zeresPluginLibrary);
    await this.listenersService.start();

    this.settingsService = new SettingsService(this, zeresPluginLibrary);
    await this.settingsService.start(this.listenersService);

    this.modulesService = new ModulesService(this, zeresPluginLibrary);
    await this.modulesService.start();

    this.htmlService = new HtmlService(this, zeresPluginLibrary);
    await this.htmlService.start(this.modulesService);

    this.emoteService = new EmoteService(this, zeresPluginLibrary);
    await this.emoteService.start(
      this.listenersService,
      this.settingsService,
      this.htmlService
    );

    this.attachService = new AttachService(this, zeresPluginLibrary);
    await this.attachService.start(this.modulesService);

    this.completionsService = new CompletionsService(this, zeresPluginLibrary);
    await this.completionsService.start(
      this.emoteService,
      this.settingsService,
      this.modulesService,
      this.listenersService,
      this.htmlService,
      this.attachService
    );

    this.gifProcessingService = new GifProcessingService(
      this,
      zeresPluginLibrary
    );
    await this.gifProcessingService.start();

    this.sendMessageService = new SendMessageService(this, zeresPluginLibrary);
    await this.sendMessageService.start(
      this.emoteService,
      this.attachService,
      this.modulesService,
      this.settingsService,
      this.gifProcessingService
    );

    this.patchesService = new PatchesService(this, zeresPluginLibrary);
    await this.patchesService.start(
      this.sendMessageService,
      this.attachService,
      this.completionsService,
      this.emoteService,
      this.modulesService
    );
  }

  observer(e) {
    if (!e.addedNodes.length || !(e.addedNodes[0] instanceof Element)) return;
    const elem = e.addedNodes[0];

    const modulesService = this.modulesService;
    if (!modulesService) return;

    const textAreaSelector = this.htmlService?.getClassSelector(
      modulesService.classes.TextArea.textArea
    );

    if (
      textAreaSelector !== undefined &&
      elem.querySelector(textAreaSelector)
    ) {
      this.listenersService?.requestAddListeners(CompletionsService.TAG);
    }
  }

  onSwitch() {
    this.completionsService?.destroyCompletions();
  }

  getSettingsPanel() {
    return this.settingsService?.getSettingsElement() ?? new HTMLElement();
  }

  stop() {
    this.patchesService?.stop();
    this.patchesService = undefined;

    this.sendMessageService?.stop();
    this.sendMessageService = undefined;

    this.gifProcessingService?.stop();
    this.gifProcessingService = undefined;

    this.completionsService?.stop();
    this.completionsService = undefined;

    this.attachService?.stop();
    this.attachService = undefined;

    this.emoteService?.stop();
    this.emoteService = undefined;

    this.htmlService?.stop();
    this.htmlService = undefined;

    this.modulesService?.stop();
    this.modulesService = undefined;

    this.settingsService?.stop();
    this.settingsService = undefined;

    this.listenersService?.stop();
    this.listenersService = undefined;
  }
}

const bdWindow = window;

var index =
  bdWindow.ZeresPluginLibrary === undefined ? RawPlugin : EmoteReplacerPlugin;

module.exports = index;

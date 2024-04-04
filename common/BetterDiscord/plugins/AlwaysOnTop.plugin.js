/**
 * @name AlwaysOnTop
 * @author Qwerasd
 * @description Keep the Discord window from being hidden under other windows.
 * @version 1.2.2
 * @authorId 140188899585687552
 * @updateUrl https://betterdiscord.app/gh-redirect?id=611
 */
// utils/BdApi.ts
const { React, ReactDOM, Patcher, Webpack, Webpack: { getModule, waitForModule, Filters, Filters: { byProps } }, DOM, Data, UI } = new BdApi('AlwaysOnTop');
// AlwaysOnTop/src/AlwaysOnTop.plugin.tsx
const FormTitle = getModule(byProps('Tags', 'Sizes'));
const FormText = getModule(m => m?.Sizes?.SIZE_32 && m.Colors);
const FormDivider = getModule(m => m?.toString?.()?.includes?.('().divider'));
const SwitchItem = getModule(m => m?.toString?.()?.includes?.('helpdeskArticleId'));
const Switch = ({ onChange, defaultValue, note, children }) => {
    const [value, setValue] = React.useState(defaultValue);
    const onChangeFunc = newValue => {
        onChange(newValue);
        setValue(newValue);
    };
    return BdApi.React.createElement(SwitchItem, { onChange: onChangeFunc, note, value, children });
};
const setAlwaysOnTop = v => {
    // @ts-ignore
    window.DiscordNative.window.setAlwaysOnTop(0, v);
    UI.showToast(`Always on top ${v ? 'enabled' : 'disabled'}.`, {
        type: v ? 'success' : 'error'
    });
};
const isMac = process.platform === 'darwin';
const createKeybindObject = async e => {
    // @ts-ignore
    const layoutMap = await navigator.keyboard.getLayoutMap();
    return {
        location: e.location,
        key: e.code,
        ctrl: e.ctrlKey,
        alt: e.altKey,
        shift: e.shiftKey,
        meta: e.metaKey,
        keyName: layoutMap.get(e.code)?.toUpperCase() ?? e.code
    };
};
const { useState, useRef } = React;
const KeybindRecorder = props => {
    const [keybind, setKeybind] = useState(props.default);
    const [recording, setRecording] = useState(false);
    const input = useRef(null);
    const startRecording = () => {
        setRecording(true);
        input.current.focus();
    };
    const stopRecording = () => {
        setRecording(false);
        input.current.blur();
    };
    const handleKeyDown = async e => {
        if ([
            'Alt', 'Shift', 'Control', 'Meta'
        ].includes(e.key)) return;
        if (recording) {
            const k = await createKeybindObject(e);
            setKeybind(k);
            props.onChange(k);
            stopRecording();
        }
    };
    // @ts-ignore
    navigator.keyboard.getLayoutMap()
        .then(layoutMap => {
            const newKeyName = layoutMap.get(keybind.key)?.toUpperCase() ?? keybind.key;
            if (newKeyName !== keybind.keyName) {
                setKeybind({ ...keybind, keyName: newKeyName });
            }
        });
    if (recording) input.current.focus();
    // if for some reason the component re-renders in the middle of recording, focus the input again
    return BdApi.React.createElement(
        'div', {
            className: `keybind-recorder ${recording ? 'recording' : ''}`
        },
        BdApi.React.createElement('span', { className: 'keybind-recorder-control-keys' }, [
            keybind.meta ? isMac ? '⌘ Command' : '⊞ Win' : '',
            keybind.ctrl ? '⌃ Ctrl' : '', keybind.alt ? isMac ? '⌥ Option' : '⎇ Alt' : '',
            keybind.shift ? '⇧ Shift' : ''
        ].filter(Boolean).map(k => k + ' + ').join('')),
        BdApi.React.createElement('span', { className: 'keybind-recorder-key' }, keybind.keyName),
        BdApi.React.createElement('span', { className: 'keybind-recorder-controls' }, BdApi.React.createElement('button', { onClick: startRecording }, 'Record'), BdApi.React.createElement('button', {
            onClick: () => {
                setKeybind(props.default);
                props.onChange(props.default);
            }
        }, 'Reset')),
        BdApi.React.createElement('input', { type: 'text', ref: input, onKeyDown: handleKeyDown, onBlur: stopRecording })
    );
};
// Check the window is within 4 px of filling available space
// because sometimes "maximized" windows don't actually fill all space -_-
const isMaximized = () => window.screen.availWidth - window.outerWidth < 4 && window.screen.availHeight - window.outerHeight < 4;
module.exports = class AlwaysOnTop {
    constructor() {
        this.state = Data.load('state') ?? true;
        this.keybind = Data.load('keybind') ?? ({
            location: 0,
            key: 'F11',
            keyName: 'F11',
            ctrl: !isMac,
            meta: isMac,
            alt: false,
            shift: false
        });
        this.boundKeyDown = this.onKeyDown.bind(this);
        this.boundResize = this.onResize.bind(this);
        this.disableWhenMaximized = Data.load('disableWhenMaximized') ?? false;
        this.disabledByMaximization = false;
    }
    start() {
        if (this.disableWhenMaximized && isMaximized()) {
            this.disabledByMaximization = this.state;
        } else if (this.state) {
            setAlwaysOnTop(true);
        }
        document.addEventListener('keydown', this.boundKeyDown);
        window.addEventListener('resize', this.boundResize);
        DOM.addStyle(`
            .keybind-recorder {
                color: #fff;
                background-color: #000;
                position: relative;
                display: inline-block;
                padding: 8px;
                padding-right: 12ch;
                border-radius: 8px;
                border: 1px solid white;
            }

            .keybind-recorder.recording {
                border-color: #ff0000;
            }

            .keybind-recorder-control-keys,
            .keybind-recorder-key {
                vertical-align: text-bottom;
            }

            .keybind-recorder-controls {
                position: absolute;
                right: 8px;
            }

            .keybind-recorder-controls button:first-child {
                margin-right: 4px;
            }

            .keybind-recorder input {
                width: 0;
                border: 0;
                padding: 0;
            }
        `);
    }
    stop() {
        setAlwaysOnTop(false);
        document.removeEventListener('keydown', this.boundKeyDown);
        window.removeEventListener('resize', this.boundResize);
        DOM.removeStyle();
    }
    onResize() {
        if (!this.state || !this.disableWhenMaximized) return;
        if (isMaximized()) {
            setAlwaysOnTop(false);
            this.disabledByMaximization = true;
        } else if (this.disabledByMaximization) {
            setAlwaysOnTop(true);
            this.disabledByMaximization = false;
        }
    }
    async onKeyDown (e) {
        const { key, ctrl, alt, shift, meta } = this.keybind;
        const k = await createKeybindObject(e);
        if (k.key === key && k.ctrl === ctrl && k.alt === alt && k.shift === shift && k.meta === meta) {
            this.state = !this.state;
            setAlwaysOnTop(this.state);
            Data.save('state', this.state);
        }
    }
    getSettingsPanel() {
        return BdApi.React.createElement(
            BdApi.React.Fragment, null,
            BdApi.React.createElement(FormTitle, null, 'Keybind'),
            BdApi.React.createElement(FormText, null, 'Key combo to toggle always on top functionality.'),
            BdApi.React.createElement('br', null),
            BdApi.React.createElement(KeybindRecorder, {
                default: this.keybind,
                onChange: k => {
                    this.keybind = k;
                    Data.save('keybind', k);
                }
            }),
            BdApi.React.createElement('br', null),
            BdApi.React.createElement('br', null),
            BdApi.React.createElement(FormDivider, null),
            BdApi.React.createElement('br', null),
            BdApi.React.createElement(Switch, {
                onChange: value => {
                    this.disableWhenMaximized = value;
                    Data.save('disableWhenMaximized', this.disableWhenMaximized);
                },
                note: 'When the window is maximized, disable always on top functionality.',
                defaultValue: this.disableWhenMaximized
            }, 'Disable When Maximized')
        );
    }
};
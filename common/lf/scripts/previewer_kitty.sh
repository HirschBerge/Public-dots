#!/usr/bin/env bash
preview_image() {
    file=$1
    w=$2
    h=$3
    x=$4
    y=$5

    # Rescale the image
    w=$(( w * 99 / 100 ))
    h=$(( h * 99 / 100 ))
    y=$(( y + 1 ))

    if [[ "$( file -Lb --mime-type "$file")" =~ ^image ]]; then
        # kitty +icat --silent --transfer-mode file --place "${w}x${h}@${x}x${y}" "$file"
        kitten icat --transfer-mode file --stdin no --place "${w}x${h}@${x}x${y}" "$file" < /dev/null > /dev/tty
        exit 1
    fi

    pistol "$file"
}

preview_text() {
    file="$1"
    shift
    if command -v bat > /dev/null 2>&1; then
        # bat --color=always --style=plain --pager=never "$file" "$@"
        bat --color=always --style=numbers --pager=never "$file" "$@"
    else
        cat "$file"
    fi
}

preview_doc() {
    file="$1"
    if command -v catdoc > /dev/null 2>&1; then
        catdoc "$file"
    elif command -v textutil > /dev/null 2>&1; then
        textutil -stdout -cat txt "$file" | bat --color=always --style=numbers --pager=never
    fi
}

preview_docx() {
    file_docx="$1"
    file_txt="${file_docx/%.docx/.txt}"

    # MacOS
    if command -v docx2txt.sh > /dev/null 2>&1; then
        docx2txt.sh "$file_docx" > /dev/null
    # Linux
    elif command -v  docx2txt > /dev/null 2>&1; then
        docx2txt < "$file_docx"
    fi

    preview_text "$file_txt"
    rm "$file_txt"
}

preview_nb() {
    if command -v nbpreview > /dev/null 2>&1; then
        nbpreview --theme material --image-drawing block "$1"
    else
        preview_text "$1"
    fi
}

# CACHE="$HOME/.cache/lf/thumbnail.$(stat --printf '%n\0%i\0%F\0%s\0%W\0%Y' -- "$(readlink -f "$1")" | sha256sum | awk '{print $1}')"
CACHE="$HOME/.cache/lf/thumbnail.$(stat "$(readlink -f "$1")" | sha256sum | awk '{print $1}')"
mkdir -p "$HOME/.cache/lf"

case "$(printf "%s\n" "$(readlink -f "$1")" | awk '{print tolower($0)}')" in
    *.tgz|*.tar.gz)
        tar tzf "$1"
        ;;
    *.md)
        preview_text "$1"
        ;;
    *.tar.bz2|*.tbz2)
        tar tjf "$1"
        ;;
    *.tar.txz|*.txz)
        xz --list "$1"
        ;;
    *.tar)
        tar tf "$1"
        ;;
    *.zip|*.jar|*.war|*.ear|*.oxt)
        unzip -l "$1"
        ;;
    *.rar)
        unrar l "$1"
        ;;
    *.7z)
        7z l "$1"
        ;;
    *.[1-8])
        man "$1" | col -b
        ;;
    *.o)
        nm "$1"
        ;;
    *.torrent)
        transmission-show "$1"
        ;;
    *.iso)
        iso-info --no-header -l "$1"
        ;;
    *.odt|*.ods|*.odp|*.sxw)
        odt2txt "$1"
        ;;
    *.doc)
        # catdoc "$1"
        preview_doc "$1"
        ;;
    *.docx)
        preview_docx "$1"
        ;;
    *.xls|*.xlsx)
        ssconvert --export-type=Gnumeric_stf:stf_csv "$1" "fd://1" | preview_text --language=csv
        ;;
    *.wav|*.mp3|*.flac|*.m4a|*.wma|*.ape|*.ac3|*.og[agx]|*.spx|*.opus|*.as[fx]|*.mka)
        exiftool "$1"
        ;;
    *.pdf)
        [ ! -f "${CACHE}.jpg" ] && pdftoppm -jpeg -f 1 -singlefile "$1" "$CACHE"
        preview_image "${CACHE}.jpg" "$2" "$3" "$4" "$5"
        ;;
    *.epub)
        [ ! -f "$CACHE" ] && epub-thumbnailer "$1" "$CACHE" 1024
        preview_image "$CACHE" "$2" "$3" "$4" "$5"
        ;;
    *.cbz|*.cbr|*.cbt)
        [ ! -f "$CACHE" ] && comicthumb "$1" "$CACHE" 1024
        preview_image "$CACHE" "$2" "$3" "$4" "$5"
        ;;
    *.html)
        [ ! -f "$CACHE" ] && wkhtmltopdf "$1" - | pdftoppm -jpeg -f 1 -singlefile - "$CACHE"
        preview_image "${CACHE}.jpg" "$2" "$3" "$4" "$5"
        ;;
    *.avi|*.mp4|*.wmv|*.dat|*.3gp|*.ogv|*.mkv|*.mpg|*.mpeg|*.vob|*.fl[icv]|*.m2v|*.mov|*.webm|*.ts|*.mts|*.m4v|*.r[am]|*.qt|*.divx)
        [ ! -f "${CACHE}.jpg" ] && ffmpegthumbnailer -i "$1" -o "${CACHE}.jpg" -s 0 -q 5
        preview_image "${CACHE}.jpg" "$2" "$3" "$4" "$5"
        ;;
    *.bmp|*.jpg|*.jpeg|*.png|*.xpm|*.webp|*.gif|*.jfif)
        preview_image "$1" "$2" "$3" "$4" "$5"
        ;;
    *.ino)
        preview_text --language=cpp "$1"
        ;;
    *.ipynb)
        preview_nb "$1"
        ;;
    *)
        preview_text "$1"
        ;;
esac
exit 0

{
  ...
}: 
{
  programs.zathura = {
    enable = true;
    options = {
      default-fg = "#c9c7cd";
      default-bg = "#161617";
      completion-bg = "#1b1b1c";
      completion-fg = "#c9c7cd";
      completion-highlight-bg = "#313134";
      completion-highlight-fg = "#c9c7cd";
      completion-group-bg = "#1b1b1c";
      completion-group-fg = "#92a2d5";
      statusbar-fg = "#c9c7cd";
      statusbar-bg = "#1b1b1c";
      notification-bg = "#1b1b1c";
      notification-fg = "#c9c7cd";
      notification-error-bg = "#1b1b1c";
      notification-error-fg = "#ea83a5";
      notification-warning-bg = "#1b1b1c";
      notification-warning-fg = "#f5a191";
      inputbar-fg = "#c9c7cd";
      inputbar-bg = "#1b1b1c";
      recolor-lightcolor = "#161617";
      recolor-darkcolor = "#c9c7cd";
      index-fg = "#c9c7cd";
      index-bg = "#161617";
      index-active-fg = "#c9c7cd";
      index-active-bg = "#1b1b1c";
      render-loading-bg = "#161617";
      render-loading-fg = "#c9c7cd";
      highlight-color = "#313134";
      highlight-fg = "#e29eca";
      highlight-active-color = "#e29eca";
      selection-clipboard= "clipboard";
      synctex = "true";
      synctex-editor-command = "code -g %{input}:%{line}";
      recolor = "true";
      recolor-keephue = "true";
    };
  };
}

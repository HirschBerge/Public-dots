{ pkgs, lib, ... }:
{
  programs.helix = {
  enable = true;
    languages = {
      language = [
        {
          name = "rust";
          auto-format = true;
        }
        {
          name = "python";
          scope = "source.python";
          injection-regex = "python";
          file-types = ["py""pyi""py3""pyw"".pythonstartup"".pythonrc"];
          shebangs = [ "python" "python3" ];
          roots = ["." "pyproject.toml" "pyrightconfig.json"];
          comment-token = "#";
          language-servers = [ "pyright" "ruff" ];
          indent = ''{ tab-width = 4, unit = "    " }'';
          auto-format = true;
          formatter = {
            command = "black";
            args = ["-" "--quiet" "--line-length=88" ];
          };
        }
      ];
    };
  };
}

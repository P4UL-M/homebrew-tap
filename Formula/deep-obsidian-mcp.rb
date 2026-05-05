# typed: false

class DeepObsidianMcp < Formula
  desc "Filesystem-first MCP server for deep Obsidian vault access"
  homepage "https://github.com/P4UL-M/deep-obsidian-mcp"
  url "https://github.com/P4UL-M/deep-obsidian-mcp/archive/refs/tags/v0.1.0-alpha.3.tar.gz"
  sha256 "53116b2d6e4bcd77eeca0135f66c81fb4b122e767815ec1b6aaa12957a7e7076"
  license "MIT"
  version "0.1.0-alpha.3"

  depends_on "rust" => :build
  depends_on "ripgrep"

  def install
    system "cargo", "install", *std_cargo_args(path: "rust/crates/deep-obsidian-cli")
    pkgshare.install "assets"
    pkgshare.install "skills"
    pkgshare.install "obsidian-snippets"
    (var/"log/deep-obsidian-mcp").mkpath
  end

  def caveats
    <<~EOS
      Configure the service before starting it:
        deep-obsidian-mcp setup-service --vault ~/Vault --mcp --skills --vault-snippets

      Then start and validate:
        brew services start P4UL-M/tap/deep-obsidian-mcp
        deep-obsidian-mcp doctor
        curl -fsS http://127.0.0.1:4100/readyz

      Homebrew services run in packaged mode, so default indexes live outside the vault under:
        ~/Library/Application Support/deep-obsidian-mcp/indexes/<vault-hash>

      Agent skill templates are installed under:
        #{opt_pkgshare}/skills

      Obsidian CSS snippets are installed under:
        #{opt_pkgshare}/obsidian-snippets

      Project icons and logo assets are installed under:
        #{opt_pkgshare}/assets

      setup-service --skills copies them into Codex and Claude Code skill directories.
      setup-service --mcp configures Codex and Claude Code MCP client entries.
      setup-service --vault-snippets copies packaged Obsidian snippets into the vault and enables them.
    EOS
  end

  service do
    run [opt_bin/"deep-obsidian-mcp", "serve", "--packaged", "--transport", "http"]
    keep_alive true
    environment_variables DEEP_OBSIDIAN_PACKAGED: "1"
    log_path var/"log/deep-obsidian-mcp/output.log"
    error_log_path var/"log/deep-obsidian-mcp/error.log"
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/deep-obsidian-mcp help")
    assert_match "deep-obsidian-mcp", shell_output("#{bin}/deep-obsidian-mcp version")
  end
end

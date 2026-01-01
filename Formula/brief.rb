class Brief < Formula
  desc "Terminal-first chat client with slash commands and tool execution"
  homepage "https://github.com/WilliamAGH/brief"
  url "https://github.com/WilliamAGH/brief/releases/download/v0.1.4/brief-0.1.4.zip"
  sha256 "9ec834655c4153ed4af93db115f6d8b627e34dc962d429686fccdb01c9af9d38"
  license "MIT"

  # Install latest from dev branch: brew install --head williamagh/tap/brief
  head "https://github.com/WilliamAGH/brief.git", branch: "dev"

  depends_on "openjdk"

  def install
    if build.head?
      # Build from source for --head installs
      ENV["JAVA_HOME"] = Formula["openjdk"].opt_prefix
      system "./gradlew", "installDist", "-q"

      cd "build/install/brief" do
        rm Dir["bin/*.bat"]
        libexec.install Dir["*"]
      end
    else
      # Pre-built release distribution
      rm Dir["bin/*.bat"]
      libexec.install Dir["*"]
    end

    # Create wrapper script that sets JAVA_HOME
    (bin/"brief").write_env_script libexec/"bin/brief",
      JAVA_HOME: Formula["openjdk"].opt_prefix
  end

  def caveats
    <<~EOS
      brief requires an API key to function.

      Just run `brief` — the app will guide you through setup if no API key is configured.

      Or configure manually:
        export OPENAI_API_KEY="your-key-here"

      See: https://github.com/WilliamAGH/brief/blob/main/docs/environment-variables-api-keys.md
    EOS
  end

  test do
    # Basic smoke test - the app will fail without API key but should at least start
    assert_match "brief", shell_output("#{bin}/brief --help 2>&1", 1)
  end
end

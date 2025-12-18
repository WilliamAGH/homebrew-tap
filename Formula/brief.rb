class Brief < Formula
  desc "Terminal-first chat client with slash commands and tool execution"
  homepage "https://github.com/WilliamAGH/brief"
  url "https://github.com/WilliamAGH/brief/releases/download/v${VERSION}/brief-${VERSION}.zip"
  sha256 "${SHA256}"
  license "MIT"

  # Install latest from main branch: brew install --head williamagh/tap/brief
  head "https://github.com/WilliamAGH/brief.git", branch: "main"

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
      brief requires an API key to function. Set up your environment:

        cp #{opt_prefix}/.env-example ~/.config/brief/.env
        # Edit ~/.config/brief/.env with your API key

      Or set OPENAI_API_KEY in your shell profile.
      See: https://github.com/WilliamAGH/brief/blob/main/docs/environment-variables-api-keys.md
    EOS
  end

  test do
    # Basic smoke test - the app will fail without API key but should at least start
    assert_match "brief", shell_output("#{bin}/brief --help 2>&1", 1)
  end
end

# frozen_string_literal: true

class JexlExecutor < Formula
  desc "JEXL scripts executor"
  homepage "https://github.com/siakhooi/jexl-executor"
  version "1.6.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/jexl-executor/releases/download/#{version}/jexl-executor-#{version}-macos-arm64.zip"
      sha256 "b2733c21ad81414eddbf7c5730d8f7cc583108152efd7ff9de214e1d7d8d6922"
    end
    on_intel do
      url "https://github.com/siakhooi/jexl-executor/releases/download/#{version}/jexl-executor.jar"
      sha256 "aad287f9195d27f9ba90e2d37b19b6fe9e117ced78bb8bcacfb6163e52faba4f"

      depends_on "openjdk"
    end
  end

  on_linux do
    url "https://github.com/siakhooi/jexl-executor/releases/download/#{version}/jexl-executor.jar"
    sha256 "aad287f9195d27f9ba90e2d37b19b6fe9e117ced78bb8bcacfb6163e52faba4f"

    depends_on "openjdk"
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      prefix.install "jexl-executor.app"
      bin.install_symlink prefix/"jexl-executor.app/Contents/MacOS/jexl-executor"
    else
      libexec.install "jexl-executor.jar"
      bin.write_jar_script libexec/"jexl-executor.jar", "jexl-executor"
    end
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/jexl-executor -V").strip
  end
end

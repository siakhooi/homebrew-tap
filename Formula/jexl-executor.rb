# frozen_string_literal: true

class JexlExecutor < Formula
  desc "JEXL scripts executor"
  homepage "https://github.com/siakhooi/jexl-executor"
  version "1.6.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/jexl-executor/releases/download/#{version}/jexl-executor-#{version}-macos-arm64.zip"
      sha256 "73818dcfbe85355d6ece2d0c9754ea8cfa6b17e6c2c38926ae494b6adb859a29"
    end
    on_intel do
      url "https://github.com/siakhooi/jexl-executor/releases/download/#{version}/jexl-executor.jar"
      sha256 "1e3663fda5e4cdf1b32073cc284aeae2898901227e09ab92fee3d0f6d7f86c6d"

      depends_on "openjdk"
    end
  end

  on_linux do
    url "https://github.com/siakhooi/jexl-executor/releases/download/#{version}/jexl-executor.jar"
    sha256 "1e3663fda5e4cdf1b32073cc284aeae2898901227e09ab92fee3d0f6d7f86c6d"

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

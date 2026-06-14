# frozen_string_literal: true

class Semvery < Formula
  desc "Java semver utilities"
  homepage "https://github.com/siakhooi/semvery"
  version "1.1.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/semvery/releases/download/#{version}/semvery-#{version}-macos-arm64.zip"
      sha256 "fed2f69c50b96654754b9654d223e5ed5a6871fcaa68e20803d125b92266365f"
    end
    on_intel do
      url "https://github.com/siakhooi/semvery/releases/download/#{version}/semvery-#{version}-jar-with-dependencies.jar"
      sha256 "17a7d7fb2dc99493245a4662567c46320ea6e460db36855f4325c19dba30c104"

      depends_on "openjdk"
    end
  end

  on_linux do
    url "https://github.com/siakhooi/semvery/releases/download/#{version}/semvery-#{version}-jar-with-dependencies.jar"
    sha256 "17a7d7fb2dc99493245a4662567c46320ea6e460db36855f4325c19dba30c104"

    depends_on "openjdk"
  end

  def install
    if OS.mac? && Hardware::CPU.arm?
      prefix.install "semvery.app"
      bin.install_symlink prefix/"semvery.app/Contents/MacOS/semvery"
    else
      libexec.install "semvery-#{version}-jar-with-dependencies.jar"
      bin.write_jar_script libexec/"semvery-#{version}-jar-with-dependencies.jar", "semvery"
    end
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/semvery --version").strip
  end
end

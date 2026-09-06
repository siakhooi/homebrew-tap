# frozen_string_literal: true

class Semvery < Formula
  desc "Java semver utilities"
  homepage "https://github.com/siakhooi/semvery"
  version "1.1.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/semvery/releases/download/#{version}/semvery-#{version}-macos-arm64.zip"
      sha256 "833443f5b7ce21f5027f317a660b5c34c95519b730b2e4276fbdb8ca769ea727"
    end
    on_intel do
      url "https://github.com/siakhooi/semvery/releases/download/#{version}/semvery-#{version}-jar-with-dependencies.jar"
      sha256 "d742e627243f047100e2c39d4fd08436fde0462de8de32c929ef69cf3cc7fb0d"

      depends_on "openjdk"
    end
  end

  on_linux do
    url "https://github.com/siakhooi/semvery/releases/download/#{version}/semvery-#{version}-jar-with-dependencies.jar"
    sha256 "d742e627243f047100e2c39d4fd08436fde0462de8de32c929ef69cf3cc7fb0d"

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

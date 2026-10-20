# frozen_string_literal: true

class Cooonfig < Formula
  desc "Combine multiple configuration sources into a unified model and generate configuration and environment files."
  homepage "https://github.com/siakhooi/cooonfig"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/cooonfig/releases/download/v#{version}/cooonfig_#{version}_Darwin_arm64.tar.gz"
      sha256 "cae7fc3e654da202e3261639ba415e417ede039000ff42377d10516b390f510d"
    end
    on_intel do
      url "https://github.com/siakhooi/cooonfig/releases/download/v#{version}/cooonfig_#{version}_Darwin_x86_64.tar.gz"
      sha256 "df0b21ba05eb8b133f18dc4a502d36ed9e597e73423ccfa42c23ef0979a8d148"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/cooonfig/releases/download/v#{version}/cooonfig_#{version}_Linux_arm64.tar.gz"
      sha256 "e1bf13c0d254d3f064dacf3308ecebee89cd5998fb1559bdd49536f5ac57ba55"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/cooonfig/releases/download/v#{version}/cooonfig_#{version}_Linux_x86_64.tar.gz"
      sha256 "bb54451c30214d0bf0b611565887c00ba1e1e82b40fdc0ddd319c9946b9e72d4"
    end
  end

  def install
    bin.install "cooonfig"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cooonfig --version")
  end
end

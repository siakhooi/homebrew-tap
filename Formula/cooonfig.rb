# frozen_string_literal: true

class Cooonfig < Formula
  desc "Combine multiple configuration sources into a unified model and generate configuration and environment files."
  homepage "https://github.com/siakhooi/cooonfig"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/cooonfig/releases/download/v#{version}/cooonfig_#{version}_Darwin_arm64.tar.gz"
      sha256 "33044ea79c006aa9e3a8405f2c376a4defe1548fb8b7b8163a0af57e7e3d8f10"
    end
    on_intel do
      url "https://github.com/siakhooi/cooonfig/releases/download/v#{version}/cooonfig_#{version}_Darwin_x86_64.tar.gz"
      sha256 "57ad6281dc8f0ac42f2210f80ed4808bab59f9426f361acbf8e7e2bb6b776800"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/cooonfig/releases/download/v#{version}/cooonfig_#{version}_Linux_arm64.tar.gz"
      sha256 "691480adeed2370ede71c4914c8b0995b3d1c7e5b47a530cf59f53640849a953"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/cooonfig/releases/download/v#{version}/cooonfig_#{version}_Linux_x86_64.tar.gz"
      sha256 "be16f41079c5a4bf78ba30b061b5e918a7f6126915ad0fa43a4bd74cde09f74c"
    end
  end

  def install
    bin.install "cooonfig"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/cooonfig --version")
  end
end

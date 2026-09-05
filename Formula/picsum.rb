# frozen_string_literal: true

class Picsum < Formula
  desc "CLI client for picsum.photos"
  homepage "https://github.com/siakhooi/picsum"
  version "1.2.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Darwin_arm64.tar.gz"
      sha256 "70b15d104aa09a2891367b867108c375ebefeaa21031329e6310c741f38234eb"
    end
    on_intel do
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Darwin_x86_64.tar.gz"
      sha256 "ed4587f04684a4ea61de10c0f23ac01494bf96e466e1bbe9ec909d3a29e54c1a"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_arm64.tar.gz"
      sha256 "3003efd84a9973aeb40af9a6a5bbe135ff7d9b8cdadd499623ab0dcc220df6b3"
    elsif Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_x86_64.tar.gz"
        sha256 "79d364638aeb37e09dc05f2d075d91af8f7503bdbbb9d24a244c1e2b9104f6f0"
      else
        url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_i386.tar.gz"
        sha256 "6e2699665b25668d272bc04aea909c5edfc3c794b3ff1c53e39d449717adb077"
      end
    end
  end

  def install
    bin.install "picsum"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/picsum --version")
  end
end

# frozen_string_literal: true

class Picsum < Formula
  desc "CLI client for picsum.photos"
  homepage "https://github.com/siakhooi/picsum"
  version "1.2.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Darwin_arm64.tar.gz"
      sha256 "842789079b3f8f81f3b5b6a8a95020b25252fd54c2d31f555ee83452ccdc8af3"
    end
    on_intel do
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Darwin_x86_64.tar.gz"
      sha256 "8010bd680cad5eb5d4e8cfea2b351f379fef9499fdb9f8cc5afa809c62bacef4"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_arm64.tar.gz"
      sha256 "ee00c77697c4e571dc988ced5e4ed67ba047816578e805cf1eb12a0e0e04c597"
    elsif Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_x86_64.tar.gz"
        sha256 "8b18dd42256b378ad0db4820074112c6befed678b5eb1dee2dd377283e2fbf88"
      else
        url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_i386.tar.gz"
        sha256 "517548a31960a4ed66784123fe0ac7b20e36b01aa3bb316f108a6cb287f134c4"
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

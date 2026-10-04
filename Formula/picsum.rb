# frozen_string_literal: true

class Picsum < Formula
  desc "CLI client for picsum.photos"
  homepage "https://github.com/siakhooi/picsum"
  version "1.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Darwin_arm64.tar.gz"
      sha256 "3a17d385d1945402b02e23a0f4c6ea07681b3addd28c8700f51c59ae7f5432a7"
    end
    on_intel do
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Darwin_x86_64.tar.gz"
      sha256 "dd49382686f99ea19397c5ddd72c48033d63aab993268e5c7dec34a4f534b4ce"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_arm64.tar.gz"
      sha256 "5f00441db7794e27460991d4060c6cf26f702f9fb0614e4b333c7cd46dfadb0a"
    elsif Hardware::CPU.intel?
      if Hardware::CPU.is_64_bit?
        url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_x86_64.tar.gz"
        sha256 "f1ce7ee24576933fe6b517b6bff9c1a56d0337772da5c097d0a88edc3b6a336c"
      else
        url "https://github.com/siakhooi/picsum/releases/download/v#{version}/picsum_#{version}_Linux_i386.tar.gz"
        sha256 "9736afa248314e7a40192cffe70d28dcb02ec3352d3b275d9d90c8ab254d6f12"
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

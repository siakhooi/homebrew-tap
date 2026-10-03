# frozen_string_literal: true

class FiboPlanner < Formula
  desc "web app to run planning poker technique"
  homepage "https://github.com/siakhooi/fibo-planner"
  version "0.8.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/fibo-planner/releases/download/v#{version}/fibo-planner_#{version}_Darwin_arm64.tar.gz"
      sha256 "09d301ac5bd4478af25239b429aa684f268980c5834f4b9a80a3df4d0e43278b"
    end
    on_intel do
      url "https://github.com/siakhooi/fibo-planner/releases/download/v#{version}/fibo-planner_#{version}_Darwin_x86_64.tar.gz"
      sha256 "1ecf21bfb5a6406fcb4944021ce92ab4becc6e58c440fc7d8c6ddb54b873fc39"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/fibo-planner/releases/download/v#{version}/fibo-planner_#{version}_Linux_arm64.tar.gz"
      sha256 "e73cd21079b648d0ab822604220c726e6f4a5c1d51b71da2050f38f10a5eaf48"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/fibo-planner/releases/download/v#{version}/fibo-planner_#{version}_Linux_x86_64.tar.gz"
      sha256 "2d420171b3d4bfb47c3d69d157d192680d61f2d5c5158175b6bf3b24f2d30a1b"
    end
  end

  def install
    bin.install "fibo-planner"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fibo-planner --version")
  end
end

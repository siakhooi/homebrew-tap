# frozen_string_literal: true

class FiboPlanner < Formula
  desc "web app to run planning poker technique"
  homepage "https://github.com/siakhooi/fibo-planner"
  version "0.7.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/fibo-planner/releases/download/v#{version}/fibo-planner_#{version}_Darwin_arm64.tar.gz"
      sha256 "edb530157789f300b3a3edea43da517f869b4103825be2a094320d53f178f6e0"
    end
    on_intel do
      url "https://github.com/siakhooi/fibo-planner/releases/download/v#{version}/fibo-planner_#{version}_Darwin_x86_64.tar.gz"
      sha256 "35f58c2c3cb3e6cefb85ff87d9ea3b10a014198019063aed0f8c11a15763a180"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/fibo-planner/releases/download/v#{version}/fibo-planner_#{version}_Linux_arm64.tar.gz"
      sha256 "fe6f54579abd07808b5cf0a0e6210828f5c1d3a773a87af3e86514a44a7410dc"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/fibo-planner/releases/download/v#{version}/fibo-planner_#{version}_Linux_x86_64.tar.gz"
      sha256 "477eb23a260bbbaf5999f81cb4afbd41022cbb1a59e569f674f6a3464f41a9a9"
    end
  end

  def install
    bin.install "fibo-planner"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fibo-planner --version")
  end
end

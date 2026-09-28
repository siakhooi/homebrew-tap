# frozen_string_literal: true

class FiboPlanner < Formula
  desc "web app to run planning poker technique"
  homepage "https://github.com/siakhooi/fibo-planner"
  version "0.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/siakhooi/fibo-planner/releases/download/#{version}/fibo-planner_#{version}_Darwin_arm64.tar.gz"
      sha256 "760529f5d8669e5271784ac7fd90b2ab5181023c19da94fe3ac19116f65bb1df"
    end
    on_intel do
      url "https://github.com/siakhooi/fibo-planner/releases/download/#{version}/fibo-planner_#{version}_Darwin_x86_64.tar.gz"
      sha256 "85b27b59afe816f9d09f1ebd77fcd9282beae4eda6a28ab9026e6837f64e9fe1"
    end
  end

  on_linux do
    if Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/fibo-planner/releases/download/#{version}/fibo-planner_#{version}_Linux_arm64.tar.gz"
      sha256 "15908e767645212640b5c595b6225b19b3e8790ca99838fb40b75c57d2e6dfb4"
    elsif Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      url "https://github.com/siakhooi/fibo-planner/releases/download/#{version}/fibo-planner_#{version}_Linux_x86_64.tar.gz"
      sha256 "14f2c9415dfd521486f8cdbc54c850087c2f5c5788b1e712694d5e263d96a7e3"
    end
  end

  def install
    bin.install "fibo-planner"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fibo-planner --version")
  end
end
